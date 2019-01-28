//
//  KlineViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/10.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

class KlineViewController: BaseChartViewController {

    // MARK: Properties
    @IBOutlet weak var klineChartView: KlineCombinedChartView!
    //X轴显示格式，“年/月”--“2017/07” “月/日”--“07/09”
    var xValsFormat = ""
    var scaleX = CGFloat(0.0)
    //均线数据
    var lineData: LineChartData!
    var viewWidth = 0
    var left_id = -1
    var right_id = -1
    var last_id = -1
    var moveGesture: UIPanGestureRecognizer!
    var isMoveHighlight = false
    var startX = CGFloat(0.0)
    //最新价数据
    var latestLimitLines = [String: ChartLimitLine]()
    var chart: Chart!
    var kline: Kline!
    var mas: [Int]!

    override func viewDidLoad() {
        chartView = klineChartView
        super.viewDidLoad()
    }

    override func initChart() {
        super.initChart()

        isShowAverageLine = UserDefaults.standard.bool(forKey: "averageLine")
        if !isShowAverageLine {
            chartView.legend.enabled = false
        }

        switch fragmentType {
        case CommonConstants.DAY_FRAGMENT:
            xValsFormat = "yy/MM/dd"
        case CommonConstants.HOUR_FRAGMENT:
            xValsFormat = "dd/HH:mm"
        case CommonConstants.MINUTE_FRAGMENT:
            xValsFormat = "dd/HH:mm"
        case CommonConstants.SECOND_FRAGMENT:
            xValsFormat = "HH:mm:ss"
        default:
            xValsFormat = "dd/HH:mm"
        }
        simpleDateFormat = DateFormatter()
        simpleDateFormat.dateFormat = xValsFormat
        simpleDateFormat.locale = Locale.autoupdatingCurrent

        mas = UserDefaults.standard.array(forKey: CommonConstants.CONFIG_SETTING_PARA_MA) as? [Int]
        mas = mas.filter(){
            return $0 != 0
        }
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

        var maLengendEntries = [LegendEntry]()
        for index in Array(0..<mas.count) {
            let para = mas[index]
            let color = CommonConstants.KLINE_MDs[index]
            let maLegendEntry = LegendEntry(label: "MA\(para)", form: .square, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: [CGFloat.nan], formColor: color)
            maLengendEntries.append(maLegendEntry)
        }

        let l = chartView.legend
        l.setCustom(entries: maLengendEntries)
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
                MDWebSocketUtils.getInstance().sendSetChartKline(insList: instrumentId, klineType: klineType, viewWidth: viewWidth)
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
        
        if chartView.data != nil && (chartView.data?.dataSetCount)! > 0 {
            let combineData = chartView.combinedData
            let candleData = combineData?.candleData
            let datas = kline.datas
            let left_id_t = chart.left_id as? Int ?? -1
            let right_id_t = chart.right_id as? Int ?? -1
            let last_id_t = kline.last_id as? Int ?? -1

            if right_id_t == right_id && left_id_t == left_id{
                //print("k线图刷新")
                let xValue = Double(last_id)
                candleData?.removeEntry(xValue: xValue, dataSetIndex: 0)
                for index in Array(0..<lineData.dataSetCount){
                    lineData.removeEntry(xValue: xValue, dataSetIndex: index)
                }
                generateLineCandleDataEntry(candleData: candleData!, left_id: left_id, index: last_id, datas: datas)
                refreshLatestLine(data: datas["\(last_id)"])
            } else if right_id_t > right_id && left_id_t > left_id{
                //NSLog("向后添加柱子")
                for index in (right_id + 1)...right_id_t {
                    generateLineCandleDataEntry(candleData: candleData!, left_id: left_id, index: index, datas: datas)
                }
                refreshLatestLine(data: datas["\(last_id)"])
            }else if left_id_t < left_id{
                //NSLog("向前添加柱子")
                var index = left_id - 1
                while index >= left_id_t {
                    generateLineCandleDataEntry(candleData: candleData!, left_id: left_id_t, index: index, datas: datas)
                    index -= 1
                }
            }
            right_id = right_id_t
            last_id = last_id_t
            left_id = left_id_t
            combineData?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            chartView.xAxis.axisMaximum = (combineData?.xMax)! + 2.5
            chartView.xAxis.axisMinimum = (combineData?.xMin)! - 0.5
        } else {
            NSLog("k线图初始化")
            guard let chart = dataManager.sRtnMD.charts[CommonConstants.CHART_ID] else {return}
            self.chart = chart
            let left_id_t = chart.left_id as? Int ?? -1
            let right_id_t = chart.right_id as? Int ?? -1
            let mdhis_more_data = dataManager.sRtnMD.mdhis_more_data
            if (left_id_t == -1 && right_id_t == -1) || mdhis_more_data{return}
            let ins_list = "\(chart.state?.ins_list ?? "")"
            let duration = "\(chart.state?.duration ?? "")"
            if !ins_list.elementsEqual(dataManager.sInstrumentId) || !duration.elementsEqual(klineType) {return}
            guard let kline = dataManager.sRtnMD.klines[dataManager.sInstrumentId]?[klineType] else {return}
            self.kline = kline
            let datas = kline.datas
            let last_id_t = kline.last_id as? Int ?? -1
            if last_id_t == -1 || datas.isEmpty {return}
            left_id = left_id_t
            right_id = right_id_t
            last_id = last_id_t

            let combineData = CombinedChartData()
            combineData.candleData = generateCandleData()
            lineData = generateLineData()
            if isShowAverageLine {combineData.lineData = lineData } else {combineData.lineData = LineChartData()}
            chartView.data = combineData
            chartView.xAxis.axisMaximum = combineData.xMax + 2.5
            chartView.xAxis.axisMinimum = combineData.xMin - 0.5
            chartView.setVisibleXRangeMaximum(200)
            chartView.setVisibleXRangeMinimum(7)
            chartView.zoom(scaleX: scaleX, scaleY: 1.0, xValue: Double(last_id), yValue: 0.0, axis: YAxis.AxisDependency.left)
            chartView.moveViewToX(Double(right_id))
            generateLatestLine(data: datas["\(right_id)"])
            (chartView.marker as! KlineMarkerView).resizeXib(heiht: chartView.viewPortHandler.contentHeight, width: chartView.viewPortHandler.contentWidth)
        }
    }

