//
//  BaseChartViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/22.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON

class BaseChartViewController: UIViewController, ChartViewDelegate {

    // MARK: Properties
    //组合图
    weak var chartView: CombinedChartView!
    //图表背景色
    var colorChartBackground: UIColor?
    //轴线颜色
    var colorAxis: UIColor?
    //文字颜色
    var colorText: UIColor?
    //栅格线颜色
    var colorGrid: UIColor?
    //买颜色
    var colorBuy: UIColor?
    //卖颜色
    var colorSell: UIColor?
    //是否显示持仓线
    var isShowPositionLine = false
    //是否显示挂单线
    var isShowOrderLine = false
    //是否显示均线
    var isShowAverageLine = false
    //持仓线数据
    var positionLimitLines = [String: ChartLimitLine]()
    //挂单数据
    var orderLimitLines = [String: ChartLimitLine]()

    let dataManager = DataManager.getInstance()
    var preSettlement = 0.0
    let calendar = Calendar.autoupdatingCurrent
    var simpleDateFormat = DateFormatter()
    var xVals = [Int: Int]()
    var dataEntities = [String: JSON]()
    var klineType = ""
    var doubleTap: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        initChart()
        NotificationCenter.default.addObserver(self, selector: #selector(controlPositionLine), name: Notification.Name(CommonConstants.ControlPositionLineNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controlOrderLine), name: Notification.Name(CommonConstants.ControlOrderLineNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controlAverageLine), name: Notification.Name(CommonConstants.ControlAverageLineNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearChartView), name: Notification.Name(CommonConstants.ClearChartViewNotification), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshPage()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshPositionLine), name: Notification.Name(CommonConstants.PositionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshOrderLine), name: Notification.Name(CommonConstants.OrderNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshKline), name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendChart), name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        cancelChart()

        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.PositionNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.OrderNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
    }

