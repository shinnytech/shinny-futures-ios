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
    @IBOutlet weak var topChartView: KlineCombinedChartView!
    @IBOutlet weak var middleChartView: KlineCombinedChartView!
    @IBOutlet weak var bottomChartView: KlineCombinedChartView!
    //X轴显示格式，“年/月”--“2017/07” “月/日”--“07/09”
    var xValsFormat = ""
    var scaleX = CGFloat(0.0)
    //均线数据
    var maLineData: LineChartData!
    var viewWidth = 0
    var left_id = -1
    var right_id = -1
    var last_id = -1
    var startX = CGFloat(0.0)
    //最新价数据
    var latestLimitLines = [String: ChartLimitLine]()
    var chart: Chart!
    var kline: Kline!
    var mas: [Int]!

    override func viewDidLoad() {
        topChartViewBase = topChartView
        middleChartViewBase = middleChartView
        bottomChartViewBase = bottomChartView
        super.viewDidLoad()
    }

    override func initChart() {
        super.initChart()

        isShowAverageLine = UserDefaults.standard.bool(forKey: "averageLine")
        if !isShowAverageLine {
            topChartViewBase.legend.enabled = false
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

        topChartViewBase.scaleYEnabled = false
        topChartViewBase.highlightPerDragEnabled = false
        topChartViewBase.drawOrder = [CombinedChartView.DrawOrder.candle.rawValue, CombinedChartView.DrawOrder.line.rawValue]
        let markView = KlineMarkerView.viewFromXib()!
        markView.chartView = topChartViewBase
        topChartViewBase.marker = markView

        let bottomAxis = topChartViewBase.xAxis
        bottomAxis.drawAxisLineEnabled = true
        bottomAxis.drawLabelsEnabled = false
        bottomAxis.gridLineDashLengths = [2, 2, 2, 2]
        bottomAxis.gridLineWidth = 0.2
        bottomAxis.gridColor = colorGrid!
        bottomAxis.axisLineColor = colorGrid!
        bottomAxis.labelPosition = .bottom

        let leftAxis = topChartViewBase.leftAxis
        leftAxis.spaceBottom = 0.02
        leftAxis.spaceTop = 0.02
        leftAxis.labelPosition = .insideChart
        leftAxis.drawAxisLineEnabled = false
        leftAxis.gridLineDashLengths = [2, 2, 2, 2]
        leftAxis.gridLineWidth = 0.2
        leftAxis.gridColor = colorGrid!
        leftAxis.labelTextColor = colorText!
        leftAxis.labelCount = 6
        leftAxis.valueFormatter = MyYAxisValueFormat(parent: self)

        let rightAxis = topChartViewBase.rightAxis
        rightAxis.enabled = false

        var maLengendEntries = [LegendEntry]()
        for index in Array(0..<mas.count) {
            let para = mas[index]
            let color = CommonConstants.KLINE_MDs[index]
            let maLegendEntry = LegendEntry(label: "MA\(para)", form: .square, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: [CGFloat.nan], formColor: color)
            maLengendEntries.append(maLegendEntry)
        }

        let l = topChartViewBase.legend
        l.setCustom(entries: maLengendEntries)
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.textColor = UIColor.white

        middleChartViewBase.scaleYEnabled = false
        middleChartViewBase.highlightPerDragEnabled = false

        let middleBottomAxis = middleChartViewBase.xAxis
        middleBottomAxis.drawAxisLineEnabled = true
        middleBottomAxis.drawLabelsEnabled = true
        middleBottomAxis.gridLineDashLengths = [2, 2, 2, 2]
        middleBottomAxis.gridLineWidth = 0.2
        middleBottomAxis.gridColor = colorGrid!
        middleBottomAxis.axisLineColor = colorGrid!
        middleBottomAxis.labelTextColor = colorText!
        middleBottomAxis.labelPosition = .bottom
        middleBottomAxis.valueFormatter = MyXAxisValueFormat(parent: self)

        let middleLeftAxis = middleChartViewBase.leftAxis
        middleLeftAxis.labelPosition = .insideChart
        middleLeftAxis.drawAxisLineEnabled = false
        middleLeftAxis.gridLineDashLengths = [2, 2, 2, 2]
        middleLeftAxis.gridLineWidth = 0.2
        middleLeftAxis.gridColor = colorGrid!
        middleLeftAxis.labelTextColor = colorText!
        middleLeftAxis.labelCount = 4
        middleLeftAxis.axisMinimum = 0
        middleLeftAxis.spaceBottom = 0

        let middleRightAxis = middleChartViewBase.rightAxis
        middleRightAxis.drawLabelsEnabled = false
        middleRightAxis.drawAxisLineEnabled = false
        middleRightAxis.drawGridLinesEnabled = false

        let middleLegend = middleChartViewBase.legend
        middleLegend.enabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scaleX = CGFloat(UserDefaults.standard.double(forKey: CommonConstants.SCALE_X))
    }

    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(scaleX, forKey: CommonConstants.SCALE_X)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).allObjects[0] as! UITouch
        let location = touch.location(in: topChartViewBase)
        startX = location.x
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMoveHighlight {
            let touch = (touches as NSSet).allObjects[0] as! UITouch
            let location = touch.location(in: topChartViewBase)
            if abs(location.x - startX) > 10 && Int(topChartViewBase.lowestVisibleX + 0.5) == left_id && xVals.count >= viewWidth {
                viewWidth = viewWidth + 100
                let instrumentId = dataManager.sInstrumentId
                MDWebSocketUtils.getInstance().sendSetChartKline(insList: instrumentId, klineType: klineType, viewWidth: viewWidth)
            }
        }
    }

    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        if (scaleX > 1 && scaleX > self.scaleX) || (scaleX < 1 && scaleX < self.scaleX){self.scaleX = scaleX}
        let srcMatrix = chartView.viewPortHandler.touchMatrix
        topChartViewBase.viewPortHandler.refresh(newMatrix: srcMatrix, chart: topChartViewBase, invalidate: true)
        middleChartViewBase.viewPortHandler.refresh(newMatrix: srcMatrix, chart: middleChartViewBase, invalidate: true)
    }

    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        let srcMatrix = chartView.viewPortHandler.touchMatrix
        topChartViewBase.viewPortHandler.refresh(newMatrix: srcMatrix, chart: topChartViewBase, invalidate: true)
        middleChartViewBase.viewPortHandler.refresh(newMatrix: srcMatrix, chart: middleChartViewBase, invalidate: true)
    }

    override func refreshKline() {

        if topChartViewBase.data != nil && (topChartViewBase.data?.dataSetCount)! > 0 {
            let topCombineData = topChartViewBase.combinedData
            let candleData = topCombineData?.candleData
            let middleCombineData = middleChartViewBase.combinedData
            let middleLineData = middleCombineData?.lineData
            let middleBarData = middleCombineData?.barData

            let datas = kline.datas
            var left_id_t = chart.left_id as? Int ?? -1
            if left_id_t < 0 {left_id_t = 0}
            var right_id_t = chart.right_id as? Int ?? -1
            if right_id_t < 0 {right_id_t = 0}
            var last_id_t = kline.last_id as? Int ?? -1
            if last_id_t < 0 {last_id_t = 0}

            if right_id_t == right_id && left_id_t == left_id{
//                print("k线图刷新")
                let xValue = Double(last_id)
                candleData?.removeEntry(xValue: xValue, dataSetIndex: 0)
                for index in Array(0..<maLineData.dataSetCount){
                    maLineData.removeEntry(xValue: xValue, dataSetIndex: index)
                }
                middleLineData?.removeEntry(xValue: xValue, dataSetIndex: 0)
                middleBarData?.removeEntry(xValue: xValue, dataSetIndex: 0)
                generateLineCandleDataEntry(left_id: left_id, index: last_id, datas: datas)
                refreshLatestLine(data: datas["\(last_id)"])
            } else if right_id_t > right_id && left_id_t > left_id{
                //NSLog("向后添加柱子")
                for index in (right_id + 1)...right_id_t {
                    generateLineCandleDataEntry(left_id: left_id, index: index, datas: datas)
                }
                refreshLatestLine(data: datas["\(last_id)"])
            }else if left_id_t < left_id{
                //NSLog("向前添加柱子")
                var index = left_id - 1
                while index >= left_id_t {
                    generateLineCandleDataEntry(left_id: left_id_t, index: index, datas: datas)
                    index -= 1
                }
            }
            right_id = right_id_t
            last_id = last_id_t
            left_id = left_id_t
            topCombineData?.notifyDataChanged()
            topChartViewBase.notifyDataSetChanged()
            topChartViewBase.xAxis.axisMaximum = (topCombineData?.xMax)! + 2.5
            topChartViewBase.xAxis.axisMinimum = (topCombineData?.xMin)! - 0.5

            middleCombineData?.notifyDataChanged()
            middleChartViewBase.notifyDataSetChanged()
            middleChartViewBase.xAxis.axisMaximum = (middleCombineData?.xMax)! + 2.5
            middleChartViewBase.xAxis.axisMinimum = (middleCombineData?.xMin)! - 0.5
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
            if left_id < 0{left_id = 0}
            right_id = right_id_t
            if right_id < 0{right_id = 0}
            last_id = last_id_t
            if last_id < 0{last_id = 0}

            let topCombineData = CombinedChartData()
            var candleEntries = [CandleChartDataEntry]()
            let middleCombineData = CombinedChartData()
            var oiEntries = [ChartDataEntry]()
            var volumeEntries = [BarChartDataEntry]()
            for index in left_id...last_id {
                guard let data = datas["\(index)"] else {continue}
                let entries = generateMultiDataEntry(index: index, data: data)
                candleEntries.append(entries[0] as! CandleChartDataEntry)
                oiEntries.append(entries[1])
                volumeEntries.append(entries[2] as! BarChartDataEntry)
            }
            
            topCombineData.candleData = generateCandleData(candleEntries: candleEntries)
            maLineData = generateMALineData()
            if isShowAverageLine {topCombineData.lineData = maLineData } else {topCombineData.lineData = LineChartData()}
            topChartViewBase.data = topCombineData

            let oiDataSet = generateLineDataSet(entries: oiEntries, color: UIColor.white, label: "OI", isHighlight: false, axisDependency: .right)
            let volumeDataSet = generateBarDataSet(entries: volumeEntries, color: UIColor.yellow, label: "Volume", isHighlight: true)
            let oiLineData = LineChartData(dataSet: oiDataSet)
            let volumeBarData = BarChartData(dataSet: volumeDataSet)
            middleCombineData.lineData = oiLineData
            middleCombineData.barData = volumeBarData
            middleChartViewBase.data = middleCombineData

            topChartViewBase.xAxis.axisMaximum = topCombineData.xMax + 2.5
            topChartViewBase.xAxis.axisMinimum = topCombineData.xMin - 0.5
            topChartViewBase.setVisibleXRangeMaximum(200)
            topChartViewBase.setVisibleXRangeMinimum(10)
            topChartViewBase.zoom(scaleX: scaleX, scaleY: 1.0, xValue: Double(last_id), yValue: 0.0, axis: YAxis.AxisDependency.left)
            topChartViewBase.moveViewToX(Double(right_id))
            generateLatestLine(data: datas["\(right_id)"])
            (topChartViewBase.marker as! KlineMarkerView).setDateFormat(fragmentType: fragmentType)
            (topChartViewBase.marker as! KlineMarkerView).resizeXib(heiht: topChartViewBase.viewPortHandler.contentHeight, width: topChartViewBase.viewPortHandler.contentWidth)

            middleChartViewBase.xAxis.axisMaximum = middleCombineData.xMax + 2.5
            middleChartViewBase.xAxis.axisMinimum = middleCombineData.xMin - 0.5
            middleChartViewBase.setVisibleXRangeMaximum(200)
            middleChartViewBase.setVisibleXRangeMinimum(10)
            middleChartViewBase.zoom(scaleX: scaleX, scaleY: 1.0, xValue: Double(last_id), yValue: 0.0, axis: YAxis.AxisDependency.left)
            middleChartViewBase.moveViewToX(Double(right_id))

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
            topChartViewBase.leftAxis.addLimitLine(chartLimitLine)
        }

    }


    //刷新最新价线
    private func refreshLatestLine(data: Kline.Data?){
        guard let data = data else {return}
        let limit = Double("\(data.close ?? 0.0)") ?? 0.0
        guard let limitLine = latestLimitLines["latest"] else {return}
        if limitLine.limit != limit{
            topChartViewBase.leftAxis.removeLimitLine(limitLine)
            latestLimitLines.removeValue(forKey: "latest")
            generateLatestLine(data: data)
        }
    }

    override func removeLatestLine() {
        guard let limitLine = latestLimitLines["latest"] else {return}
        topChartViewBase.leftAxis.removeLimitLine(limitLine)
        latestLimitLines.removeValue(forKey: "latest")
    }

    //添加单个均线数据与柱子
    private func generateLineCandleDataEntry(left_id: Int, index: Int, datas: [String: Kline.Data]) {
        guard let data = datas["\(index)"] else {return}
        let entries = generateMultiDataEntry(index: index, data: data)
        let candleEntry = entries[0]
        let oiEntry = entries[1]
        let volumeEntry = entries[2]
        _ = topChartViewBase.candleData?.getDataSetByIndex(0).addEntryOrdered(candleEntry)
        _ = middleChartViewBase.lineData?.getDataSetByIndex(0).addEntryOrdered(oiEntry)
        _ = middleChartViewBase.barData?.getDataSetByIndex(0).addEntryOrdered(volumeEntry)

        for i in Array(0..<mas.count) {
            let para = mas[i]
            if index >= left_id + para - 1 {
                let entry = generateMALineDataEntry(index: index, lineIndex: para - 1, datas: datas)
                _ = maLineData.getDataSetByIndex(i).addEntryOrdered(entry)
            }
        }
    }

    //产生单个均线数据
    private func generateMALineDataEntry(index: Int, lineIndex: Int, datas: [String: Kline.Data]) -> ChartDataEntry {
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
    private func generateMultiDataEntry(index: Int, data: Kline.Data) -> [ChartDataEntry] {
        let high = Double("\(data.high ?? 0.0)") ?? 0.0
        let low = Double("\(data.low ?? 0.0)") ?? 0.0
        let close = Double("\(data.close ?? 0.0)") ?? 0.0
        let open = Double("\(data.open ?? 0.0)") ?? 0.0
        let dateTime = ((data.datetime as? Int) ?? 0) / 1000000000
        let oi = Double("\(data.close_oi ?? 0)") ?? 0.0
        let volume = Double("\(data.volume ?? 0)") ?? 0.0
        let sub = open - close
        let x = Double(index)
        let candleChartDataEntry = CandleChartDataEntry(x: x, shadowH: high, shadowL: low, open: open, close: close)
        let oiEntry = ChartDataEntry(x: x, y: oi)
        let volumeEntry = BarChartDataEntry(x: x, y: volume, data: sub as AnyObject)
        xVals[index] = dateTime
        return [candleChartDataEntry, oiEntry, volumeEntry]
    }

    //生成蜡烛图数据
    private func generateCandleData(candleEntries: [CandleChartDataEntry]) -> CandleChartData {
        let set = CandleChartDataSet(values: candleEntries, label: "kline")
        set.axisDependency = .left
        set.shadowWidth = 0.7
        set.decreasingColor = decreasingColor
        set.decreasingFilled = true
        set.increasingColor = increasingColor
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
    private func generateMALineData() -> LineChartData {
        var sets = [LineChartDataSet]()

        for index in Array(0..<mas.count) {
            let para = mas[index]
            let color = CommonConstants.KLINE_MDs[index]
            sets.append(generateMALineDataSet(para: para, color: color, label: "MA\(para)"))
        }

        let lineData: LineChartData!
        lineData = LineChartData(dataSets: sets)
        return lineData
    }

    //生成均线数据集
    private func generateMALineDataSet(para: Int, color: UIColor, label: String) -> LineChartDataSet {
        var entities = [ChartDataEntry]()
        for index in left_id...last_id {
            if index >= (left_id + para - 1) {
                let entry = generateMALineDataEntry(index: index, lineIndex: para - 1, datas: kline.datas)
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

    //生成成交量数据集
    func generateBarDataSet(entries: [BarChartDataEntry], color: UIColor, label: String, isHighlight: Bool) -> BarChartDataSet {
        let set = BarChartDataSet(values: entries, label: label)
        set.barBorderColor = color
        set.barBorderWidth = 0
        set.colors = [decreasingColor!, increasingColor!]
        set.drawValuesEnabled = false
        set.axisDependency = .left
        if isHighlight {
            set.highlightLineWidth = 0.7
            set.highlightColor = UIColor.white
        } else {
            set.highlightEnabled = false
        }
        return set
    }

    //生成持仓量数据集
    private func generateLineDataSet(entries: [ChartDataEntry], color: UIColor, label: String, isHighlight: Bool, axisDependency: YAxis.AxisDependency) -> LineChartDataSet {
        let set = LineChartDataSet(values: entries, label: label)
        set.setColor(color)
        set.lineWidth = 0.7
        set.drawCirclesEnabled = false
        set.drawCircleHoleEnabled = false
        set.drawValuesEnabled = false
        set.axisDependency = axisDependency
        if isHighlight {
            set.highlightLineWidth = 0.7
            set.highlightColor = UIColor.white
        } else {
            set.highlightEnabled = false
        }
        return set
    }

    //控制均线显示与否
    @objc override func controlAverageLine(notification: Notification) {
        isShowAverageLine = notification.object as! Bool
        if isShowAverageLine {
            topChartViewBase.combinedData?.lineData = maLineData
            topChartViewBase.legend.enabled = true
        } else {
            topChartViewBase.combinedData?.lineData = LineChartData()
            topChartViewBase.legend.enabled = false
        }
        topChartViewBase.combinedData?.notifyDataChanged()
        topChartViewBase.setNeedsDisplay()
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
