//
//  QuoteTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/26.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import DeepDiff

class QuoteTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: Properties
    let dataManager = DataManager.getInstance()
    //用来控制标题
    var index = 1
    var isChangePercent = true
    var isOpenInterest = true
    var isRefresh = true
    var quotes = [Quote]()
    var oldQuotes = [Quote]()
    var insList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // make tableview look better in ipad
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()

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
        let instrumentId = quote.instrument_id as? String ?? ""
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)
        if let insturmentName = dataManager.sSearchEntities[instrumentId]?.instrument_name{
            cell.name.text = insturmentName
        }else{
            cell.name.text = instrumentId
        }

        let last = "\(quote.last_price ?? "-")"
        cell.last.text = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(last)")
        let pre_settlement = "\(quote.pre_settlement ?? "-")"

        if self.index == 7 || self.index == 8{
            if let last = Float(last), let pre_settlement = Float(pre_settlement){
                let change = last - pre_settlement
                if change < 0 {
                    cell.last.textColor = CommonConstants.GREEN_TEXT
                } else if change > 0{
                    cell.last.textColor = CommonConstants.RED_TEXT
                }else {
                    cell.last.textColor = CommonConstants.WHITE_TEXT
                }
                
            }else{
                cell.last.textColor = CommonConstants.WHITE_TEXT
            }

            if isChangePercent {
                let bid_price1 = "\(quote.bid_price1 ?? "-")"
                cell.changePercent.text = dataManager.saveDecimalByPtick(decimal: decimal, data: bid_price1)
                if let bid_price1_f = Float(bid_price1), let pre_settlement = Float(pre_settlement){
                    let change = bid_price1_f - pre_settlement
                    if change < 0 {
                        cell.changePercent.textColor = CommonConstants.GREEN_TEXT
                    } else if change > 0{
                        cell.changePercent.textColor = CommonConstants.RED_TEXT
                    }else {
                        cell.changePercent.textColor = CommonConstants.WHITE_TEXT
                    }
                }else{
                    cell.changePercent.textColor = CommonConstants.WHITE_TEXT
                }
            } else {
                let ask_price1 = "\(quote.ask_price1 ?? "-")"
                cell.changePercent.text = dataManager.saveDecimalByPtick(decimal: decimal, data: ask_price1)
                if let ask_price1_f = Float(ask_price1), let pre_settlement = Float(pre_settlement){
                    let change = ask_price1_f - pre_settlement
                    if change < 0 {
                        cell.changePercent.textColor = CommonConstants.GREEN_TEXT
                    } else if change > 0{
                        cell.changePercent.textColor = CommonConstants.RED_TEXT
                    }else {
                        cell.changePercent.textColor = CommonConstants.WHITE_TEXT
                    }
                }else {
                    cell.changePercent.textColor = CommonConstants.WHITE_TEXT
                }
            }

            if isOpenInterest {
                cell.openInterest.text = "\(quote.bid_volume1 ?? "-")"
            } else {
                cell.openInterest.text = "\(quote.ask_volume1 ?? "-")"
            }

        } else {
            if let last = Float(last), let pre_settlement = Float(pre_settlement){
                let change = last - pre_settlement
                if change < 0 {
                    cell.last.textColor = CommonConstants.GREEN_TEXT
                    cell.changePercent.textColor = CommonConstants.GREEN_TEXT
                } else if change > 0{
                    cell.last.textColor = CommonConstants.RED_TEXT
                    cell.changePercent.textColor = CommonConstants.RED_TEXT
                }else {
                    cell.last.textColor = CommonConstants.WHITE_TEXT
                    cell.changePercent.textColor = CommonConstants.WHITE_TEXT
                }

                if isChangePercent {
                    let change_percent = pre_settlement == 0 ? 0 : change / pre_settlement * 100
                    cell.changePercent.text = dataManager.saveDecimalByPtick(decimal: 2, data: "\(change_percent)")
                } else {
                    cell.changePercent.text = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(change)")
                }

            }else{
                cell.last.textColor = CommonConstants.WHITE_TEXT
                cell.changePercent.text = "-"
                cell.changePercent.textColor = CommonConstants.WHITE_TEXT
            }

            if isOpenInterest {
                cell.openInterest.text = "\(quote.open_interest ?? "-")"
            } else {
                cell.openInterest.text = "\(quote.volume ?? "-")"
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
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35.0))
        headerView.backgroundColor = CommonConstants.QUOTE_TABLE_HEADER_2
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width - 10, height: 35.0))
        stackView.distribution = .fillEqually
        let name = UILabel()
        name.textColor = UIColor.white
        name.text = "合约名称"
        name.textAlignment = .center
        name.backgroundColor = CommonConstants.QUOTE_TABLE_HEADER_1
        let last = UILabel()
        last.textColor = UIColor.white
        last.textAlignment = .right
        last.backgroundColor = CommonConstants.QUOTE_TABLE_HEADER_1

        let changePercent = UILabel()
        changePercent.textColor = UIColor.white
        changePercent.backgroundColor = CommonConstants.QUOTE_TABLE_HEADER_2
        changePercent.textAlignment = .right
        let tapChangePercent = UITapGestureRecognizer(target: self, action: #selector(QuoteTableViewController.tapChangePercent))
        changePercent.isUserInteractionEnabled = true
        changePercent.addGestureRecognizer(tapChangePercent)

        let openInterest = UILabel()
        openInterest.backgroundColor = CommonConstants.QUOTE_TABLE_HEADER_2
        openInterest.textColor = UIColor.white
        openInterest.textAlignment = .right
        let tapOpenInterest = UITapGestureRecognizer(target: self, action: #selector(QuoteTableViewController.tapOpenInterest))
        openInterest.isUserInteractionEnabled = true
        openInterest.addGestureRecognizer(tapOpenInterest)

        last.text = "最新价"
        if index == 7 || index == 8 {

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
        return 35.0
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
            DataManager.getInstance().sToQuoteTarget = ""
            let instrumentId = insList[indexPath.row]
            DataManager.getInstance().sPreInsList = dataManager.sRtnMD.ins_list
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
                sendInsList(data: getInsList(data: insList, firstIndex: firstIndex, lastIndex: lastIndex))
            }else{
                //当自选合约列表从无到有，从主力合约滑动过来时，虽然indexPaths.count==0，但是需要重新加载合约列表，订阅刚添加的合约行情
                sendInsList(data: getInsList(data: insList, firstIndex: 0, lastIndex: CommonConstants.MAX_SUBSCRIBE_QUOTES))
            }
        } else {
            //导航栏切换页面时订阅
            sendInsList(data: getInsList(data: insList, firstIndex: 0, lastIndex: CommonConstants.MAX_SUBSCRIBE_QUOTES))
        }
    }

    //发送订阅合约
    private func sendInsList(data: [String]){
        var insList = data
        if index == 7 || index == 8 || index == 0{
            insList = dataManager.getCombineInsList(data: data)
        }
        let ins = insList[0..<insList.count].joined(separator: ",")
        if !ins.elementsEqual(dataManager.sRtnMD.ins_list) {
            MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: ins)
        }
    }

    private func getInsList(data: [String], firstIndex: Int, lastIndex: Int) -> [String] {
        if data.count < lastIndex {
            if firstIndex == 0{
                return data
            }else {
                return Array(data[firstIndex..<data.count])
            }
        }else{
            return Array(data[firstIndex..<lastIndex])
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
        oldQuotes = quotes
        let count = quotes.count
        for ins in dataManager.sRtnMD.ins_list.split(separator: ",") {
            let instrumentId = String(ins)
            if insList.contains(instrumentId) {
                let index = insList.index(of: instrumentId)
                let quote = dataManager.sRtnMD.quotes[instrumentId]
                if let index = index, let quote = quote, index < count {
                    var quote_copy = quote.copy() as! Quote
                    if self.index == 7 || self.index == 8 || self.index == 0{
                        if instrumentId.contains("&") && instrumentId.contains(" "){
                            quote_copy = dataManager.calculateCombineQuotePart(quote: quote_copy)
                        }
                    }
                    quotes[index] = quote_copy
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

    @IBAction func searchViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从搜索页来～")
        if index == 0 {
            quotes = dataManager.sQuotes[self.index].map {$0.value}
            insList = dataManager.sQuotes[self.index].map {$0.key}
            sendSubscribeQuotes()
        }

    }

}


