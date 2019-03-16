//
//  BaseChartViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/22.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

class BaseChartViewController: UIViewController, ChartViewDelegate {

    // MARK: Properties
    //组合图
    weak var topChartViewBase: CombinedChartView!
    weak var middleChartViewBase: CombinedChartView!
    weak var bottomChartViewBase: CombinedChartView!
    //图表背景色
    var colorChartBackground: UIColor?
    //文字颜色
    var colorText: UIColor?
    //栅格线颜色
    var colorGrid: UIColor?
    //买颜色
    var colorBuy: UIColor?
    //卖颜色
    var colorSell: UIColor?
    //跌颜色
    var decreasingColor: NSUIColor?
    //涨颜色
    var increasingColor: NSUIColor?
    //是否显示持仓线
    var isShowPositionLine = true
    //是否显示挂单线
    var isShowOrderLine = true
    //是否显示均线
    var isShowAverageLine = true
    //持仓线数据
    var positionLimitLines = [String: ChartLimitLine]()
    //持仓手数
    var positionVolumes = [String: Int]()
    //挂单数据
    var orderLimitLines = [String: ChartLimitLine]()
    //挂单手数
    var orderVolumes = [String: Int]()

    let dataManager = DataManager.getInstance()
    let calendar = Calendar.autoupdatingCurrent
    var simpleDateFormat = DateFormatter()
    var xVals = [Int: Int]()
    var klineType = ""
    var fragmentType = ""
    var topMoveGesture: UIPanGestureRecognizer!
    var middleMoveGesture: UIPanGestureRecognizer!
    var isMoveHighlight = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initChart()
        NotificationCenter.default.addObserver(self, selector: #selector(controlPositionLine), name: Notification.Name(CommonConstants.ControlPositionLineNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controlOrderLine), name: Notification.Name(CommonConstants.ControlOrderLineNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controlAverageLine), name: Notification.Name(CommonConstants.ControlAverageLineNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearChartView), name: Notification.Name(CommonConstants.ClearChartViewNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchKlineType(_:)), name: Notification.Name(CommonConstants.SwitchDurationNotification), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTradeLine), name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshKline), name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendChart), name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controlMiddleBottomChartView), name: Notification.Name(CommonConstants.ControlMiddleBottomChartViewNotification), object: nil)


        clearChartView()
        sendChart()
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.ControlMiddleBottomChartViewNotification), object: nil)
    }

    deinit {
        print("k线页销毁")
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.ControlPositionLineNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.ControlOrderLineNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.ControlAverageLineNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.ClearChartViewNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.SwitchDurationNotification), object: nil)
    }

    @objc func sendChart() {

        let instrumentId = dataManager.sInstrumentId
        if CommonConstants.CURRENT_DAY_FRAGMENT.elementsEqual(fragmentType){
            MDWebSocketUtils.getInstance().sendSetChart(insList: instrumentId)
        }else{
            MDWebSocketUtils.getInstance().sendSetChartKline(insList: instrumentId, klineType: self.klineType, viewWidth: CommonConstants.VIEW_WIDTH)
        }
    }

    @objc func controlMiddleBottomChartView() {

        if middleChartViewBase.isHidden{
            middleChartViewBase.isHidden = false
        }else{
            middleChartViewBase.isHidden = true
        }

//        if bottomChartViewBase.isHidden{
//            bottomChartViewBase.isHidden = false
//        }else{
//            bottomChartViewBase.isHidden = true
//        }

    }

    // MARK: functions
    func initChart() {
        colorChartBackground = UIColor.black
        colorText = UIColor.white
        colorGrid = CommonConstants.KLINE_GRID
        colorSell = CommonConstants.KLINE_PO_LINE_SELL
        colorBuy = CommonConstants.KLINE_PO_LINE_BUY
        decreasingColor = UIColor(red: 0.0, green: 252.0/255.0, blue: 252.0/255.0, alpha: 1)
        increasingColor = UIColor(red: 218.0/255.0, green: 0.0, blue: 0.0, alpha: 1)
        topChartViewBase.delegate = self
        topChartViewBase.chartDescription?.enabled = false
        topChartViewBase.drawValueAboveBarEnabled = false
        topChartViewBase.autoScaleMinMaxEnabled = true
        topChartViewBase.dragEnabled = true
        topChartViewBase.doubleTapToZoomEnabled = false
        topChartViewBase.highlightPerTapEnabled = false
        topChartViewBase.highlightPerDragEnabled = false
        topChartViewBase.drawBordersEnabled = true
        topChartViewBase.borderLineWidth = 0.5
        topChartViewBase.borderColor = colorGrid!
        topChartViewBase.setViewPortOffsets(left: 0, top: 15, right: 0, bottom: 0)
        topChartViewBase.noDataText = "数据申请中"

        middleChartViewBase.delegate = self
        middleChartViewBase.chartDescription?.enabled = false
        middleChartViewBase.drawValueAboveBarEnabled = false
        middleChartViewBase.autoScaleMinMaxEnabled = true
        middleChartViewBase.dragEnabled = true
        middleChartViewBase.doubleTapToZoomEnabled = false
        middleChartViewBase.highlightPerTapEnabled = false
        middleChartViewBase.highlightPerDragEnabled = false
        middleChartViewBase.drawBordersEnabled = false
        middleChartViewBase.borderColor = colorGrid!
        middleChartViewBase.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 15)
        middleChartViewBase.noDataText = "数据申请中"
        
        bottomChartViewBase.delegate = self
        bottomChartViewBase.chartDescription?.enabled = false
        bottomChartViewBase.drawValueAboveBarEnabled = false
        bottomChartViewBase.autoScaleMinMaxEnabled = true
        bottomChartViewBase.dragEnabled = true
        bottomChartViewBase.doubleTapToZoomEnabled = false
        bottomChartViewBase.highlightPerTapEnabled = false
        bottomChartViewBase.highlightPerDragEnabled = false
        bottomChartViewBase.drawBordersEnabled = false
        bottomChartViewBase.borderColor = colorGrid!
        bottomChartViewBase.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 15)
        bottomChartViewBase.noDataText = "数据申请中"

        topMoveGesture = UIPanGestureRecognizer(target: self, action: #selector(topMovePan(gesture:)))
        middleMoveGesture = UIPanGestureRecognizer(target: self, action: #selector(middleMovePan(gesture:)))

        let longPressGestureTop = UILongPressGestureRecognizer(target: self, action: #selector(longPressDetectedTop(gesture:)))
        topChartViewBase.addGestureRecognizer(longPressGestureTop)

        let longPressGestureMiddle = UILongPressGestureRecognizer(target: self, action: #selector(longPressDetectedMiddle(gesture:)))
        middleChartViewBase.addGestureRecognizer(longPressGestureMiddle)

        //        let longPressGestureBottom = UILongPressGestureRecognizer(target: self, action: #selector(longPressDetectedBottom(gesture:)))
        //        longPressGestureBottom.allowableMovement = 50
        //        bottomChartViewBase.addGestureRecognizer(longPressGestureBottom)

        let tapGestureTop = UITapGestureRecognizer(target: self, action: #selector(tapDetectedTop(gesture:)))
        topChartViewBase.addGestureRecognizer(tapGestureTop)

        let tapGestureMiddle = UITapGestureRecognizer(target: self, action: #selector(tapDetectedMiddle(gesture:)))
        middleChartViewBase.addGestureRecognizer(tapGestureMiddle)

        //        let tapGestureBottom = UITapGestureRecognizer(target: self, action: #selector(tapDetectedBottom(gesture:)))
        //        bottomChartViewBase.addGestureRecognizer(tapGestureBottom)

        isShowOrderLine = UserDefaults.standard.bool(forKey: "orderLine")
        isShowPositionLine = UserDefaults.standard.bool(forKey: "positionLine")

        if dataManager.sIsLogin {
            if isShowPositionLine {
                addPositionLimitLines()
            }
            if isShowOrderLine {
                addOrderLimitLines()
            }
        }

        //切换k线周期时保持图表显示隐藏状态
        if dataManager.isShowDownStack {
            middleChartViewBase.isHidden = true
//            bottomChartViewBase.isHidden = true
        }else{
            middleChartViewBase.isHidden = false
//            bottomChartViewBase.isHidden = false
        }

    }

    //持仓线增删操作
    func addPositionLimitLines() {
        addLongPositionLimitLine()
        addShortPositionLimitLine()
    }

    func generatePositionLimitLine(limit: String, label: String, color: UIColor, limitKey: String, volume: Int) {
        if let limit = Double(limit) {
            let chartLimitLine = ChartLimitLine(limit: limit, label: label)
            chartLimitLine.lineWidth = 0.7
            chartLimitLine.lineDashLengths = [5.0, 5.0]
            chartLimitLine.lineDashPhase = 0.0
            chartLimitLine.lineColor = color
            chartLimitLine.labelPosition = .leftBottom
            chartLimitLine.valueFont = UIFont.systemFont(ofSize: 10.0)
            chartLimitLine.valueTextColor = colorText!
            positionLimitLines[limitKey] = chartLimitLine
            positionVolumes[limitKey] = volume
            topChartViewBase.leftAxis.addLimitLine(chartLimitLine)
        }
    }

    func addLongPositionLimitLine() {
        var key = dataManager.sInstrumentId
        if key.contains("KQ") {
            key = (dataManager.sSearchEntities[key]?.underlying_symbol)!
        }

        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        guard let position = user.positions[key] else {return}
        let volume_long = (position.volume_long as? Int) ?? 0
        if volume_long != 0 {
            let limit_long =  "\(position.open_price_long ?? 0.0)"
            let p_decs = dataManager.getDecimalByPtick(instrumentId: key)
            let limit_long_p = dataManager.saveDecimalByPtick(decimal: p_decs, data: limit_long)
            let label_long = "\(position.instrument_id ?? "")@\(limit_long_p)/\(volume_long)手"
            generatePositionLimitLine(limit: limit_long_p, label: label_long, color: colorBuy!, limitKey: key + "0", volume: volume_long)
        }
    }

    func addShortPositionLimitLine() {
        var key = dataManager.sInstrumentId
        if key.contains("KQ") {
            key = (dataManager.sSearchEntities[key]?.underlying_symbol)!
        }

        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        guard let position = user.positions[key] else {return}
        let volume_short = (position.volume_short as? Int) ?? 0
        if volume_short != 0 {
            let limit_short = "\(position.open_price_short ?? 0.0)"
            let p_decs = dataManager.getDecimalByPtick(instrumentId: key)
            let limit_short_p = dataManager.saveDecimalByPtick(decimal: p_decs, data: limit_short)
            let label_short = "\(position.instrument_id ?? "")@\(limit_short_p)/\(volume_short)手"
            generatePositionLimitLine(limit: limit_short_p, label: label_short, color: colorSell!, limitKey: key + "1", volume: volume_short)
        }
    }

    func refreshLongPositionLimitLine() {
        var key = dataManager.sInstrumentId
        if key.contains("KQ") {
            key = (dataManager.sSearchEntities[key]?.underlying_symbol)!
        }

        let limitKey = key + "0"
        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        guard let position = user.positions[key] else {return}
        let volume_long = (position.volume_long as? Int) ?? 0
        guard let limitLine = positionLimitLines[limitKey] else {return}
        if volume_long != 0 {
            let limit_long = "\(position.open_price_long ?? 0.0)"
            let p_decs = dataManager.getDecimalByPtick(instrumentId: key)
            let limit_long_p = dataManager.saveDecimalByPtick(decimal: p_decs, data: limit_long)
            guard let limit_long_p_d = Double(limit_long_p) else{return}

            guard let volume_long_l = positionVolumes[limitKey] else {return}
            if limitLine.limit != limit_long_p_d || volume_long != volume_long_l {
                let label_long = "\(position.instrument_id ?? "")@\(limit_long_p)/\(volume_long)手"
                topChartViewBase.leftAxis.removeLimitLine(limitLine)
                generatePositionLimitLine(limit: limit_long_p, label: label_long, color: colorBuy!, limitKey: limitKey, volume: volume_long)
            }
        } else {
            topChartViewBase.leftAxis.removeLimitLine(limitLine)
            positionLimitLines.removeValue(forKey: limitKey)
            positionVolumes.removeValue(forKey: limitKey)
        }

    }

    func refreshShortPositionLimitLine() {
        var key = dataManager.sInstrumentId
        if key.contains("KQ") {
            key = (dataManager.sSearchEntities[key]?.underlying_symbol)!
        }

        let limitKey = key + "1"
        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        guard let position = user.positions[key] else {return}
        let volume_short = (position.volume_short as? Int) ?? 0
        guard let limitLine = positionLimitLines[limitKey] else {return}
        if volume_short != 0 {
            let limit_short = "\(position.open_price_short ?? 0.0)"
            let p_decs = dataManager.getDecimalByPtick(instrumentId: key)
            let limit_short_p = dataManager.saveDecimalByPtick(decimal: p_decs, data: limit_short)
            guard let limit_short_p_d = Double(limit_short_p) else{return}
            guard let volume_short_l = positionVolumes[limitKey] else {return}
            if limitLine.limit != limit_short_p_d || volume_short != volume_short_l{
                let label_short = "\(position.instrument_id ?? "")@\(limit_short_p)/\(volume_short)手"
                topChartViewBase.leftAxis.removeLimitLine(limitLine)
                generatePositionLimitLine(limit: limit_short_p, label: label_short, color: colorSell!, limitKey: limitKey, volume: volume_short)
            }
        } else {
            topChartViewBase.leftAxis.removeLimitLine(limitLine)
            positionLimitLines.removeValue(forKey: limitKey)
            positionVolumes.removeValue(forKey: limitKey)
        }
    }

    func removePositionLimitLines() {
        if positionLimitLines.isEmpty {return}
        for value in positionLimitLines.map({$0.value}) {
            topChartViewBase.leftAxis.removeLimitLine(value)
        }
        positionLimitLines.removeAll()
        positionVolumes.removeAll()
    }

    //挂单线增删操作
    func addOrderLimitLines() {
        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        let orders = user.orders
        if orders.isEmpty{return}
        for orderEntity in orders.map({$0.value}) {
            let instrumentId = "\(orderEntity.exchange_id ?? "")" + "." + "\(orderEntity.instrument_id ?? "")"
            let status = "\(orderEntity.status ?? "")"
            var ins = dataManager.sInstrumentId
            if ins.contains("KQ") {
                ins = (dataManager.sSearchEntities[ins]?.underlying_symbol)!
            }
            if instrumentId.elementsEqual(ins) && "ALIVE".elementsEqual(status) {
                addOneOrderLimitLine(orderEntity: orderEntity)
            }
        }
    }

    func removeOrderLimitLines() {
        if orderLimitLines.isEmpty {return}
        for key in orderLimitLines.map({$0.key}) {
            removeOneOrderLimitLine(key: key)
        }
    }

    private func addOneOrderLimitLine(orderEntity: Order) {
        let direction = "\(orderEntity.direction ?? "")"
        let p_decs = dataManager.getDecimalByPtick(instrumentId: dataManager.sInstrumentId)
        let price = dataManager.saveDecimalByPtick(decimal: p_decs, data: "\(orderEntity.limit_price ?? 0.0)")
        let order_id = "\(orderEntity.order_id ?? "")"
        let instrument_id = "\(orderEntity.instrument_id ?? "")"
        let volume = (orderEntity.volume_orign as? Int) ?? 0
        let limit = Double(price)!
        let label = "\(instrument_id)@\(price)/\(volume)手"
        let chartLimitLine = ChartLimitLine(limit: limit, label: label)
        orderLimitLines[order_id] = chartLimitLine
        orderVolumes[order_id] = volume
        chartLimitLine.lineWidth = 0.7
        if "BUY".elementsEqual(direction) {
            chartLimitLine.lineColor = colorBuy!
        } else {
            chartLimitLine.lineColor = colorSell!
        }
        chartLimitLine.labelPosition = .leftBottom
        chartLimitLine.valueFont = UIFont.systemFont(ofSize: 10.0)
        chartLimitLine.valueTextColor = colorText!
        topChartViewBase.leftAxis.addLimitLine(chartLimitLine)
    }

    private func removeOneOrderLimitLine(key: String) {
        let limitLine = orderLimitLines[key]!
        topChartViewBase.leftAxis.removeLimitLine(limitLine)
        orderLimitLines.removeValue(forKey: key)
        orderVolumes.removeValue(forKey: key)
    }

    // MARK: objc methods
    @objc func refreshTradeLine() {
        if dataManager.sIsLogin && isShowPositionLine {
            var key = dataManager.sInstrumentId
            if key.contains("KQ") {
                key = (dataManager.sSearchEntities[key]?.underlying_symbol)!
            }
            let position0 = positionLimitLines[key + "0"]
            let position1 = positionLimitLines[key + "1"]
            if position0 == nil {
                //添加多头持仓
                addLongPositionLimitLine()
            } else {
                //刷新多头持仓
                refreshLongPositionLimitLine()
            }

            if position1 == nil {
                //添加空头持仓
                addShortPositionLimitLine()
            } else {
                //刷新空头持仓
                refreshShortPositionLimitLine()
            }
        }

        if dataManager.sIsLogin && isShowOrderLine {
            guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
            let orders = user.orders
            for (orderId, orderEntity)in orders{
                let instrumentId = "\(orderEntity.exchange_id ?? "")" + "." + "\(orderEntity.instrument_id ?? "")"
                var ins = dataManager.sInstrumentId
                if ins.contains("KQ") {
                    ins = (dataManager.sSearchEntities[ins]?.underlying_symbol)!
                }
                if instrumentId.elementsEqual(ins) {
                    let status = "\(orderEntity.status ?? "")"
                    let limitLine = orderLimitLines[orderId]
                    if limitLine ==  nil {
                        if "ALIVE".elementsEqual(status) {
                            addOneOrderLimitLine(orderEntity: orderEntity)
                        }
                    } else {
                        if "FINISHED".elementsEqual(status) {
                            removeOneOrderLimitLine(key: orderId)
                        }
                    }

                }
            }
        }
    }

    //控制持仓线显示与否
    @objc private func controlPositionLine(notification: Notification) {
        isShowPositionLine = notification.object as! Bool
        if !dataManager.sIsLogin {return}
        if isShowPositionLine {
            addPositionLimitLines()
        } else {
            removePositionLimitLines()
        }
        topChartViewBase.combinedData?.notifyDataChanged()
        topChartViewBase.setNeedsDisplay()
    }

    //控制挂单线显示与否
    @objc private func controlOrderLine(notification: Notification) {
        isShowOrderLine = notification.object as! Bool
        if !dataManager.sIsLogin {return}
        if isShowOrderLine {
            addOrderLimitLines()
        } else {
            removeOrderLimitLines()
        }
        topChartViewBase.combinedData?.notifyDataChanged()
        topChartViewBase.setNeedsDisplay()
    }

    //控制均线显示与否
    @objc func controlAverageLine(notification: Notification){

    }

    @objc func refreshKline() {

    }

    //删除所有K线图
    @objc func clearChartView(){
        xVals.removeAll()
        removeLatestLine()
        removeOrderLimitLines()
        removePositionLimitLines()
        topChartViewBase.clear()
        middleChartViewBase.clear()

        if dataManager.sIsLogin {
            if isShowPositionLine {
                addPositionLimitLines()
            }
            if isShowOrderLine {
                addOrderLimitLines()
            }
        }

    }

    //相同页下切换K线周期
    @objc func switchKlineType(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary? {
            if let fragmentType = dict["fragmentType"] as? String{
                if fragmentType.elementsEqual(self.fragmentType){
                    clearChartView()
                    sendChart()
                }
            }
        }
    }

    //移除最新价线
    @objc func removeLatestLine(){

    }

    //长按显示十字光标
    @objc func longPressDetectedTop(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self.topChartViewBase)
        if gesture.state == .began{
            guard let h_top = self.topChartViewBase.getHighlightByTouchPoint(point) else {return}
            h_top.setDraw(pt: point)
            self.topChartViewBase.highlightValue(h_top)
            highlight()
            topChartValueSelected(h_top: h_top)
        }else{
            topMove(point: point)
        }

    }

    @objc func longPressDetectedMiddle(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self.middleChartViewBase)
        if gesture.state == .began {
            guard let h_middle = self.middleChartViewBase.getHighlightByTouchPoint(point)else {return}
            h_middle.setDraw(pt: point)
            self.middleChartViewBase.highlightValue(h_middle)
            highlight()
            middleChartValueSelected(h_middle: h_middle)
        }else{
            middleMove(point: point)
        }

    }

    //单击隐藏十字光标
    @objc func tapDetectedTop(gesture: UITapGestureRecognizer) {
        self.topChartViewBase.highlightValue(nil)
        self.middleChartViewBase.highlightValue(nil)
        unHighlight()
    }

    @objc func tapDetectedMiddle(gesture: UITapGestureRecognizer) {
        self.topChartViewBase.highlightValue(nil)
        self.middleChartViewBase.highlightValue(nil)
        unHighlight()
    }

    //拖动十字光标
    @objc func topMovePan(gesture: UIPanGestureRecognizer){
        if isMoveHighlight {
            let position = gesture.location(in: self.topChartViewBase)
            topMove(point: position)
        }
    }

    @objc func middleMovePan(gesture: UIPanGestureRecognizer){
        if isMoveHighlight {
            let position = gesture.location(in: self.middleChartViewBase)
            middleMove(point: position)
        }
    }

    //高亮状态
    func highlight() {
        isMoveHighlight = true
        topChartViewBase.dragEnabled = false
        middleChartViewBase.dragEnabled = false
        topChartViewBase.addGestureRecognizer(topMoveGesture)
        middleChartViewBase.addGestureRecognizer(middleMoveGesture)
    }

    //非高亮状态
    func unHighlight() {
        topChartViewBase.dragEnabled = true
        middleChartViewBase.dragEnabled = true
        isMoveHighlight = false
        topChartViewBase.removeGestureRecognizer(topMoveGesture)
        middleChartViewBase.removeGestureRecognizer(middleMoveGesture)
    }

    //topChart高亮回调
    func topChartValueSelected(h_top: Highlight) {
        let transformer = topChartViewBase.getTransformer(forAxis: .left)
        let yMaxValue = topChartViewBase.chartYMax
        let yMinValue = topChartViewBase.chartYMin
        let xValue = h_top.x
        let yMin = transformer.pixelForValues(x: xValue, y: yMaxValue).y
        let yMax = transformer.pixelForValues(x: xValue, y: yMinValue).y
        let yMaxValue_f = CGFloat(yMaxValue)
        let yMinValue_f = CGFloat(yMinValue)
        let xValue_f = CGFloat(xValue)
        let touchY = h_top.drawY
        let yData = (yMax - touchY) / (yMax - yMin) * (yMaxValue_f - yMinValue_f) + yMinValue_f
        dataManager.yData = dataManager.saveDecimalByPtick(decimal: dataManager.getDecimalByPtick(instrumentId: dataManager.sInstrumentId), data: "\(yData)")
        let y = touchY - topChartViewBase.viewPortHandler.chartHeight
        let h_middle = middleChartViewBase.getHighlightByTouchPoint(CGPoint(x: h_top.xPx, y: 0))
        h_middle?.setDraw(x: xValue_f, y: y)
        middleChartViewBase.highlightValue(h_middle)
    }

    //middleChart高亮回调
    func middleChartValueSelected(h_middle: Highlight) {
        let transformer = middleChartViewBase.getTransformer(forAxis: .left)
        let yMaxValue = middleChartViewBase.chartYMax
        let xValue = h_middle.x
        let yMin = transformer.pixelForValues(x: xValue, y: yMaxValue).y
        let yMax = transformer.pixelForValues(x: xValue, y: 0).y
        let yMaxValue_f = CGFloat(yMaxValue)
        let xValue_f = CGFloat(xValue)
        let touchY = h_middle.drawY
        let yData = Int((yMax - touchY) / (yMax - yMin) * yMaxValue_f)
        dataManager.yData = "\(yData)"
        let y = touchY + topChartViewBase.viewPortHandler.chartHeight
        let h_top = topChartViewBase.getHighlightByTouchPoint(CGPoint(x: h_middle.xPx, y: topChartViewBase.viewPortHandler.contentHeight / 2))
        h_top?.setDraw(x: xValue_f, y: y)
        topChartViewBase.highlightValue(h_top)
    }

    //topChart滑动
    func topMove(point: CGPoint) {
        var position = point
        var y = position.y
        let offset = topChartViewBase.viewPortHandler.contentHeight
        if position.y > topChartViewBase.viewPortHandler.chartHeight{
            if y > offset { y = y - offset}
            position.y = y
            guard let h_middle = middleChartViewBase.getHighlightByTouchPoint(position) else {return}
            h_middle.setDraw(pt: position)
            middleChartViewBase.highlightValue(h_middle)
            middleChartValueSelected(h_middle: h_middle)
        }else{
            if y < 0 { y = y + offset}
            position.y = y
            guard let h_top = topChartViewBase.getHighlightByTouchPoint(position) else {return}
            h_top.setDraw(pt: position)
            topChartViewBase.highlightValue(h_top)
            topChartValueSelected(h_top: h_top)
        }
    }

     //middleChart滑动
    func middleMove(point: CGPoint) {
        var position = point
        var y = position.y
        let offset = topChartViewBase.viewPortHandler.contentHeight
        if position.y < 0 {
            if y < 0 { y = y + offset}
            position.y = y
            guard let h_top = topChartViewBase.getHighlightByTouchPoint(position) else {return}
            h_top.setDraw(pt: position)
            topChartViewBase.highlightValue(h_top)
            topChartValueSelected(h_top: h_top)
        }else {
            if y > offset { y = y - offset}
            position.y = y
            guard let h_middle = middleChartViewBase.getHighlightByTouchPoint(position) else {return}
            h_middle.setDraw(pt: position)
            middleChartViewBase.highlightValue(h_middle)
            middleChartValueSelected(h_middle: h_middle)
        }
    }
}
