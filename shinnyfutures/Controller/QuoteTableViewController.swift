//
//  QuoteTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/26.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import SwiftyJSON
import DeepDiff

class QuoteTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: Properties
    let dataManager = DataManager.getInstance()
    //用来控制标题
    var index = 1
    var isChangePercent = true
    var isOpenInterest = true
    var isUpperLimit = true
    var isRefresh = true
    var quotes = [JSON]()
    var insList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // make tableview look better in ipad
        tableView.cellLayoutMarginsFollowReadableWidth = true
        let longPressGusture = UILongPressGestureRecognizer(target: self, action: #selector(QuoteTableViewController.longPress(longPressGestureRecognizer:)))
        tableView.addGestureRecognizer(longPressGusture)
        NotificationCenter.default.addObserver(self, selector: #selector(initInsList), name: Notification.Name(CommonConstants.RefreshOptionalInsListNotification), object: nil)
        quotes = dataManager.sQuotes[self.index].map {$0.value}

        insList = dataManager.sQuotes[self.index].map {$0.key}
    }
    
    //iPhone下默认是.overFullScreen(全屏显示)，需要返回.none，否则没有弹出框效果，iPad则不需要
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDatas), name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.RefreshOptionalInsListNotification), object: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "QuoteTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? QuoteTableViewCell  else {
            fatalError("The dequeued cell is not an instance of QuoteTableViewCell.")
        }

        // Fetches the appropriate quote for the data source layout.
        let quote = quotes[indexPath.row]
        let instrumentId = quote[QuoteConstants.instrument_id].stringValue
        let insturmentName = quote[QuoteConstants.instrument_name].stringValue
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)
        cell.name.text = insturmentName

        if index == 7 || index == 8 {
            if isUpperLimit {
                let upper_limit = quote[QuoteConstants.upper_limit].stringValue
                if let upper_limit = Float(upper_limit){
                    if upper_limit < 0 {cell.last.textColor = UIColor.green} else {cell.last.textColor = UIColor.red}
                }
                cell.last.text = dataManager.saveDecimalByPtick(decimal: decimal, data: upper_limit)
            }else{
                let lower_limit = quote[QuoteConstants.lower_limit].stringValue
                if let lower_limit = Float(lower_limit){
                    if lower_limit < 0 {cell.last.textColor = UIColor.green} else {cell.last.textColor = UIColor.red}
                }
                cell.last.text = dataManager.saveDecimalByPtick(decimal: decimal, data: lower_limit)
            }

            if isChangePercent {
                let bid_price1 = quote[QuoteConstants.bid_price1].stringValue
                if let bid_price1 = Float(bid_price1){
                    if bid_price1 < 0 {cell.changePercent.textColor = UIColor.green} else {cell.changePercent.textColor = UIColor.red}
                }
                cell.changePercent.text = dataManager.saveDecimalByPtick(decimal: decimal, data: bid_price1)
            } else {
                let ask_price1 = quote[QuoteConstants.ask_price1].stringValue
                if let ask_price1 = Float(ask_price1){
                    if ask_price1 < 0 {cell.changePercent.textColor = UIColor.green} else {cell.changePercent.textColor = UIColor.red}
                }
                cell.changePercent.text = dataManager.saveDecimalByPtick(decimal: decimal, data: ask_price1)
            }
            if isOpenInterest {
                cell.openInterest.text = quote[QuoteConstants.bid_volume1].stringValue
            } else {
                cell.openInterest.text = quote[QuoteConstants.ask_volume1].stringValue
            }
        }else{
            let last = quote[QuoteConstants.last_price].stringValue
            let pre_settlement = quote[QuoteConstants.pre_settlement].stringValue
            cell.last.text = dataManager.saveDecimalByPtick(decimal: decimal, data: last)
            if let last = Float(last), let pre_settlement = Float(pre_settlement) {
                if last < 0 {cell.last.textColor = UIColor.green} else {cell.last.textColor = UIColor.red}
                let change = last - pre_settlement
                if change < 0 {cell.changePercent.textColor = UIColor.green} else {cell.changePercent.textColor = UIColor.red}
                if isChangePercent {
                    let change_percent = change / pre_settlement
                    cell.changePercent.text = dataManager.saveDecimalByPtick(decimal: 2, data: "\(change_percent)")
                } else {
                    cell.changePercent.text = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(change)")
                }
            }else{
                cell.changePercent.text = "-"
            }

            if isOpenInterest {
                cell.openInterest.text = quote[QuoteConstants.open_interest].stringValue
            } else {
                cell.openInterest.text = quote[QuoteConstants.volume].stringValue
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
        headerView.backgroundColor = UIColor(red: 31/255, green:31/255, blue: 31/255, alpha: 1.0)
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width - 10, height: 44.0))
        stackView.distribution = .fillEqually
        let name = UILabel()
        name.textColor = UIColor.white
        name.text = "合约名称"
        name.textAlignment = .center
        let last = UILabel()
        last.textColor = UIColor.white
        last.textAlignment = .right
        let tapUpperLimit = UITapGestureRecognizer(target: self, action: #selector(QuoteTableViewController.tapUpperLimit))
        last.isUserInteractionEnabled = true
        last.addGestureRecognizer(tapUpperLimit)

        let changePercent = UILabel()
        changePercent.textColor = UIColor.white
        changePercent.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        changePercent.textAlignment = .right
        let tapChangePercent = UITapGestureRecognizer(target: self, action: #selector(QuoteTableViewController.tapChangePercent))
        changePercent.isUserInteractionEnabled = true
        changePercent.addGestureRecognizer(tapChangePercent)

        let openInterest = UILabel()
        openInterest.backgroundColor = UIColor(red: 31/255, green:31/255, blue: 31/255, alpha: 1.0)
        openInterest.textColor = UIColor.white
        openInterest.textAlignment = .right
        let tapOpenInterest = UITapGestureRecognizer(target: self, action: #selector(QuoteTableViewController.tapOpenInterest))
        openInterest.isUserInteractionEnabled = true
        openInterest.addGestureRecognizer(tapOpenInterest)

        if index == 7 || index == 8 {
            if isUpperLimit {
                last.text = "涨停价⇲"
            }else{
                last.text = "跌停价⇲"
            }

            if isChangePercent {
                changePercent.text = "买价⇲"
            } else {
                changePercent.text = "卖价⇲"
            }

            if isOpenInterest {
                openInterest.text = "买量⇲"
            } else {
                openInterest.text = "卖量⇲"
            }
        }else {
            last.text = "最新价"
            if isChangePercent {
                changePercent.text = "涨跌幅%⇲"
            } else {
                changePercent.text = "涨跌⇲"
            }

            if isOpenInterest {
                openInterest.text = "持仓量⇲"
            } else {
                openInterest.text = "成交量⇲"
            }
        }

        stackView.addArrangedSubview(name)
        stackView.addArrangedSubview(last)
        stackView.addArrangedSubview(changePercent)
        stackView.addArrangedSubview(openInterest)
        headerView.addSubview(stackView)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    //UICollectionView有3种停止滚动类型，分别是：1、快速滚动，自然停止；2、快速滚动，手指按压突然停止；3、慢速上下滑动停止。
    //1. - (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
    //2. - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView；
    //3. - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate；
    //停止类型1：DidEndDecelerat:0,dragging:0,decelerating:0
    //停止类型2：DidEndDragging:tracking:1,dragging:0,decelerating:1
    //DidEndDecelerat:tracking:0,dragging:0,decelerating:0
    //停止类型3：DidEndDragging:tracking:1,dragging:0,decelerating:0
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToScrollStop {
            isRefresh = true
            sendSubscribeQuotes()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let dragToDragStop = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
            if dragToDragStop {
                isRefresh = true
                sendSubscribeQuotes()
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isRefresh = false
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let instrumentId = insList[indexPath.row]
            DataManager.getInstance().sPreInsList = DataManager.getInstance().sRtnMD[RtnMDConstants.ins_list].stringValue
            dataManager.sInstrumentId = instrumentId
        }
    }
    
    // MARK: Methods
    func sendSubscribeQuotes() {
        let indexPathsForVisiableRows = self.tableView.indexPathsForVisibleRows
        //侧滑页面以及滑动列表时订阅
        if let indexPaths = indexPathsForVisiableRows {
            if  indexPaths.count > 0 {
                let firstIndex = indexPaths[0].row
                let lastIndex = firstIndex + CommonConstants.MAX_SUBSCRIBE_QUOTES
                let ins = insList.count < lastIndex ? insList[firstIndex..<insList.count].joined(separator: ","): insList[firstIndex..<lastIndex].joined(separator: ",")
                if !ins.elementsEqual(dataManager.sRtnMD[RtnMDConstants.ins_list].stringValue) {
                    MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: ins)
                }
            }else{
                //当自选合约列表从无到有，从主力合约滑动过来时，虽然indexPaths.count==0，但是需要重新加载合约列表，订阅刚添加的合约行情
                let ins = insList.count < CommonConstants.MAX_SUBSCRIBE_QUOTES ? insList[0..<insList.count].joined(separator: ","): insList[0..<CommonConstants.MAX_SUBSCRIBE_QUOTES].joined(separator: ",")
                if !ins.elementsEqual(dataManager.sRtnMD[RtnMDConstants.ins_list].stringValue) {
                    MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: ins)
                }
            }
        } else {
            //导航栏切换页面时订阅
            let ins = insList.count < CommonConstants.MAX_SUBSCRIBE_QUOTES ? insList[0..<insList.count].joined(separator: ","): insList[0..<CommonConstants.MAX_SUBSCRIBE_QUOTES].joined(separator: ",")
            if !ins.elementsEqual(dataManager.sRtnMD[RtnMDConstants.ins_list].stringValue) {
                MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: ins)
            }
        }
    }
    
    // MARK: objc Methods
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let instrumentId = insList[indexPath.row]
                if let optionalPopupView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: CommonConstants.OptionalPopupViewController) as? OptionalPopupViewController {
                    if let indexPath = tableView.indexPathForRow(at: longPressGestureRecognizer.location(ofTouch: 0, in: tableView)) {
                        if let cell = tableView.cellForRow(at: indexPath) as? QuoteTableViewCell {
                            if self.index == 0 {
                                optionalPopupView.isOptional = true
                            } else {
                                optionalPopupView.isOptional = false
                            }
                            optionalPopupView.instrumentId = instrumentId
                            optionalPopupView.modalPresentationStyle = .popover
                            //箭头所指向的区域
                            optionalPopupView.popoverPresentationController?.sourceView = cell
                            optionalPopupView.popoverPresentationController?.sourceRect = cell.bounds
                            //箭头方向
                            optionalPopupView.popoverPresentationController?.permittedArrowDirections = .up
                            //设置代理
                            optionalPopupView.popoverPresentationController?.delegate = self
                            //弹出框口大小
                            optionalPopupView.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 44.0)
                            self.present(optionalPopupView, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    @objc func tapUpperLimit() {
        isUpperLimit = !isUpperLimit
        tableView.reloadData()
    }

    @objc func tapChangePercent() {
        isChangePercent = !isChangePercent
        tableView.reloadData()
    }
    
    @objc func tapOpenInterest() {
        isOpenInterest = !isOpenInterest
        tableView.reloadData()
    }
    
    @objc private func refreshDatas() {
        if !isRefresh {return}
        //两个数据集的大小必须一致，否则会出错
        let count = quotes.count
        let oldQuotes = quotes
        for ins in dataManager.sRtnMD[RtnMDConstants.ins_list].stringValue.split(separator: ",") {
            let instrumentId = String(ins)
            if insList.contains(instrumentId) {
                let index = insList.index(of: instrumentId)
                let quoteJson = dataManager.sRtnMD[RtnMDConstants.quotes][instrumentId]
                if let index = index, index < count {
                    do{
                        try quotes[index].merge(with: quoteJson)
                    }catch {
                        print(error.localizedDescription)
                    }

                }
            }
        }

        //自选合约列表大小发生变化时，刷新数据源的大小
        if tableView.numberOfRows(inSection: 0) != oldQuotes.count {
            tableView.reloadData()
            return
        }
        let change = diff(old: oldQuotes, new: quotes)
        tableView.reload(changes: change, section: 0, insertionAnimation: .none, deletionAnimation: .none, replacementAnimation: .none, completion: {_ in})
    }

    @objc func initInsList(){
        if index == 0 {
            quotes = dataManager.sQuotes[self.index].map {$0.value}

            insList = dataManager.sQuotes[self.index].map {$0.key}
        }
    }
}


extension JSON: Hashable {

    public var hashValue: Int {

        if (self.dictionaryValue.map {$0.key}).contains(OrderConstants.order_id) {
            return self[OrderConstants.exchange_order_id].stringValue.hashValue
        }

        if (self.dictionaryValue.map {$0.key}).contains(TradeConstants.trade_id) {
            return self[TradeConstants.exchange_trade_id].stringValue.hashValue
        }

        if (self.dictionaryValue.map {$0.key}).contains(PositionConstants.position_profit) {
            return (self[PositionConstants.exchange_id].stringValue + "." + self[PositionConstants.instrument_id].stringValue).hashValue
        }

        if (self.dictionaryValue.map {$0.key}).contains(TransferConstants.currency) {
            return self[TransferConstants.datetime].stringValue.hashValue
        }

        if (self.dictionaryValue.map {$0.key}).contains(QuoteConstants.instrument_name) {
            return self[QuoteConstants.instrument_id].stringValue.hashValue
        }

        return self.count
    }

    static func == (lhs: JSON, rhs: JSON) -> Bool {
        if (lhs.dictionaryValue.map {$0.key}).contains(PositionConstants.position_profit) {
            return lhs[PositionConstants.exchange_id].stringValue == rhs[PositionConstants.exchange_id].stringValue && lhs[PositionConstants.instrument_id].stringValue == rhs[PositionConstants.instrument_id].stringValue && lhs[PositionConstants.volume_long_frozen_his].stringValue == rhs[PositionConstants.volume_long_frozen_his].stringValue &&
                lhs[PositionConstants.volume_long_frozen_today].stringValue == rhs[PositionConstants.volume_long_frozen_today].stringValue &&
                lhs[PositionConstants.volume_short_frozen_his].stringValue == rhs[PositionConstants.volume_short_frozen_his].stringValue &&
                lhs[PositionConstants.volume_short_frozen_today].stringValue == rhs[PositionConstants.volume_short_frozen_today].stringValue && lhs[PositionConstants.volume_long].stringValue == rhs[PositionConstants.volume_long].stringValue  && lhs[PositionConstants.open_price_long].stringValue == rhs[PositionConstants.open_price_long].stringValue && lhs[PositionConstants.float_profit_long].stringValue == rhs[PositionConstants.float_profit_long].stringValue && lhs[PositionConstants.volume_short].stringValue == rhs[PositionConstants.volume_short].stringValue && lhs[PositionConstants.open_price_short].stringValue == rhs[PositionConstants.open_price_short].stringValue && lhs[PositionConstants.float_profit_short].stringValue == rhs[PositionConstants.float_profit_short].stringValue

        }

        if (lhs.dictionaryValue.map {$0.key}).contains(OrderConstants.exchange_order_id) {
            return lhs[OrderConstants.order_id].stringValue == rhs[OrderConstants.order_id].stringValue && lhs[OrderConstants.last_msg].stringValue == rhs[OrderConstants.last_msg].stringValue && lhs[OrderConstants.status].stringValue == rhs[OrderConstants.status].stringValue && lhs[OrderConstants.volume_left].stringValue == rhs[OrderConstants.volume_left].stringValue
        }

        if (lhs.dictionaryValue.map {$0.key}).contains(QuoteConstants.lowest) {
            return lhs[QuoteConstants.last_price].stringValue == rhs[QuoteConstants.last_price].stringValue && lhs[QuoteConstants.pre_settlement].stringValue == rhs[QuoteConstants.pre_settlement].stringValue && lhs[QuoteConstants.open_interest].stringValue == rhs[QuoteConstants.open_interest].stringValue && lhs[QuoteConstants.volume].stringValue == rhs[QuoteConstants.volume].stringValue &&
                lhs[QuoteConstants.bid_price1].stringValue == rhs[QuoteConstants.bid_price1].stringValue &&
                lhs[QuoteConstants.bid_volume1].stringValue == rhs[QuoteConstants.bid_volume1].stringValue &&
                lhs[QuoteConstants.ask_price1].stringValue == rhs[QuoteConstants.ask_price1].stringValue &&
                lhs[QuoteConstants.ask_volume1].stringValue == rhs[QuoteConstants.ask_volume1].stringValue &&
                lhs[QuoteConstants.upper_limit].stringValue == rhs[QuoteConstants.upper_limit].stringValue &&
                lhs[QuoteConstants.lower_limit].stringValue == rhs[QuoteConstants.lower_limit].stringValue
        }

        return lhs.hashValue == rhs.hashValue
    }

}


