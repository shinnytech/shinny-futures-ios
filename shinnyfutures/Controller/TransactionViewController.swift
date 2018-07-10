//
//  TransactionViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/9.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import SwiftyJSON

class TransactionViewController: UIViewController, PriceKeyboardViewDelegate, VolumeKeyboardViewDelegate, UITextFieldDelegate {

    // MARK: Properties
    var isVisible = false
    let dataManager = DataManager.getInstance()
    var priceType = "最新价"
    var direction = ""
    var key = ""
    var exchange_id = ""
    var isClosePriceShow = false

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAccount), name: Notification.Name(CommonConstants.AccountNotification), object: nil)
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
        refreshPrice()
        refreshAccount()
        initPosition()
    }

    func initPosition() {
        price.text = "最新价"
        priceType = "最新价"
        var position: JSON?
        let instrumentId = dataManager.sInstrumentId
        if let exchange_id = (dataManager.sSearchEntities[instrumentId]?.exchange_id) {
            self.key = exchange_id + "." + instrumentId
            self.exchange_id = exchange_id
            position = dataManager.sRtnPositions[key]
        }
        if let position = position {
            let available_long = position[PositionConstants.volume_long_today].intValue + position[PositionConstants.volume_long_his].intValue
            let volume_long = available_long + position[PositionConstants.volume_long_frozen].intValue
            let available_short = position[PositionConstants.volume_short_today].intValue + position[PositionConstants.volume_short_his].intValue
            let volume_short = available_short + position[PositionConstants.volume_short_frozen].intValue
            if volume_long != 0 && volume_short == 0 {
                direction = "多"
                volume.text = "\(available_long)"
                isClosePriceShow = true
                bid_order_direction.text = "加多"
                ask_order_direction.text = "锁仓"
                close_order_price.text = bid_order_price.text
            } else if volume_long == 0 && volume_short != 0 {
                direction = "空"
                volume.text = "\(available_short)"
                isClosePriceShow = true
                bid_order_direction.text = "锁仓"
                ask_order_direction.text = "加空"
                close_order_price.text = bid_order_price.text
            } else if volume_long != 0 && volume_short != 0 {
                direction = "双向"
                volume.text = "1"
                isClosePriceShow = false
                bid_order_direction.text = "买多"
                ask_order_direction.text = "卖空"
                close_order_price.text = "锁仓状态"
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

    func refreshPosition() {
        var position: JSON?
        let instrumentId = dataManager.sInstrumentId
        if let exchange_id = (dataManager.sSearchEntities[instrumentId]?.exchange_id) {
            self.key = exchange_id + "." + instrumentId
            self.exchange_id = exchange_id
            position = dataManager.sRtnPositions[key]
        }
        if let position = position {
            let available_long = position[PositionConstants.volume_long_today].intValue + position[PositionConstants.volume_long_his].intValue
            let volume_long = available_long + position[PositionConstants.volume_long_frozen].intValue
            let available_short = position[PositionConstants.volume_short_today].intValue + position[PositionConstants.volume_short_his].intValue
            let volume_short = available_short + position[PositionConstants.volume_short_frozen].intValue
            if volume_long != 0 && volume_short == 0 {
                direction = "多"
                isClosePriceShow = true
                bid_order_direction.text = "加多"
                ask_order_direction.text = "锁仓"
                close_order_price.text = bid_order_price.text
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

    func calculator(_ calculator: PriceKeyboardView, didChangeValue value: String) {
        price.text = value
        let instrumentId = dataManager.sInstrumentId
        let quote = dataManager.sRtnMD[RtnMDConstants.quotes][instrumentId]
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)
        if !quote.isEmpty {
            //下单板价格显示
            let last_price = dataManager.saveDecimalByPtick(decimal: decimal, data: quote[QuoteConstants.last_price].stringValue)
            let ask_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: quote[QuoteConstants.ask_price1].stringValue)
            let bid_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: quote[QuoteConstants.bid_price1].stringValue)
            switch price.text {
            case "排队价":
                priceType = "排队价"
                bid_order_price.text = bid_price1
                ask_order_price.text = ask_price1
                if isClosePriceShow {
                    if "多".elementsEqual(direction) {
                        close_order_price.text = ask_price1
                    } else if "空".elementsEqual(direction) {
                        close_order_price.text = bid_price1
                    }
                }
            case "对手价":
                priceType = "对手价"
                bid_order_price.text = ask_price1
                ask_order_price.text = bid_price1
                if isClosePriceShow {
                    if "多".elementsEqual(direction) {
                        close_order_price.text = bid_price1
                    } else if "空".elementsEqual(direction) {
                        close_order_price.text = ask_price1
                    }
                }
            case "市价":
                priceType = "市价"
                let upper_limit = dataManager.saveDecimalByPtick(decimal: decimal, data: quote[QuoteConstants.upper_limit].stringValue)
                let lower_limit = dataManager.saveDecimalByPtick(decimal: decimal, data: quote[QuoteConstants.lower_limit].stringValue)

                bid_order_price.text = upper_limit
                ask_order_price.text = lower_limit
                if isClosePriceShow {
                    close_order_price.text = upper_limit
                }
            case "最新价":
                priceType = "最新价"
                bid_order_price.text = last_price
                ask_order_price.text = last_price
                if isClosePriceShow {
                    close_order_price.text = last_price
                }
            default:
                priceType = "用户设置价"
                bid_order_price.text = price.text
                ask_order_price.text = price.text
                if isClosePriceShow {
                    close_order_price.text = price.text
                }
            }
        }
    }

    func calculator(_ calculator: VolumeKeyboardView, didChangeValue value: String) {
        volume.text = value
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.HideUpViewNotification), object: nil)

    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.ShowUpViewNotification), object: nil)
    }

    //平仓处理函数
    func closePosition() {
        if let price = close_order_price.text, let volume = volume.text, !"".elementsEqual(direction) {

            if price.elementsEqual("0") || price.elementsEqual(".") {
                ToastUtils.showNegativeMessage(message: "价格输入不合法～")
                return
            }

            if volume.elementsEqual("0") || volume.count > 7 {
                ToastUtils.showNegativeMessage(message: "手数输入不合法～")
                return
            }

            let direction = self.direction.elementsEqual("多") ? "SELL" : "BUY"
            let volume = Int(volume)!
            let price = Double(price)!
            let order_id = Int(Date().timeIntervalSince1970)
            let title = "确认下单吗？"
            let message_today = "\(dataManager.sInstrumentId), \(price), 平今, \(volume)手"
            let message_history = "\(dataManager.sInstrumentId), \(price), 平昨, \(volume)手"
            let searchEntity = dataManager.sSearchEntities[dataManager.sInstrumentId]
            if searchEntity != nil, let exchange_name = searchEntity?.exchange_name, "上海国际能源交易中心".elementsEqual(exchange_name) || "上海国际能源交易中心".elementsEqual(exchange_name) {
                guard let position = dataManager.sRtnPositions[key] else {return}
                var volumre_today = 0
                var volume_history = 0
                if "多".elementsEqual(direction) {
                    volumre_today = position[PositionConstants.volume_long_today].intValue
                    volume_history = position[PositionConstants.volume_long_his].intValue
                } else if "空".elementsEqual(direction) {
                    volumre_today = position[PositionConstants.volume_short_today].intValue
                    volume_history = position[PositionConstants.volume_short_his].intValue
                }

                if volumre_today > 0 && volume_history > 0 {
                    if volume <= volumre_today || volume <= volume_history {
                        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "平今", style: .default) { _ in
                            self.initOrderAlert(title: title, message: message_today, orderId: "\(order_id)", exchangeId: self.exchange_id, instrumentId: self.dataManager.sInstrumentId, direction: direction, offset: "CLOSETODAY", volume: volume, priceType: "LIMIT", price: price)
                        })
                        alert.addAction(UIAlertAction(title: "平昨", style: .default) { _ in
                            self.initOrderAlert(title: title, message: message_history, orderId: "\(order_id)", exchangeId: self.exchange_id, instrumentId: self.dataManager.sInstrumentId, direction: direction, offset: "CLOSE", volume: volume, priceType: "LIMIT", price: price)
                        })
                        present(alert, animated: true)
                    } else if volume > volumre_today || volume > volume_history {
                        let volume_sub = volume - volumre_today
                        let message1 = "\(dataManager.sInstrumentId), \(price), 平今, \(volumre_today)手"
                        let message2 = "\(dataManager.sInstrumentId), \(price), 平昨, \(volume_sub)手"
                        initOrderAlert(title: title, message1: message1, message2: message2, orderId: "\(order_id)", exchangeId: exchange_id, instrumentId: dataManager.sInstrumentId, direction: direction, offset1: "CLOSETODAY", offset2: "CLOSE", volume1: volumre_today, volume2: volume_sub, priceType: "LIMIT", price: price)
                    }
                } else if volumre_today == 0 && volume_history > 0 {
                    initOrderAlert(title: title, message: message_history, orderId: "\(order_id)", exchangeId: exchange_id, instrumentId: dataManager.sInstrumentId, direction: direction, offset: "CLOSE", volume: volume, priceType: "LIMIT", price: price)
                } else if volumre_today > 0 && volume_history == 0 {
                    initOrderAlert(title: title, message: message_today, orderId: "\(order_id)", exchangeId: exchange_id, instrumentId: dataManager.sInstrumentId, direction: direction, offset: "CLOSETODAY", volume: volume, priceType: "LIMIT", price: price)
                }

            } else {
                let message = "\(dataManager.sInstrumentId), \(price), 平仓, \(volume)手"
                initOrderAlert(title: title, message: message, orderId: "\(order_id)", exchangeId: exchange_id, instrumentId: dataManager.sInstrumentId, direction: direction, offset: "CLOSE", volume: volume, priceType: "LIMIT", price: price)
            }
        }
    }

    //下单对话框
    func initOrderAlert(title: String, message: String, orderId: String, exchangeId: String, instrumentId: String, direction: String, offset: String, volume: Int, priceType: String, price: Double) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            switch action.style {
            case .default:
                TDWebSocketUtils.getInstance().sendReqInsertOrder(order_id: orderId, exchange_id: exchangeId, instrument_id: instrumentId, direction: direction, offset: offset, volume: volume, priceType: priceType, price: price)
                self.refreshPosition()
            default:
                break
            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    //平今平昨对话框
    func initOrderAlert(title: String, message1: String, message2: String, orderId: String, exchangeId: String, instrumentId: String, direction: String, offset1: String, offset2: String, volume1: Int, volume2: Int, priceType: String, price: Double) {
        let alert = UIAlertController(title: title, message: "\(message1)\n\(message2)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            switch action.style {
            case .default:
                TDWebSocketUtils.getInstance().sendReqInsertOrder(order_id: orderId, exchange_id: exchangeId, instrument_id: instrumentId, direction: direction, offset: offset1, volume: volume1, priceType: priceType, price: price)
                TDWebSocketUtils.getInstance().sendReqInsertOrder(order_id: orderId, exchange_id: exchangeId, instrument_id: instrumentId, direction: direction, offset: offset2, volume: volume2, priceType: priceType, price: price)
                self.refreshPosition()
            default:
                break
            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: objc methods
    @objc func refreshAccount() {
        for (_, account) in dataManager.sRtnAcounts {
            let balance = account[AccountConstants.balance].floatValue
            let margin = account[AccountConstants.margin].floatValue
            let available = account[AccountConstants.available].floatValue
            self.balance.text = String(format: "%.0f", balance)
            self.available.text = String(format: "%.0f", available)
            if balance != 0 {
                let usingRate = margin / balance * 100
                self.usingRate.text = String(format: "%.0f", usingRate) + "%"
            } else {
                self.usingRate.text = "0%"
            }
        }
    }

    @objc func refreshPrice() {
        let instrumentId = dataManager.sInstrumentId
        let quote = dataManager.sRtnMD[RtnMDConstants.quotes][instrumentId]
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)
        if !quote.isEmpty {
            let last_price = dataManager.saveDecimalByPtick(decimal: decimal, data: quote[QuoteConstants.last_price].stringValue)
            let last_volume = quote[QuoteConstants.volume].stringValue
            let ask_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: quote[QuoteConstants.ask_price1].stringValue)
            let ask_volume1 = quote[QuoteConstants.ask_volume1].stringValue
            let bid_price1 = dataManager.saveDecimalByPtick(decimal: decimal, data: quote[QuoteConstants.bid_price1].stringValue)
            let bid_volume1 = quote[QuoteConstants.bid_volume1].stringValue
            self.last_price.text = last_price
            self.last_volume.text = last_volume
            self.ask_price1.text = ask_price1
            self.ask_volume1.text = ask_volume1
            self.bid_price1.text = bid_price1
            self.bid_volume1.text = bid_volume1

            //下单板价格显示
            switch priceType {
            case "排队价":
                bid_order_price.text = bid_price1
                ask_order_price.text = ask_price1
                if isClosePriceShow {
                    if "多".elementsEqual(direction) {
                        close_order_price.text = ask_price1
                    } else if "空".elementsEqual(direction) {
                        close_order_price.text = bid_price1
                    }
                }
            case "对手价":
                bid_order_price.text = ask_price1
                ask_order_price.text = bid_price1
                if isClosePriceShow {
                    if "多".elementsEqual(direction) {
                        close_order_price.text = bid_price1
                    } else if "空".elementsEqual(direction) {
                        close_order_price.text = ask_price1
                    }
                }
            case "市价":
                let upper_limit = dataManager.saveDecimalByPtick(decimal: decimal, data: quote[QuoteConstants.upper_limit].stringValue)
                let lower_limit = dataManager.saveDecimalByPtick(decimal: decimal, data: quote[QuoteConstants.lower_limit].stringValue)
                bid_order_price.text = upper_limit
                ask_order_price.text = lower_limit
                if isClosePriceShow {
                    close_order_price.text = upper_limit
                }
            case "最新价":
                bid_order_price.text = last_price
                ask_order_price.text = last_price
                if isClosePriceShow {
                    close_order_price.text = last_price
                }
            default:
                break
            }
        }

    }

    //买开仓
    @objc func bidInsertOrder() {
        if let price = self.bid_order_price.text, let volume = self.volume.text {
            if price.elementsEqual("0") || price.elementsEqual(".") {
                ToastUtils.showNegativeMessage(message: "价格输入不合法～")
                return
            }

            if volume.elementsEqual("0") || volume.count > 7 {
                ToastUtils.showNegativeMessage(message: "手数输入不合法～")
                return
            }
            let price = Double(price)!
            let volume = Int(volume)!
            let title = "确认下单吗？"
            let order_id = Int(Date().timeIntervalSince1970)
            let message = "\(dataManager.sInstrumentId), \(price), 买开, \(volume)手"
            initOrderAlert(title: title, message: message, orderId: "\(order_id)", exchangeId: exchange_id, instrumentId: dataManager.sInstrumentId, direction: "BUY", offset: "OPEN", volume: volume, priceType: "LIMIT", price: price)
        }
    }

    //卖开仓
    @objc func askInsertOrder() {
        if let price = self.ask_order_price.text, let volume = self.volume.text {
            if price.elementsEqual("0") || price.elementsEqual(".") {
                ToastUtils.showNegativeMessage(message: "价格输入不合法～")
                return
            }

            if volume.elementsEqual("0") || volume.count > 7 {
                ToastUtils.showNegativeMessage(message: "手数输入不合法～")
                return
            }
            let price = Double(price)!
            let volume = Int(volume)!
            let title = "确认下单吗？"
            let order_id = Int(Date().timeIntervalSince1970)
            let message = "\(dataManager.sInstrumentId), \(price), 卖开, \(volume)手"
            initOrderAlert(title: title, message: message, orderId: "\(order_id)", exchangeId: exchange_id, instrumentId: dataManager.sInstrumentId, direction: "SELL", offset: "OPEN", volume: volume, priceType: "LIMIT", price: price)
        }
    }

    //平仓
    @objc func closeInsertOrder() {
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
                    if "排队价".elementsEqual(self.priceType) {
                        self.close_order_price.text = self.ask_order_price.text
                    } else {
                        self.close_order_price.text = self.bid_order_price.text
                    }
                    self.closePosition()
                })
                alert.addAction(UIAlertAction(title: "平空", style: .default) { _ in
                    self.direction  = "空"
                    self.isClosePriceShow = true
                    self.close_order_direction.text = "平空"
                    self.bid_order_direction.text = "锁仓"
                    self.ask_order_direction.text = "加空"
                    if "对手价".elementsEqual(self.priceType) {
                        self.close_order_price.text = self.ask_order_price.text
                    } else {
                        self.close_order_price.text = self.bid_order_price.text
                    }
                    self.closePosition()
                })
                present(alert, animated: true)
            case "先开先平":
                ToastUtils.showNegativeMessage(message: "此合约您还没有持仓～")
            default:
                closePosition()
            }
        }
    }

}