    deinit {
        print("k线页销毁")
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.ControlPositionLineNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.ControlOrderLineNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.ControlAverageLineNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CommonConstants.ClearChartViewNotification), object: nil)
    }

    @objc func sendChart() {
        let instrumentId = dataManager.sInstrumentId
        switch klineType {
        case CommonConstants.CURRENT_DAY:
            MDWebSocketUtils.getInstance().sendSetChart(insList: instrumentId)
        case CommonConstants.KLINE_DAY:
            MDWebSocketUtils.getInstance().sendSetChartDay(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
        case CommonConstants.KLINE_HOUR:
            MDWebSocketUtils.getInstance().sendSetChartHour(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
        case CommonConstants.KLINE_MINUTE:
            MDWebSocketUtils.getInstance().sendSetChartMinute(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
        default:
            break
        }
    }

    func cancelChart() {
        switch klineType {
        case CommonConstants.CURRENT_DAY:
            MDWebSocketUtils.getInstance().sendSetChart(insList: "")
        case CommonConstants.KLINE_DAY:
            MDWebSocketUtils.getInstance().sendSetChartDay(insList: "", viewWidth: CommonConstants.VIEW_WIDTH)
        case CommonConstants.KLINE_HOUR:
            MDWebSocketUtils.getInstance().sendSetChartHour(insList: "", viewWidth: CommonConstants.VIEW_WIDTH)
        case CommonConstants.KLINE_MINUTE:
            MDWebSocketUtils.getInstance().sendSetChartMinute(insList: "", viewWidth: CommonConstants.VIEW_WIDTH)
        default:
            break
        }
    }

    func refreshPage() {
        sendChart()
    }

    // MARK: functions
    func initChart() {
        colorChartBackground = UIColor.black
        colorAxis = UIColor.black
        colorText = UIColor.white
        colorGrid = UIColor.red
        colorSell = UIColor.green
        colorBuy = UIColor.red
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(Unhighlight))
        chartView.addGestureRecognizer(tap)
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(highlight))
        doubleTap.numberOfTapsRequired = 2
        chartView.addGestureRecognizer(doubleTap)

        let quoteJson = dataManager.sRtnMD[RtnMDConstants.quotes][dataManager.sInstrumentId]
        if !quoteJson.isEmpty, let preSettlement = Double(quoteJson[QuoteConstants.pre_settlement].stringValue) {
            self.preSettlement = preSettlement
        } else {
            self.preSettlement = 1.0
        }

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

    func generatePositionLimitLine(limit: Double, label: String, color: UIColor, limitKey: String) {
        let chartLimitLine = ChartLimitLine(limit: limit, label: label)
        chartLimitLine.lineWidth = 2.0
        chartLimitLine.lineDashLengths = [10.0, 10.0]
        chartLimitLine.lineDashPhase = 0.0
        chartLimitLine.lineColor = color
        chartLimitLine.labelPosition = .leftBottom
        chartLimitLine.valueFont = UIFont.systemFont(ofSize: 10.0)
        chartLimitLine.valueTextColor = colorText!
        positionLimitLines[limitKey] = chartLimitLine
        chartView.leftAxis.addLimitLine(chartLimitLine)
    }

    func addLongPositionLimitLine() {
        var key = dataManager.sInstrumentId
        if key.contains("KQ") {
            key = (dataManager.sSearchEntities[key]?.underlying_symbol)!
        }
        var vm = "1"
        if let search = dataManager.sSearchEntities[key] {
            vm = search.vm
        }
        guard let position = dataManager.sRtnPositions[key] else {return}
        let available_long = position[PositionConstants.volume_long_his].intValue + position[PositionConstants.volume_long_today].intValue
        let volume_long = available_long + position[PositionConstants.volume_long_frozen].intValue
        if volume_long != 0 {
            let open_cost_long = position[PositionConstants.open_cost_long].floatValue
            let open_price_long = position[PositionConstants.open_price_long].floatValue
            let limit_long = dataManager.getPrice(open_cost: open_cost_long, open_price: open_price_long, vm: Int(vm)!, volume: volume_long)
            let label_long = position[PositionConstants.instrument_id].stringValue + " " + "\(limit_long)"
            generatePositionLimitLine(limit: Double(limit_long), label: label_long, color: colorBuy!, limitKey: key + "0")
        }
    }

    func addShortPositionLimitLine() {
        var key = dataManager.sInstrumentId
        if key.contains("KQ") {
            key = (dataManager.sSearchEntities[key]?.underlying_symbol)!
        }
        var vm = "1"
        if let search = dataManager.sSearchEntities[key] {
            vm = search.vm
        }
        guard let position = dataManager.sRtnPositions[key] else {return}
        let available_short = position[PositionConstants.volume_short_his].intValue + position[PositionConstants.volume_short_today].intValue
        let volume_short = available_short + position[PositionConstants.volume_short_frozen].intValue
        if volume_short != 0 {
            let open_cost_short = position[PositionConstants.open_cost_short].floatValue
            let open_price_short = position[PositionConstants.open_price_short].floatValue
            let limit_short = dataManager.getPrice(open_cost: open_cost_short, open_price: open_price_short, vm: Int(vm)!, volume: volume_short)
            let label_short = position[PositionConstants.instrument_id].stringValue + " " + "\(limit_short)"
            generatePositionLimitLine(limit: Double(limit_short), label: label_short, color: colorSell!, limitKey: key + "1")
        }
    }

    func refreshLongPositionLimitLine() {
        var key = dataManager.sInstrumentId
        if key.contains("KQ") {
            key = (dataManager.sSearchEntities[key]?.underlying_symbol)!
        }
        var vm = "1"
        if let search = dataManager.sSearchEntities[key] {
            vm = search.vm
        }
        let limitKey = key + "0"
        guard let position = dataManager.sRtnPositions[key] else {return}
        let available_long = position[PositionConstants.volume_long_his].intValue + position[PositionConstants.volume_long_today].intValue
        let volume_long = available_long + position[PositionConstants.volume_long_frozen].intValue
        if volume_long != 0 {
            let open_cost_long = position[PositionConstants.open_cost_long].floatValue
            let open_price_long = position[PositionConstants.open_price_long].floatValue
            let limit_long = dataManager.getPrice(open_cost: open_cost_long, open_price: open_price_long, vm: Int(vm)!, volume: volume_long)
            let limitLine = positionLimitLines[limitKey]
            if limitLine?.limit != Double(limit_long) {
                let label_long = position[PositionConstants.instrument_id].stringValue + " " + "\(limit_long)"
                chartView.leftAxis.removeLimitLine(positionLimitLines[limitKey]!)
                generatePositionLimitLine(limit: Double(limit_long), label: label_long, color: colorBuy!, limitKey: limitKey)
            }
        } else {
            chartView.leftAxis.removeLimitLine(positionLimitLines[limitKey]!)
            positionLimitLines.removeValue(forKey: limitKey)
        }

    }

    func refreshShortPositionLimitLine() {
        var key = dataManager.sInstrumentId
        if key.contains("KQ") {
            key = (dataManager.sSearchEntities[key]?.underlying_symbol)!
        }
        var vm = "1"
        if let search = dataManager.sSearchEntities[key] {
            vm = search.vm
        }
        let limitKey = key + "1"
        guard let position = dataManager.sRtnPositions[key] else {return}
        let available_short = position[PositionConstants.volume_short_his].intValue + position[PositionConstants.volume_short_today].intValue
        let volume_short = available_short + position[PositionConstants.volume_short_frozen].intValue
        if volume_short != 0 {
            let open_cost_short = position[PositionConstants.open_cost_short].floatValue
            let open_price_short = position[PositionConstants.open_price_short].floatValue
            let limit_short = dataManager.getPrice(open_cost: open_cost_short, open_price: open_price_short, vm: Int(vm)!, volume: volume_short)
            let limitLine = positionLimitLines[limitKey]
            if limitLine?.limit != Double(limit_short) {
                let label_short = position[PositionConstants.instrument_id].stringValue + " " + "\(limit_short)"
                chartView.leftAxis.removeLimitLine(positionLimitLines[limitKey]!)
                generatePositionLimitLine(limit: Double(limit_short), label: label_short, color: colorSell!, limitKey: limitKey)
            }
        } else {
            chartView.leftAxis.removeLimitLine(positionLimitLines[limitKey]!)
            positionLimitLines.removeValue(forKey: limitKey)
        }
    }

    func removePositionLimitLines() {
        for value in positionLimitLines.map({$0.value}) {
            chartView.leftAxis.removeLimitLine(value)
        }
        positionLimitLines.removeAll()
    }

    //挂单线增删操作
    func addOrderLimitLines() {
        for orderEntity in dataManager.sRtnOrders.map({$0.value}) {
            let instrumentId = orderEntity[OrderConstants.exchange_id].stringValue + "." + orderEntity[OrderConstants.instrument_id].stringValue
            let status = orderEntity[OrderConstants.status].stringValue
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
        for key in orderLimitLines.map({$0.key}) {
            removeOneOrderLimitLine(key: key)
        }
    }

    private func addOneOrderLimitLine(orderEntity: JSON) {
        let direction = orderEntity[OrderConstants.direction].stringValue
        let price = orderEntity[OrderConstants.limit_price].stringValue
        let OrderId = orderEntity[OrderConstants.order_id].stringValue
        let limit = Double(price)!
        let label = "\(OrderId)@\(price)"
        let chartLimitLine = ChartLimitLine(limit: limit, label: label)
        orderLimitLines[OrderId] = chartLimitLine
        chartLimitLine.lineWidth = 2.0
        chartLimitLine.lineDashLengths = [10.0, 10.0]
        chartLimitLine.lineDashPhase = 0.0
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
    }

    // MARK: objc methods
    @objc func refreshPositionLine() {
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
    }

    @objc func refreshOrderLine() {
        if dataManager.sIsLogin && isShowOrderLine {
            for (orderId, orderEntity): (String, JSON) in dataManager.sRtnOrders {
                let instrumentId = orderEntity[OrderConstants.exchange_id].stringValue + "." + orderEntity[OrderConstants.instrument_id].stringValue
                var ins = dataManager.sInstrumentId
                if ins.contains("KQ") {
                    ins = (dataManager.sSearchEntities[ins]?.underlying_symbol)!
                }
                if instrumentId.elementsEqual(ins) {
                    let status = orderEntity[OrderConstants.status].stringValue
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

    @objc func controlAverageLine(notification: Notification){

    }

    @objc func refreshKline() {

    }

    @objc func clearChartView(){
        xVals.removeAll()
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

    //隐藏十字光标
    @objc func Unhighlight(){
        
    }

    //显示十字光标
    @objc func highlight(){
     
    }
}
