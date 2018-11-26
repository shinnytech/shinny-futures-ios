//
//  KlineViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/10.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON

class KlineViewController: BaseChartViewController {

    // MARK: Properties
    @IBOutlet weak var klineChartView: KlineCombinedChartView!
    //X轴显示格式，“年/月”--“2017/07” “月/日”--“07/09”
    var xValsFormat = ""
    var scaleX = CGFloat(0.0)
    //均线数据
    var lineData: LineChartData!
    //均线颜色
    var colorMa5: UIColor!
    var colorMa10: UIColor!
    var colorMa20: UIColor!
    var viewWidth = 0
    var left_id = -1
    var right_id = -1
    var last_id = -1
    var moveGesture: UIPanGestureRecognizer!
    var isMoveHighlight = false
    var startX = CGFloat(0.0)
    //最新价数据
    var latestLimitLines = [String: ChartLimitLine]()

    override func viewDidLoad() {
        //为了marker view中的分类
        klineChartView.klineType = klineType
        chartView = klineChartView
        super.viewDidLoad()
    }

    override func initChart() {
        super.initChart()

        isShowAverageLine = UserDefaults.standard.bool(forKey: "averageLine")
        if !isShowAverageLine {
            chartView.legend.enabled = false
        }

        switch klineType {
        case CommonConstants.KLINE_DAY:
            xValsFormat = "yy/MM/dd"
        case CommonConstants.KLINE_HOUR:
            xValsFormat = "dd/HH:mm"
        case CommonConstants.KLINE_MINUTE:
            xValsFormat = "dd/HH:mm"
        default:
            xValsFormat = "dd/HH:mm"
        }
        simpleDateFormat = DateFormatter()
        simpleDateFormat.dateFormat = xValsFormat
        simpleDateFormat.locale = Locale.autoupdatingCurrent
        colorMa5 = UIColor.white
        colorMa10 = UIColor.yellow
        colorMa20 = UIColor.purple
        viewWidth = CommonConstants.VIEW_WIDTH

        chartView.scaleYEnabled = false
        chartView.drawOrder = [CombinedChartView.DrawOrder.candle.rawValue, CombinedChartView.DrawOrder.line.rawValue]
        let markView = KlineMarkerView.viewFromXib()!
        markView.chartView = chartView
        chartView.marker = markView
        chartView.highlightPerDragEnabled = false
        moveGesture = UIPanGestureRecognizer(target: self, action: #selector(movePan))

        let bottomAxis = chartView.xAxis
        bottomAxis.labelPosition = .bottom
        bottomAxis.valueFormatter = MyXAxisValueFormat(parent: self)
        bottomAxis.gridLineDashLengths = [2, 2, 2, 2]
        bottomAxis.gridLineWidth = 0.2
        bottomAxis.axisLineColor = colorGrid!
        bottomAxis.gridColor = colorGrid!
        bottomAxis.labelTextColor = colorText!
        bottomAxis.granularity = 1

        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .insideChart
        leftAxis.drawAxisLineEnabled = false
        leftAxis.gridLineDashLengths = [2, 2, 2, 2]
        leftAxis.gridLineWidth = 0.2
        leftAxis.gridColor = colorGrid!
        leftAxis.labelTextColor = colorText!
        leftAxis.labelCount = 6
        leftAxis.valueFormatter = MyYAxisValueFormat(parent: self)

        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false

        let ma5 = LegendEntry(label: "MA5", form: .square, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: [CGFloat.nan], formColor: colorMa5)
        let ma10 = LegendEntry(label: "MA10", form: .square, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: [CGFloat.nan], formColor: colorMa10)
        let ma20 = LegendEntry(label: "MA20", form: .square, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: [CGFloat.nan], formColor: colorMa20)
        let l = chartView.legend
        l.setCustom(entries: [ma5, ma10, ma20])
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.textColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scaleX = CGFloat(UserDefaults.standard.double(forKey: "scaleX"))
        if chartView.scaleX != scaleX {
            chartView.fitScreen()
            chartView.zoom(scaleX: scaleX, scaleY: 1, x: CGFloat(last_id), y: 0)
        }
    }

    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        UserDefaults.standard.set(self.chartView.scaleX, forKey: "scaleX")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).allObjects[0] as! UITouch
        let location = touch.location(in: chartView)
        startX = location.x
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMoveHighlight {
            let touch = (touches as NSSet).allObjects[0] as! UITouch
            let location = touch.location(in: chartView)
            if abs(location.x - startX) > 10 && Int(chartView.lowestVisibleX + 0.5) == left_id && xVals.count >= viewWidth {
                viewWidth = viewWidth + 100
                let instrumentId = dataManager.sInstrumentId
                switch klineType {
                case CommonConstants.KLINE_DAY:
                    MDWebSocketUtils.getInstance().sendSetChartDay(insList: instrumentId, viewWidth: viewWidth)
                case CommonConstants.KLINE_HOUR:
                    MDWebSocketUtils.getInstance().sendSetChartHour(insList: instrumentId, viewWidth: viewWidth)
                case CommonConstants.KLINE_MINUTE:
                    MDWebSocketUtils.getInstance().sendSetChartMinute(insList: instrumentId, viewWidth: viewWidth)
                default:
                    break
                }
            }
        }
    }

    override func highlight() {
        isMoveHighlight = true
        chartView.dragEnabled = false
        let position = doubleTap.location(in: chartView)
        let highlight = chartView.getHighlightByTouchPoint(position)
        chartView.highlightValue(highlight)
        chartView.addGestureRecognizer(moveGesture)
        chartView.addGestureRecognizer(singleTap)
    }

    override func Unhighlight() {
        chartView.highlightValue(nil)
        chartView.dragEnabled = true
        isMoveHighlight = false
        chartView.removeGestureRecognizer(moveGesture)
        chartView.removeGestureRecognizer(singleTap)
    }

    @objc func movePan(){
        if isMoveHighlight {
            let highlight = chartView.getHighlightByTouchPoint(moveGesture.location(in: moveGesture.view))
            chartView.highlightValue(highlight)
        }
    }

    override func refreshKline() {
        let kline = dataManager.sRtnMD[RtnMDConstants.klines][dataManager.sInstrumentId][klineType]
        let chart = dataManager.sRtnMD[RtnMDConstants.charts][klineType]
        let ins_list = chart[ChartConstants.state][ChartConstants.ins_list].stringValue
        last_id = kline[KlineConstants.last_id].intValue
        let datas = kline[KlineConstants.data]
        if last_id != -1 && !datas.isEmpty && dataManager.sInstrumentId.elementsEqual(ins_list) {
            if chartView.data != nil && (chartView.data?.dataSetCount)! > 0 {
                let combineData = chartView.combinedData
                let candleData = combineData?.candleData
                let itemCount = datas.count
                let entryCount = candleData?.getDataSetByIndex(0).entryCount
                if itemCount == entryCount {
                    //print("k线图刷新")
                    let xValue = Double(last_id)
                    candleData?.removeEntry(xValue: xValue, dataSetIndex: 0)
                    lineData.removeEntry(xValue: xValue, dataSetIndex: 0)
                    lineData.removeEntry(xValue: xValue, dataSetIndex: 1)
                    lineData.removeEntry(xValue: xValue, dataSetIndex: 2)
                    generateLineCandleDataEntry(candleData: candleData!, left_id: left_id, index: last_id, datas: datas)
                    refreshLatestLine(data: datas["\(last_id)"])
                } else {
                    var left_index = chart[ChartConstants.left_id].intValue
                    let right_index = chart[ChartConstants.right_id].intValue
                    if left_index < 0 {left_index = 0}
                    if left_index < left_id {
                        //NSLog("向前添加柱子")
                        var index = left_id - 1
                        while index >= left_index {
                            generateLineCandleDataEntry(candleData: candleData!, left_id: left_index, index: index, datas: datas)
                            index -= 1
                        }
                        left_id = left_index
                    } else if right_index > right_id {
                        //NSLog("向后添加柱子")
                        for index in (right_id + 1)...right_index {
                            generateLineCandleDataEntry(candleData: candleData!, left_id: left_id, index: index, datas: datas)
                        }
                        right_id = right_index
                        refreshLatestLine(data: datas["\(last_id)"])
                    }
                }
                combineData?.notifyDataChanged()
                chartView.notifyDataSetChanged()
                chartView.xAxis.axisMaximum = (combineData?.xMax)! + 2.5
                chartView.xAxis.axisMinimum = (combineData?.xMin)! - 0.5
            } else {
                NSLog("k线图初始化")
                left_id = chart[ChartConstants.left_id].intValue
                right_id = chart[ChartConstants.right_id].intValue
                if left_id < 0 {left_id = 0}
                var ma5Datas = [ChartDataEntry]()
                var ma10Datas = [ChartDataEntry]()
                var ma20Datas = [ChartDataEntry]()
                var candleDatas = [CandleChartDataEntry]()
                for index in left_id...last_id {
                    candleDatas.append(generateCandleDataEntry(index: index, datas: datas))
                    if index >= left_id + 4 {
                        let entry = generateLineDataEntry(index: index, lineIndex: 4, datas: datas)
                        ma5Datas.append(entry)
                    }
                    if index >= left_id + 9 {
                        let entry = generateLineDataEntry(index: index, lineIndex: 9, datas: datas)
                        ma10Datas.append(entry)
                    }
                    if index >= left_id + 19 {
                        let entry = generateLineDataEntry(index: index, lineIndex: 19, datas: datas)
                        ma20Datas.append(entry)
                    }
                }
                let combineData = CombinedChartData()
                combineData.candleData = generateCandleData(candles: candleDatas)
                lineData = generateLineData(ma5Datas: ma5Datas, ma10Datas: ma10Datas, ma20Datas: ma20Datas)
                if isShowAverageLine {combineData.lineData = lineData } else {combineData.lineData = LineChartData()}
                chartView.data = combineData
                chartView.xAxis.axisMaximum = combineData.xMax + 2.5
                chartView.xAxis.axisMinimum = combineData.xMin - 0.5
                chartView.setVisibleXRangeMaximum(200)
                chartView.setVisibleXRangeMinimum(7)
                chartView.zoom(scaleX: scaleX, scaleY: 1.0, xValue: Double(last_id), yValue: 0.0, axis: YAxis.AxisDependency.left)
                generateLatestLine(data: datas["\(right_id)"])
                (chartView.marker as! KlineMarkerView).resizeXib(heiht: chartView.viewPortHandler.contentHeight)
            }
        }
    }

    //生成最新价线
    private func generateLatestLine(data: JSON){
        let limit = data[KlineConstants.close].stringValue
        let decimal = dataManager.getDecimalByPtick(instrumentId: dataManager.sInstrumentId)
        let label = dataManager.saveDecimalByPtick(decimal: decimal, data: limit)
        if let limit = Double(limit) {
            let chartLimitLine = ChartLimitLine(limit: limit, label: label)
            chartLimitLine.lineWidth = 1.0
            chartLimitLine.lineDashLengths = [2.0, 2.0]
            chartLimitLine.lineDashPhase = 0.0
            chartLimitLine.lineColor = UIColor(red: 63/255.0, green: 63/255.0, blue: 63/255.0, alpha: 1)
            chartLimitLine.labelPosition = .rightTop
            chartLimitLine.valueFont = UIFont.systemFont(ofSize: 10.0)
            chartLimitLine.valueTextColor = UIColor(red: 63/255.0, green: 63/255.0, blue: 63/255.0, alpha: 1)
            latestLimitLines["latest"] = chartLimitLine
            chartView.leftAxis.addLimitLine(chartLimitLine)
        }

    }


    //刷新最新价线
    private func refreshLatestLine(data: JSON){
        let limit = data[KlineConstants.close].doubleValue
        guard let limitLine = latestLimitLines["latest"] else {return}
        if limitLine.limit != limit{
            chartView.leftAxis.removeLimitLine(limitLine)
            latestLimitLines.removeValue(forKey: "latest")
            generateLatestLine(data: data)
        }
    }

    //添加单个均线数据与柱子
    private func generateLineCandleDataEntry(candleData: CandleChartData, left_id: Int, index: Int, datas: JSON) {
        let candleEntry = generateCandleDataEntry(index: index, datas: datas)
        _ = candleData.getDataSetByIndex(0).addEntryOrdered(candleEntry)
        if index >= left_id + 4 {
            let entry = generateLineDataEntry(index: index, lineIndex: 4, datas: datas)
            _ = lineData.getDataSetByIndex(0).addEntryOrdered(entry)
        }
        if index >= left_id + 9 {
            let entry = generateLineDataEntry(index: index, lineIndex: 9, datas: datas)
            _ = lineData.getDataSetByIndex(1).addEntryOrdered(entry)
        }
        if index >= left_id + 19 {
            let entry = generateLineDataEntry(index: index, lineIndex: 19, datas: datas)
            _ = lineData.getDataSetByIndex(2).addEntryOrdered(entry)
        }
    }

    //产生单个均线数据
    private func generateLineDataEntry(index: Int, lineIndex: Int, datas: JSON) -> ChartDataEntry {
        var sum = 0.0
        for i in (index - lineIndex)...index {
            let data = datas["\(i)"]
            let close = data[KlineConstants.close].doubleValue
            sum += close
        }
        let entry = ChartDataEntry(x: Double(index), y: sum / Double(lineIndex + 1))
        return entry
    }

    //生成单个柱子数据
    private func generateCandleDataEntry(index: Int, datas: JSON) -> CandleChartDataEntry {
        let data = datas["\(index)"]
        let high = data[KlineConstants.high].doubleValue
        let low = data[KlineConstants.low].doubleValue
        let close = data[KlineConstants.close].doubleValue
        let open = data[KlineConstants.open].doubleValue
        let dateTime = data[KlineConstants.datetime].intValue / 1000000000
        let x = Double(index)
        let candleChartDataEntry = CandleChartDataEntry(x: x, shadowH: high, shadowL: low, open: open, close: close)
        xVals[index] = dateTime
        return candleChartDataEntry
    }

    //生成蜡烛图数据
    private func generateCandleData(candles: [CandleChartDataEntry]) -> CandleChartData {
        let set = CandleChartDataSet(values: candles, label: "kline")
        set.axisDependency = .left
        set.shadowWidth = 0.7
        set.decreasingColor = UIColor(red: 0.0, green: 252.0/255.0, blue: 252.0/255.0, alpha: 1)
        set.decreasingFilled = true
        set.increasingColor = UIColor(red: 218.0/255.0, green: 0.0, blue: 0.0, alpha: 1)
        set.increasingFilled = false
        set.neutralColor = UIColor.white
        set.shadowColorSameAsCandle = true
        set.highlightLineWidth = 1
        set.highlightColor = UIColor.white
        set.drawValuesEnabled = true
        set.valueTextColor = UIColor.red
        set.valueFont = UIFont.systemFont(ofSize: 9)
        set.drawIconsEnabled = false
        set.valueFormatter = MyValueFormat(parent: self)
        let candleData = CandleChartData()
        candleData.addDataSet(set)
        return candleData
    }

    //产生均线数据
    private func generateLineData(ma5Datas: [ChartDataEntry], ma10Datas: [ChartDataEntry], ma20Datas: [ChartDataEntry]) -> LineChartData {
        let lineData: LineChartData!
        if ma5Datas.isEmpty {
            lineData = LineChartData()
        } else if ma10Datas.isEmpty {
            lineData = LineChartData(dataSet: generateLineDataSet(entries: ma5Datas, color: colorMa5, label: "MA5"))
        } else if ma20Datas.isEmpty {
            let ma5 = generateLineDataSet(entries: ma5Datas, color: colorMa5, label: "MA5")
            let ma10 = generateLineDataSet(entries: ma10Datas, color: colorMa10, label: "MA10")
            lineData = LineChartData(dataSets: [ma5, ma10])
        } else {
            let ma5 = generateLineDataSet(entries: ma5Datas, color: colorMa5, label: "MA5")
            let ma10 = generateLineDataSet(entries: ma10Datas, color: colorMa10, label: "MA10")
            let ma20 = generateLineDataSet(entries: ma20Datas, color: colorMa20, label: "MA20")
            lineData = LineChartData(dataSets: [ma5, ma10, ma20])
        }
        return lineData
    }

    //生成均线数据集
    private func generateLineDataSet(entries: [ChartDataEntry], color: UIColor, label: String) -> LineChartDataSet {
        let set = LineChartDataSet(values: entries, label: label)
        set.setColor(color)
        set.lineWidth = 1.0
        set.drawCirclesEnabled = false
        set.drawCircleHoleEnabled = false
        set.drawValuesEnabled = false
        set.axisDependency = .left
        set.highlightEnabled = false
        return set
    }

    //控制均线显示与否
    @objc override func controlAverageLine(notification: Notification) {
        isShowAverageLine = notification.object as! Bool
        if isShowAverageLine {
            chartView.combinedData?.lineData = lineData
            chartView.legend.enabled = true
        } else {
            chartView.combinedData?.lineData = LineChartData()
            chartView.legend.enabled = false
        }
        chartView.combinedData?.notifyDataChanged()
        chartView.setNeedsDisplay()
    }

    //格式化X轴数据
    class MyXAxisValueFormat: IAxisValueFormatter {

        weak var parent: KlineViewController!

        init(parent: KlineViewController) {
            self.parent = parent
        }

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let index = Int(value)
            guard let dateTime = parent.xVals[index] else {return ""}
            let date = Date(timeIntervalSince1970: TimeInterval(dateTime))
            let time = parent.simpleDateFormat.string(from: date)
            return time
        }
    }

    //格式化左Y轴数据
    class MyYAxisValueFormat: IAxisValueFormatter {

        weak var parent: KlineViewController!

        init(parent: KlineViewController) {
            self.parent = parent
        }

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let instrumentId = DataManager.getInstance().sInstrumentId
            let decimal = parent.dataManager.getDecimalByPtick(instrumentId: instrumentId)
            return parent.dataManager.saveDecimalByPtick(decimal: decimal, data: "\(value)")
        }
    }

    //格式化最高最低价标识
    class MyValueFormat: IValueFormatter {

        weak var parent: KlineViewController!

        init(parent: KlineViewController) {
            self.parent = parent
        }

        func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            let instrumentId = DataManager.getInstance().sInstrumentId
            let decimal = parent.dataManager.getDecimalByPtick(instrumentId: instrumentId)
            return parent.dataManager.saveDecimalByPtick(decimal: decimal, data: "\(value)")
        }
    }
}
