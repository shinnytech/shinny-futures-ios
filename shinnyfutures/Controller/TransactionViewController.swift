//
//  TransactionViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/9.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController, PriceKeyboardViewDelegate, VolumeKeyboardViewDelegate, UITextFieldDelegate {

    // MARK: Properties
    var isVisible = false
    let dataManager = DataManager.getInstance()
    var direction = ""
    var exchange_id = ""
    var instrument_id_transaction = ""
    var isClosePriceShow = false
    var isRefreshPosition = true

    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var available: UILabel!
    @IBOutlet weak var usingRate: UILabel!

    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var volume: UITextField!

    @IBOutlet weak var last_price: UILabel!
    @IBOutlet weak var last_volume: UILabel!
    @IBOutlet weak var ask_price1: UILabel!
    @IBOutlet weak var ask_volume1: UILabel!
    @IBOutlet weak var bid_price1: UILabel!
    @IBOutlet weak var bid_volume1: UILabel!

    @IBOutlet weak var bid_insert_order: UIStackView!
    @IBOutlet weak var bid_order_price: UILabel!
    @IBOutlet weak var bid_order_direction: UILabel!
    @IBOutlet weak var ask_insert_order: UIStackView!
    @IBOutlet weak var ask_order_price: UILabel!
    @IBOutlet weak var ask_order_direction: UILabel!
    @IBOutlet weak var close_insert_order: UIStackView!
    @IBOutlet weak var close_order_price: UILabel!
    @IBOutlet weak var close_order_direction: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300)

        let priceKeyboardView = PriceKeyboardView(frame: frame)
        priceKeyboardView.delegate = self
        priceKeyboardView.processor.masterView = price
        price.inputView = priceKeyboardView
        price.delegate = self

        let volumekeyboardView = VolumeKeyboardView(frame: frame)
        volumekeyboardView.delegate = self
        volume.inputView = volumekeyboardView
        volume.delegate = self

        let bidTapGesture = UITapGestureRecognizer(target: self, action: #selector(bidInsertOrder))
        bid_insert_order.addGestureRecognizer(bidTapGesture)
        let askTapGesture = UITapGestureRecognizer(target: self, action: #selector(askInsertOrder))
        ask_insert_order.addGestureRecognizer(askTapGesture)
        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(closeInsertOrder))
        close_insert_order.addGestureRecognizer(closeTapGesture)

    }

    override func viewWillAppear(_ animated: Bool) {
        refreshPage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAccount), name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPrice), name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPage), name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        print("交易页销毁")
    }

    // MARK: functions
    //刷新页面
    @objc func refreshPage() {
        initPosition()
        refreshPrice()
        refreshAccount()
        refreshPriceKeyboardQuote()
    }

    //刷新价格软键盘合约代码
    func refreshPriceKeyboardQuote() {
        (price.inputView as! PriceKeyboardView).switchQuote()
    }

    //刷新软键盘涨跌停价格
    func refreshKeyboardPrice() {
        (volume.inputView as! VolumeKeyboardView).refreshPrice()
        (price.inputView as! PriceKeyboardView).refreshPrice()
    }

    //刷新软键盘最大可开仓手数
    func refreshKeyboardVolume() {
        (volume.inputView as! VolumeKeyboardView).refreshAccount()
        (price.inputView as! PriceKeyboardView).refreshAccount()
    }

    func initPosition() {
        if CommonConstants.USER_PRICE.elementsEqual(dataManager.sPriceType){
            dataManager.sPriceType = CommonConstants.COUNTERPARTY_PRICE
        }
        price.text = dataManager.sPriceType

        var position: Position?
        if dataManager.sInstrumentId.contains("KQ") {
            instrument_id_transaction = (dataManager.sSearchEntities[dataManager.sInstrumentId]?.underlying_symbol)!
        }else {
            instrument_id_transaction = dataManager.sInstrumentId
        }
        exchange_id = String(instrument_id_transaction.split(separator: ".")[0])
        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        position = user.positions[instrument_id_transaction]

        if let position = position {

            let volume_long = (position.volume_long as? Int) ?? 0
            let volume_short = (position.volume_short as? Int) ?? 0
            let volume_long_frozen_today = (position.volume_long_frozen_today as? Int) ?? 0
            let volume_short_frozen_today = (position.volume_short_frozen_today as? Int) ?? 0
            let volume_long_frozen_his = (position.volume_long_frozen_his as? Int) ?? 0
            let volume_short_frozen_his = (position.volume_short_frozen_his as? Int) ?? 0
            let available_long = volume_long - volume_long_frozen_today - volume_long_frozen_his
            let available_short = volume_short - volume_short_frozen_today - volume_short_frozen_his

            if volume_long != 0 && volume_short == 0 {
                direction = "多"
                volume.text = "\(available_long)"
                isClosePriceShow = true
                bid_order_direction.text = "加多"
                ask_order_direction.text = "锁仓"
                close_order_price.text = ask_order_price.text
            } else if volume_long == 0 && volume_short != 0 {
                direction = "空"
                volume.text = "\(available_short)"
                isClosePriceShow = true
                bid_order_direction.text = "锁仓"
                ask_order_direction.text = "加空"
                close_order_price.text = bid_order_price.text
            } else if volume_long != 0 && volume_short != 0 {
                if dataManager.sPositionDirection.isEmpty{
                    direction = "双向"
                    volume.text = "1"
                    isClosePriceShow = false
                    bid_order_direction.text = "买多"
                    ask_order_direction.text = "卖空"
                    close_order_price.text = "锁仓状态"
                } else {
                    switch dataManager.sPositionDirection{
                    case "多":
                        direction = "多"
                        volume.text = "\(available_long)"
                        isClosePriceShow = true
                        bid_order_direction.text = "加多"
                        ask_order_direction.text = "锁仓"
                        close_order_price.text = ask_order_price.text
                        break
                    case "空":
                        direction = "空"
                        volume.text = "\(available_short)"
                        isClosePriceShow = true
                        bid_order_direction.text = "锁仓"
                        ask_order_direction.text = "加空"
                        close_order_price.text = bid_order_price.text
                        break
                    default:
                        break
                    }
                    dataManager.sPositionDirection = ""
                    isRefreshPosition = false
                }
            } else {
                direction = ""
                volume.text = "1"
                isClosePriceShow = false
                bid_order_direction.text = "买多"
                ask_order_direction.text = "卖空"
                close_order_price.text = "先开先平"
            }
        } else {
            direction = ""
            volume.text = "1"
            isClosePriceShow = false
            bid_order_direction.text = "买多"
            ask_order_direction.text = "卖空"
            close_order_price.text = "先开先平"
        }
        close_order_direction.text = "平仓"
    }

    func calculator(_ calculator: PriceKeyboardView, didChangeValue value: String) {
        price.text = value
        let instrumentId = dataManager.sInstrumentId
        guard let quote = dataManager.sRtnMD.quotes[instrumentId] else {return}
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)
        //下单板价格显示
        let last_price = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.last_price ?? 0.0)")
        let ask_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.ask_price1 ?? 0.0)")
        let bid_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.bid_price1 ?? 0.0)")
        switch price.text {
        case CommonConstants.QUEUED_PRICE:
            dataManager.sPriceType = CommonConstants.QUEUED_PRICE
            bid_order_price.text = bid_price1
            ask_order_price.text = ask_price1
            if isClosePriceShow {
                if "多".elementsEqual(direction) {
                    close_order_price.text = ask_price1
                } else if "空".elementsEqual(direction) {
                    close_order_price.text = bid_price1
                }
            }
        case CommonConstants.COUNTERPARTY_PRICE:
            dataManager.sPriceType = CommonConstants.COUNTERPARTY_PRICE
            bid_order_price.text = ask_price1
            ask_order_price.text = bid_price1
            if isClosePriceShow {
                if "多".elementsEqual(direction) {
                    close_order_price.text = bid_price1
                } else if "空".elementsEqual(direction) {
                    close_order_price.text = ask_price1
                }
            }
        case CommonConstants.MARKET_PRICE:
            dataManager.sPriceType = CommonConstants.MARKET_PRICE
            let upper_limit = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.upper_limit ?? 0.0)")
            let lower_limit = dataManager.saveDecimalByPtick(decimal: decimal, data:"\(quote.lower_limit ?? 0.0)")

            bid_order_price.text = upper_limit
            ask_order_price.text = lower_limit
            if isClosePriceShow {
                if "多".elementsEqual(direction) {
                    close_order_price.text = lower_limit
                } else if "空".elementsEqual(direction) {
                    close_order_price.text = upper_limit
                }
            }
        case CommonConstants.LATEST_PRICE:
            dataManager.sPriceType = CommonConstants.LATEST_PRICE
            bid_order_price.text = last_price
            ask_order_price.text = last_price
            if isClosePriceShow {
                close_order_price.text = last_price
            }
        default:
            dataManager.sPriceType = CommonConstants.USER_PRICE
            bid_order_price.text = price.text
            ask_order_price.text = price.text
            if isClosePriceShow {
                close_order_price.text = price.text
            }
        }
    }

    func calculator(_ calculator: VolumeKeyboardView, didChangeValue value: String) {
        volume.text = value
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case 108:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.price.selectAll(nil)
            }
        case 109:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.volume.selectAll(nil)
            }
            (volume.inputView as! VolumeKeyboardView).setVolume(volume: volume.text)
        default:
            break
        }
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.HideUpViewNotification), object: nil)

    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.ShowUpViewNotification), object: nil)
    }

    // MARK: objc methods
    @objc func refreshAccount() {
        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        for (_, account) in user.accounts {
            let balance = Float("\(account.balance ?? 0.0)") ?? 0.0
            let margin = Float("\(account.margin ?? 0.0)") ?? 0.0
            let available = Float("\(account.available ?? 0.0)") ?? 0.0
            self.balance.text = String(format: "%.0f", balance)
            self.available.text = String(format: "%.0f", available)
            if balance != 0 {
                let usingRate = margin / balance * 100
                self.usingRate.text = String(format: "%.2f", usingRate) + "%"
            } else {
                self.usingRate.text = "0.00%"
            }
        }
        if isRefreshPosition{ refreshPosition() }
        refreshKeyboardVolume()
    }

    @objc func refreshPrice() {
        let instrumentId = dataManager.sInstrumentId
        guard let quote = dataManager.sRtnMD.quotes[instrumentId] else {return}
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)
        let last_price = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.last_price ?? 0.0)")
        let last_volume = "\(quote.volume ?? 0)"
        let ask_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.ask_price1 ?? 0.0)")
        let ask_volume1 = "\(quote.ask_volume1 ?? 0)"
        let bid_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.bid_price1 ?? 0.0)")
        let bid_volume1 = "\(quote.bid_volume1 ?? 0)"
        self.last_price.text = last_price
        self.last_volume.text = last_volume
        self.ask_price1.text = ask_price1
        self.ask_volume1.text = ask_volume1
        self.bid_price1.text = bid_price1
        self.bid_volume1.text = bid_volume1

        //下单板价格显示
        switch dataManager.sPriceType {
        case CommonConstants.QUEUED_PRICE:
            bid_order_price.text = bid_price1
            ask_order_price.text = ask_price1
            if isClosePriceShow {
                if "多".elementsEqual(direction) {
                    close_order_price.text = ask_price1
                } else if "空".elementsEqual(direction) {
                    close_order_price.text = bid_price1
                }
            }
        case CommonConstants.COUNTERPARTY_PRICE:
            bid_order_price.text = ask_price1
            ask_order_price.text = bid_price1
            if isClosePriceShow {
                if "多".elementsEqual(direction) {
                    close_order_price.text = bid_price1
                } else if "空".elementsEqual(direction) {
                    close_order_price.text = ask_price1
                }
            }
        case CommonConstants.MARKET_PRICE:
            let upper_limit = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.upper_limit ?? 0.0)")
            let lower_limit = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.lower_limit ?? 0.0)")
            bid_order_price.text = upper_limit
            ask_order_price.text = lower_limit
            if isClosePriceShow {
                if "多".elementsEqual(direction) {
                    close_order_price.text = lower_limit
                } else if "空".elementsEqual(direction) {
                    close_order_price.text = upper_limit
                }
            }
        case CommonConstants.LATEST_PRICE:
            bid_order_price.text = last_price
            ask_order_price.text = last_price
            if isClosePriceShow {
                close_order_price.text = last_price
            }
        default:
            break
        }
        refreshKeyboardPrice()
    }

    @objc func refreshPosition() {
        var position: Position?
        if dataManager.sInstrumentId.contains("KQ") {
            instrument_id_transaction = (dataManager.sSearchEntities[dataManager.sInstrumentId]?.underlying_symbol)!
        }else {
            instrument_id_transaction = dataManager.sInstrumentId
        }
        exchange_id = String(instrument_id_transaction.split(separator: ".")[0])
        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        position = user.positions[instrument_id_transaction]

        if let position = position {

            let volume_long = (position.volume_long as? Int) ?? 0
            let volume_short = (position.volume_short as? Int) ?? 0

            if volume_long != 0 && volume_short == 0 {
                direction = "多"
                isClosePriceShow = true
                bid_order_direction.text = "加多"
                ask_order_direction.text = "锁仓"
                close_order_price.text = ask_order_price.text
            } else if volume_long == 0 && volume_short != 0 {
                direction = "空"
                isClosePriceShow = true
                bid_order_direction.text = "锁仓"
                ask_order_direction.text = "加空"
                close_order_price.text = bid_order_price.text
            } else if volume_long != 0 && volume_short != 0 {
                direction = "双向"
                isClosePriceShow = false
                bid_order_direction.text = "买多"
                ask_order_direction.text = "卖空"
                close_order_price.text = "锁仓状态"
            } else {
                direction = ""
                isClosePriceShow = false
                bid_order_direction.text = "买多"
                ask_order_direction.text = "卖空"
                close_order_price.text = "先开先平"
            }
        } else {
            direction = ""
            isClosePriceShow = false
            bid_order_direction.text = "买多"
            ask_order_direction.text = "卖空"
            close_order_price.text = "先开先平"
        }
        close_order_direction.text = "平仓"
    }

    //买开仓
    @objc func bidInsertOrder() {
        self.view.endEditing(true)
        if let price = self.bid_order_price.text, let volume = self.volume.text {

            guard let price_d = Double(price) else {
                ToastUtils.showNegativeMessage(message: "价格输入不合法～")
                return
            }

            guard let volume_d = Int(volume) else {
                ToastUtils.showNegativeMessage(message: "手数输入不合法～")
                return
            }

            let title = "确认下单吗？"
            let message = "\(instrument_id_transaction), \(price), 买开, \(volume)手"
            initOrderAlert(title: title, message: message, exchangeId: exchange_id, instrumentId: String(instrument_id_transaction.split(separator: ".")[1]), direction: "BUY", offset: "OPEN", volume: volume_d, priceType: "LIMIT", price: price_d)
        }
    }

    //卖开仓
    @objc func askInsertOrder() {
        self.view.endEditing(true)
        if let price = self.ask_order_price.text, let volume = self.volume.text {

            guard let price_d = Double(price) else {
                ToastUtils.showNegativeMessage(message: "价格输入不合法～")
                return
            }

            guard let volume_d = Int(volume) else {
                ToastUtils.showNegativeMessage(message: "手数输入不合法～")
                return
            }

            let title = "确认下单吗？"
            let message = "\(instrument_id_transaction), \(price), 卖开, \(volume)手"
            initOrderAlert(title: title, message: message,exchangeId: exchange_id, instrumentId: String(instrument_id_transaction.split(separator: ".")[1]), direction: "SELL", offset: "OPEN", volume: volume_d, priceType: "LIMIT", price: price_d)
        }
    }

    //平仓
    @objc func closeInsertOrder() {
        self.view.endEditing(true)
        if let close_order_price = close_order_price.text {
            switch close_order_price {
            case "锁仓状态":
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "平多", style: .default) { _ in
                    self.direction  = "多"
                    self.isClosePriceShow = true
                    self.close_order_direction.text = "平多"
                    self.bid_order_direction.text = "加多"
                    self.ask_order_direction.text = "锁仓"
                    self.refreshCloseBidPrice()
                    self.closePosition()
                })
                alert.addAction(UIAlertAction(title: "平空", style: .default) { _ in
                    self.direction  = "空"
                    self.isClosePriceShow = true
                    self.close_order_direction.text = "平空"
                    self.bid_order_direction.text = "锁仓"
                    self.ask_order_direction.text = "加空"
                    self.refreshCloseAskPrice()
                    self.closePosition()
                })
                self.present(alert, animated: true) {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                    alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
                }
            case "先开先平":
                if instrument_id_transaction.contains("&"){
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "平多", style: .default) { _ in
                        self.direction  = "多"
                        self.isClosePriceShow = true
                        self.close_order_direction.text = "平多"
                        self.refreshCloseBidPrice()
                        self.closePosition()
                    })
                    alert.addAction(UIAlertAction(title: "平空", style: .default) { _ in
                        self.direction  = "空"
                        self.isClosePriceShow = true
                        self.close_order_direction.text = "平空"
                        self.refreshCloseAskPrice()
                        self.closePosition()
                    })
                    self.present(alert, animated: true) {
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                        alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
                    }
                }else {
                    ToastUtils.showNegativeMessage(message: "此合约您还没有持仓～")
                }
            default:
                closePosition()
            }
        }
    }

    //点击空白处alert消失
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }

    //刷新平多仓位
    func refreshCloseBidPrice() {
        let instrumentId = dataManager.sInstrumentId
        guard let quote = dataManager.sRtnMD.quotes[instrumentId] else {return}
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)

        switch dataManager.sPriceType {
        case CommonConstants.QUEUED_PRICE:
            let ask_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.ask_price1 ?? 0.0)")
            close_order_price.text = ask_price1
        case CommonConstants.COUNTERPARTY_PRICE:
            let bid_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.bid_price1 ?? 0.0)")
            close_order_price.text = bid_price1
        case CommonConstants.MARKET_PRICE:
            let lower_limit = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.lower_limit ?? 0.0)")
            close_order_price.text = lower_limit
        case CommonConstants.LATEST_PRICE:
            let last_price = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.last_price ?? 0.0)")
            close_order_price.text = last_price
        default:
            break
        }

    }

    //刷新平空仓位
    func refreshCloseAskPrice() {
        let instrumentId = dataManager.sInstrumentId
        guard let quote = dataManager.sRtnMD.quotes[instrumentId] else {return}
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)

        switch dataManager.sPriceType {
        case CommonConstants.QUEUED_PRICE:
            let bid_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.bid_price1 ?? 0.0)")
            close_order_price.text = bid_price1
        case CommonConstants.COUNTERPARTY_PRICE:
            let ask_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.ask_price1 ?? 0.0)")
            close_order_price.text = ask_price1
        case CommonConstants.MARKET_PRICE:
            let upper_limit = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.upper_limit ?? 0.0)")
            close_order_price.text = upper_limit
        case CommonConstants.LATEST_PRICE:
            let last_price = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(quote.last_price ?? 0.0)")
            close_order_price.text = last_price
        default:
            break
        }
    }


    //平仓处理函数
    func closePosition() {
        if let price = close_order_price.text, let volume = volume.text, !"".elementsEqual(direction) {

            guard let price_d = Double(price) else {
                ToastUtils.showNegativeMessage(message: "价格输入不合法～")
                return
            }

            guard let volume_d = Int(volume) else {
                ToastUtils.showNegativeMessage(message: "手数输入不合法～")
                return
            }

            let direction = self.direction.elementsEqual("多") ? "SELL" : "BUY"
            let title = "确认下单吗？"
            let instrument_id = String(self.instrument_id_transaction.split(separator: ".")[1])
            let message_today = "\(instrument_id_transaction), \(price), 平今, \(volume)手"
            let message_history = "\(instrument_id_transaction), \(price), 平昨, \(volume)手"
            let searchEntity = dataManager.sSearchEntities[instrument_id_transaction]
            if searchEntity != nil, let exchange_name = searchEntity?.exchange_name, "上海期货交易所".elementsEqual(exchange_name) || "上海国际能源交易中心".elementsEqual(exchange_name) {
                guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
                guard let position = user.positions[instrument_id_transaction] else {return}
                var volumre_today = 0
                var volume_history = 0
                if "SELL".elementsEqual(direction) {
                    volumre_today = (position.volume_long_today as? Int) ?? 0
                    volume_history = (position.volume_long_his as? Int) ?? 0
                } else if "BUY".elementsEqual(direction) {
                    volumre_today = (position.volume_short_today as? Int) ?? 0
                    volume_history = (position.volume_short_his as? Int) ?? 0
                }

                if volumre_today > 0 && volume_history > 0 {
                    if volume_d <= volumre_today || volume_d <= volume_history {
                        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "平今", style: .default) { _ in
                            self.initOrderAlert(title: title, message: message_today, exchangeId: self.exchange_id, instrumentId: instrument_id, direction: direction, offset: "CLOSETODAY", volume: volume_d, priceType: "LIMIT", price: price_d)
                        })
                        alert.addAction(UIAlertAction(title: "平昨", style: .default) { _ in
                            self.initOrderAlert(title: title, message: message_history, exchangeId: self.exchange_id, instrumentId: instrument_id, direction: direction, offset: "CLOSE", volume: volume_d, priceType: "LIMIT", price: price_d)
                        })
                        present(alert, animated: true)
                    } else if volume_d > volumre_today || volume_d > volume_history {
                        let volume_sub = volume_d - volumre_today
                        let message1 = "\(instrument_id_transaction), \(price), 平今, \(volumre_today)手"
                        let message2 = "\(instrument_id_transaction), \(price), 平昨, \(volume_sub)手"
                        initOrderAlert(title: title, message1: message1, message2: message2,exchangeId: exchange_id, instrumentId: instrument_id, direction: direction, offset1: "CLOSETODAY", offset2: "CLOSE", volume1: volumre_today, volume2: volume_sub, priceType: "LIMIT", price: price_d)
                    }
                } else if volumre_today == 0 && volume_history > 0 {
                    initOrderAlert(title: title, message: message_history, exchangeId: exchange_id, instrumentId: instrument_id, direction: direction, offset: "CLOSE", volume: volume_d, priceType: "LIMIT", price: price_d)
                } else if volumre_today > 0 && volume_history == 0 {
                    initOrderAlert(title: title, message: message_today, exchangeId: exchange_id, instrumentId: instrument_id, direction: direction, offset: "CLOSETODAY", volume: volume_d, priceType: "LIMIT", price: price_d)
                }

            } else {
                let message = "\(instrument_id_transaction), \(price), 平仓, \(volume)手"
                initOrderAlert(title: title, message: message, exchangeId: exchange_id, instrumentId: instrument_id, direction: direction, offset: "CLOSE", volume: volume_d, priceType: "LIMIT", price: price_d)
            }
        }
    }


    //下单对话框
    func initOrderAlert(title: String, message: String, exchangeId: String, instrumentId: String, direction: String, offset: String, volume: Int, priceType: String, price: Double) {
        self.isRefreshPosition = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: {action in
            switch action.style {
            case .default:
                TDWebSocketUtils.getInstance().sendReqInsertOrder(exchange_id: exchangeId, instrument_id: instrumentId, direction: direction, offset: offset, volume: volume, price_type: priceType, limit_price: price)
                self.refreshPosition()
                self.isRefreshPosition = true
            default:
                break
            }}))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: {action in
            self.refreshPosition()
            self.isRefreshPosition = true
        }))
        present(alert, animated: true, completion: nil)
    }

    //平今平昨对话框
    func initOrderAlert(title: String, message1: String, message2: String, exchangeId: String, instrumentId: String, direction: String, offset1: String, offset2: String, volume1: Int, volume2: Int, priceType: String, price: Double) {
        self.isRefreshPosition = false
        let alert = UIAlertController(title: title, message: "\(message1)\n\(message2)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: {action in
            switch action.style {
            case .default:
                TDWebSocketUtils.getInstance().sendReqInsertOrder(exchange_id: exchangeId, instrument_id: instrumentId, direction: direction, offset: offset1, volume: volume1, price_type: priceType, limit_price: price)
                TDWebSocketUtils.getInstance().sendReqInsertOrder(exchange_id: exchangeId, instrument_id: instrumentId, direction: direction, offset: offset2, volume: volume2, price_type: priceType, limit_price: price)
                self.refreshPosition()
                self.isRefreshPosition = true
            default:
                break
            }}))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: {action in
            self.refreshPosition()
            self.isRefreshPosition = true
        }))
        present(alert, animated: true, completion: nil)
    }

}
