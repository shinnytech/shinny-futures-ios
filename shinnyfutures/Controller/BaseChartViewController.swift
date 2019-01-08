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
    weak var chartView: CombinedChartView!
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
    var doubleTap: UITapGestureRecognizer!
    var singleTap: UITapGestureRecognizer!

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

        clearChartView()
        sendChart()
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
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
            switch fragmentType {
            case CommonConstants.DAY_FRAGMENT:
                if let klineType = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_KLINE_DAY_TYPE){
                    self.klineType = klineType
                }
            case CommonConstants.HOUR_FRAGMENT:
                if let klineType = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_KLINE_HOUR_TYPE){
                    self.klineType = klineType
                }
            case CommonConstants.MINUTE_FRAGMENT:
                if let klineType = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_KLINE_MINUTE_TYPE){
                    self.klineType = klineType
                }
            case CommonConstants.SECOND_FRAGMENT:
                if let klineType = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_KLINE_SECOND_TYPE){
                    self.klineType = klineType
                }
            default:
                break
            }
            print(self.klineType)
            MDWebSocketUtils.getInstance().sendSetChartKline(insList: instrumentId, klineType: self.klineType, viewWidth: CommonConstants.VIEW_WIDTH)
        }
    }

    // MARK: functions
    func initChart() {
        colorChartBackground = UIColor.black
        colorText = UIColor.white
        colorGrid = CommonConstants.KLINE_GRID
        colorSell = CommonConstants.KLINE_PO_LINE_SELL
        colorBuy = CommonConstants.KLINE_PO_LINE_BUY
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.autoScaleMinMaxEnabled = true
        chartView.dragEnabled = true
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.drawBordersEnabled = true
        chartView.borderColor = colorGrid!
        chartView.setViewPortOffsets(left: 0, top: 15, right: 0, bottom: 15)

        singleTap = UITapGestureRecognizer(target: self, action: #selector(Unhighlight))
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(highlight))
        doubleTap.numberOfTapsRequired = 2
        chartView.addGestureRecognizer(doubleTap)

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
            chartLimitLine.lineDashLengths = [10.0, 10.0]
            chartLimitLine.lineDashPhase = 0.0
            chartLimitLine.lineColor = color
            chartLimitLine.labelPosition = .leftBottom
            chartLimitLine.valueFont = UIFont.systemFont(ofSize: 10.0)
            chartLimitLine.valueTextColor = colorText!
            positionLimitLines[limitKey] = chartLimitLine
            positionVolumes[limitKey] = volume
            chartView.leftAxis.addLimitLine(chartLimitLine)
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
                chartView.leftAxis.removeLimitLine(limitLine)
                generatePositionLimitLine(limit: limit_long_p, label: label_long, color: colorBuy!, limitKey: limitKey, volume: volume_long)
            }
        } else {
            chartView.leftAxis.removeLimitLine(limitLine)
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
                chartView.leftAxis.removeLimitLine(limitLine)
                generatePositionLimitLine(limit: limit_short_p, label: label_short, color: colorSell!, limitKey: limitKey, volume: volume_short)
            }
        } else {
            chartView.leftAxis.removeLimitLine(limitLine)
            positionLimitLines.removeValue(forKey: limitKey)
            positionVolumes.removeValue(forKey: limitKey)
        }
    }

    func removePositionLimitLines() {
        if positionLimitLines.isEmpty {return}
        for value in positionLimitLines.map({$0.value}) {
            chartView.leftAxis.removeLimitLine(value)
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
        chartView.leftAxis.addLimitLine(chartLimitLine)
    }

    private func removeOneOrderLimitLine(key: String) {
        let limitLine = orderLimitLines[key]!
        chartView.leftAxis.removeLimitLine(limitLine)
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
        chartView.combinedData?.notifyDataChanged()
        chartView.setNeedsDisplay()
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
        chartView.combinedData?.notifyDataChanged()
        chartView.setNeedsDisplay()
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
        chartView.clear()

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
            if let index = dict["durationIndex"] as? Int, let fragmentType = dict["fragmentType"] as? String{
                let klineType = CommonConstants.klineDuration[index]
                if fragmentType.elementsEqual(self.fragmentType) && !self.klineType.elementsEqual(klineType){
                    self.klineType = klineType
                    clearChartView()
                    sendChart()
                }
            }
        }
    }

    //隐藏十字光标
    @objc func Unhighlight(){
        
    }

    //显示十字光标
    @objc func highlight(){

    }

    //移除最新价线
    @objc func removeLatestLine(){

    }
}