    //生成最新价线
    private func generateLatestLine(data: Kline.Data?){
        guard let data = data else {return}
        let limit = "\(data.close ?? 0.0)"
        let decimal = dataManager.getDecimalByPtick(instrumentId: dataManager.sInstrumentId)
        let label = dataManager.saveDecimalByPtick(decimal: decimal, data: limit)
        if let limit = Double(limit) {
            let chartLimitLine = ChartLimitLine(limit: limit, label: label)
            chartLimitLine.lineWidth = 0.7
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
    private func refreshLatestLine(data: Kline.Data?){
        guard let data = data else {return}
        let limit = Double("\(data.close ?? 0.0)") ?? 0.0
        guard let limitLine = latestLimitLines["latest"] else {return}
        if limitLine.limit != limit{
            chartView.leftAxis.removeLimitLine(limitLine)
            latestLimitLines.removeValue(forKey: "latest")
            generateLatestLine(data: data)
        }
    }

    override func removeLatestLine() {
        guard let limitLine = latestLimitLines["latest"] else {return}
        chartView.leftAxis.removeLimitLine(limitLine)
        latestLimitLines.removeValue(forKey: "latest")
    }

    //添加单个均线数据与柱子
    private func generateLineCandleDataEntry(candleData: CandleChartData, left_id: Int, index: Int, datas: [String: Kline.Data]) {
        let candleEntry = generateCandleDataEntry(index: index, datas: datas)
        _ = candleData.getDataSetByIndex(0).addEntryOrdered(candleEntry)

        for i in Array(0..<mas.count) {
            let para = mas[i]
            if index >= left_id + para - 1 {
                let entry = generateLineDataEntry(index: index, lineIndex: para - 1, datas: datas)
                _ = lineData.getDataSetByIndex(i).addEntryOrdered(entry)
            }
        }
    }

    //产生单个均线数据
    private func generateLineDataEntry(index: Int, lineIndex: Int, datas: [String: Kline.Data]) -> ChartDataEntry {
        var sum = 0.0
        for i in (index - lineIndex)...index {
            guard let data = datas["\(i)"] else {continue}
            let close = Double("\(data.close ?? 0.0)") ?? 0.0
            sum += close
        }
        let entry = ChartDataEntry(x: Double(index), y: sum / Double(lineIndex + 1))
        return entry
    }

    //生成单个柱子数据
    private func generateCandleDataEntry(index: Int, datas: [String: Kline.Data]) -> CandleChartDataEntry {
        let data = datas["\(index)"]
        let high = Double("\(data?.high ?? 0.0)") ?? 0.0
        let low = Double("\(data?.low ?? 0.0)") ?? 0.0
        let close = Double("\(data?.close ?? 0.0)") ?? 0.0
        let open = Double("\(data?.open ?? 0.0)") ?? 0.0
        let dateTime = ((data?.datetime as? Int) ?? 0) / 1000000000
        let x = Double(index)
        let candleChartDataEntry = CandleChartDataEntry(x: x, shadowH: high, shadowL: low, open: open, close: close)
        xVals[index] = dateTime
        return candleChartDataEntry
    }

    //生成蜡烛图数据
    private func generateCandleData() -> CandleChartData {
        var candleDatas = [CandleChartDataEntry]()
        for index in left_id...last_id {
            candleDatas.append(generateCandleDataEntry(index: index, datas: kline.datas))
        }
        let set = CandleChartDataSet(values: candleDatas, label: "kline")
        set.axisDependency = .left
        set.shadowWidth = 0.7
        set.decreasingColor = UIColor(red: 0.0, green: 252.0/255.0, blue: 252.0/255.0, alpha: 1)
        set.decreasingFilled = true
        set.increasingColor = UIColor(red: 218.0/255.0, green: 0.0, blue: 0.0, alpha: 1)
        set.increasingFilled = false
        set.neutralColor = UIColor.white
        set.shadowColorSameAsCandle = true
        set.highlightLineWidth = 0.7
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
    private func generateLineData() -> LineChartData {
        var sets = [LineChartDataSet]()

        for index in Array(0..<mas.count) {
            let para = mas[index]
            let color = CommonConstants.KLINE_MDs[index]
            sets.append(generateLineDataSet(para: para, color: color, label: "MA\(para)"))
        }

        let lineData: LineChartData!
        lineData = LineChartData(dataSets: sets)
        return lineData
    }

    //生成均线数据集
    private func generateLineDataSet(para: Int, color: UIColor, label: String) -> LineChartDataSet {
        var entities = [ChartDataEntry]()
        for index in left_id...last_id {
            if index >= (left_id + para - 1) {
                let entry = generateLineDataEntry(index: index, lineIndex: para - 1, datas: kline.datas)
                entities.append(entry)
            }
        }
        let set = LineChartDataSet(values: entities, label: label)
        set.setColor(color)
        set.lineWidth = 0.7
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
