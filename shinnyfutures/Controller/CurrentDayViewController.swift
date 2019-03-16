//
//  CurrentDayViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/10.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

class CurrentDayViewController: BaseChartViewController {

    // MARK: Properties
    @IBOutlet weak var topChartView: CurrentDayCombinedChartView!
    @IBOutlet weak var middleChartView: CurrentDayCombinedChartView!
    @IBOutlet weak var bottomChartView: CurrentDayCombinedChartView!
    var colorOneMinuteLine: UIColor?
    var colorAverageLine: UIColor?
    var sumVolume = 0.0
    var sumVolumeDic = [Int: Double]()
    var sumCV = 0.0
    var sumCVDic = [Int: Double]()
    var startIndex = 0
    var endIndex = 0
    var trading_day_start_id = -1
    var trading_day_end_id = -1
    var last_id = -1
    var labels = [Int: String]()
    var preSettlement = 1.0
    var kline: Kline!

    override func viewDidLoad() {
        topChartViewBase = topChartView
        middleChartViewBase = middleChartView
        bottomChartViewBase = bottomChartView
        super.viewDidLoad()
        
    }
    
    override func initChart() {
        super.initChart()

        colorOneMinuteLine = UIColor.white
        colorAverageLine = UIColor.yellow
        simpleDateFormat = DateFormatter()
        simpleDateFormat.dateFormat = "HH:mm"
        simpleDateFormat.locale = Locale.autoupdatingCurrent

        topChartViewBase.setScaleEnabled(false)
        let markerView = CurrentDayMarkerView.viewFromXib()!
        markerView.chartView = topChartViewBase
        topChartViewBase.marker = markerView

        let xAxis = topChartViewBase.xAxis
        xAxis.drawLabelsEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.gridColor = colorGrid!
        xAxis.axisLineColor = colorGrid!
        xAxis.gridLineWidth = 0.2
        xAxis.labelPosition = .bottom

        let rightAxis = topChartViewBase.rightAxis
        rightAxis.labelPosition = .insideChart
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawAxisLineEnabled = false
        rightAxis.labelCount = 3
        rightAxis.labelTextColor = colorText!
        rightAxis.valueFormatter = MyRightYAxisValueFormat(parent: self)

        let leftAxis = topChartViewBase.leftAxis
        leftAxis.labelPosition = .insideChart
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelCount = 3
        leftAxis.gridLineWidth = 0.2
        leftAxis.gridLineDashLengths = [2, 2, 2, 2]
        leftAxis.gridLineDashPhase = 0
        leftAxis.gridColor = colorGrid!
        leftAxis.labelTextColor = colorText!
        leftAxis.valueFormatter = MyLeftYAxisValueFormat(parent: self)

        let l = topChartViewBase.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.textColor = UIColor.white


        middleChartViewBase.setScaleEnabled(false)

        let middleXAxis = middleChartViewBase.xAxis
        middleXAxis.drawLabelsEnabled = true
        middleXAxis.drawAxisLineEnabled = true
        middleXAxis.gridColor = colorGrid!
        middleXAxis.gridLineWidth = 0.2
        middleXAxis.labelPosition = .bottom
        middleXAxis.axisLineColor = colorGrid!
        middleXAxis.labelTextColor = colorText!
        middleXAxis.axisLineWidth = 1

        let middleRightAxis = middleChartViewBase.rightAxis
        middleRightAxis.drawLabelsEnabled = false
        middleRightAxis.drawAxisLineEnabled = false
        middleRightAxis.drawGridLinesEnabled = false

        let middleLeftAxis = middleChartViewBase.leftAxis
        middleLeftAxis.labelPosition = .insideChart
        middleLeftAxis.drawAxisLineEnabled = false
        middleLeftAxis.gridLineWidth = 0.2
        middleLeftAxis.gridLineDashLengths = [2, 2, 2, 2]
        middleLeftAxis.gridLineDashPhase = 0
        middleLeftAxis.gridColor = colorGrid!
        middleLeftAxis.labelTextColor = colorText!
        middleLeftAxis.labelCount = 4
        middleLeftAxis.axisMinimum = 0
        middleLeftAxis.spaceBottom = 0

        let middleLegend = middleChartViewBase.legend
        middleLegend.enabled = false

    }
    
    override func refreshKline() {
        
        if topChartViewBase.data != nil && (topChartViewBase.data?.dataSetCount)! > 0 {
            let topCombineData = topChartViewBase.combinedData
            let topLineData = topCombineData?.lineData

            let middleCombineData = middleChartView.combinedData
            let middleLineData = middleCombineData?.lineData
            let middleBarData = middleCombineData?.barData

            let last_id_t = kline.last_id as? Int ?? -1
            let datas = kline.datas

            if last_id_t == last_id {
                //NSLog("分时图刷新")
                guard let data = datas["\(last_id)"] else {return}
                topLineData?.removeEntry(xValue: Double(last_id), dataSetIndex: 0)
                topLineData?.removeEntry(xValue: Double(last_id), dataSetIndex: 1)
                middleLineData?.removeEntry(xValue: Double(last_id), dataSetIndex: 0)
                middleBarData?.removeEntry(xValue: Double(last_id), dataSetIndex: 0)
                guard let volume = sumVolumeDic[last_id] else {return}
                sumVolume -= volume
                guard let cv = sumCVDic[last_id] else {return}
                sumCV -= cv
                let entries = generateMultiDataEntry(index: last_id, data: data)
                topLineData?.addEntry(entries[0], dataSetIndex: 0)
                topLineData?.addEntry(entries[1], dataSetIndex: 1)
                middleLineData?.addEntry(entries[2], dataSetIndex: 0)
                middleBarData?.addEntry(entries[3], dataSetIndex: 0)

            } else if last_id_t > last_id{
                //NSLog("分时图加载多个数据")
                for index in (last_id + 1)...last_id_t {
                    guard let data = datas["\(index)"] else {continue}
                    let entries = generateMultiDataEntry(index: index, data: data)
                    topLineData?.addEntry(entries[0], dataSetIndex: 0)
                    topLineData?.addEntry(entries[1], dataSetIndex: 1)
                    middleLineData?.addEntry(entries[2], dataSetIndex: 0)
                    middleBarData?.addEntry(entries[3], dataSetIndex: 0)
                }
                last_id = last_id_t
            }
            refreshYAxisRange(lineDataSet: topLineData?.getDataSetByIndex(0) as! ILineChartDataSet)
            let range = Double(trading_day_end_id - trading_day_start_id)


            topCombineData?.notifyDataChanged()
            topChartViewBase.notifyDataSetChanged()
            topChartViewBase.setVisibleXRangeMinimum(range)
            topChartViewBase.xAxis.axisMinimum = topCombineData?.xMin ?? 0 - 0.35
            topChartViewBase.xAxis.axisMaximum = topCombineData?.xMax ?? 0 + 0.35
            (topChartViewBase.xAxis as! MyXAxis).labels = labels

            middleCombineData?.notifyDataChanged()
            middleChartViewBase.notifyDataSetChanged()
            middleChartViewBase.setVisibleXRangeMinimum(range)
            middleChartViewBase.xAxis.axisMinimum = middleCombineData?.xMin ?? 0 - 0.35
            middleChartViewBase.xAxis.axisMaximum = middleCombineData?.xMax ?? 0 + 0.35
            (middleChartViewBase.xAxis as! MyXAxis).labels = labels

        } else {
            guard let quote = dataManager.sRtnMD.quotes[dataManager.sInstrumentId] else {return}
            guard let kline = dataManager.sRtnMD.klines[dataManager.sInstrumentId]?[klineType] else {return}
            self.kline = kline
            let last_id_t = kline.last_id as? Int ?? -1
            let datas = kline.datas
            if last_id_t == -1 || datas.isEmpty {return}
            trading_day_start_id = kline.trading_day_start_id as? Int ?? -1
            trading_day_end_id = kline.trading_day_end_id as? Int ?? -1
            if trading_day_end_id == -1 || trading_day_start_id == -1 {return}
            last_id = last_id_t
            preSettlement = quote.pre_settlement as? Double ?? 1.0
            let range = Double(trading_day_end_id - trading_day_start_id)
            NSLog("分时图初始化")
            (topChartViewBase.leftAxis as! MyYAxis).baseValue = preSettlement
            (topChartViewBase.rightAxis as! MyYAxis).baseValue = preSettlement
            (middleChartViewBase.leftAxis as! MyYAxis).baseValue = 0
            (middleChartViewBase.rightAxis as! MyYAxis).baseValue = 0
            var oneMinuteEntries = [ChartDataEntry]()
            var averageEntries = [ChartDataEntry]()
            let topCombineData = CombinedChartData()
            var oiEntries = [ChartDataEntry]()
            var volumeEntries = [BarChartDataEntry]()
            let middleCombineData = CombinedChartData()
            for index in trading_day_start_id...last_id {
                guard let data = datas["\(index)"] else {continue}
                let entries = generateMultiDataEntry(index: index, data: data)
                oneMinuteEntries.append(entries[0])
                averageEntries.append(entries[1])
                oiEntries.append(entries[2])
                volumeEntries.append(entries[3] as! BarChartDataEntry)
            }

            let oneMinuteDataSet = generateLineDataSet(entries: oneMinuteEntries, color: colorOneMinuteLine!, label: "分时图", isHighlight: true, axisDependency: .left)
            let averageDataSet = generateLineDataSet(entries: averageEntries, color: colorAverageLine!, label: "均线", isHighlight: false, axisDependency: .left)
            let lineData = LineChartData(dataSets: [oneMinuteDataSet, averageDataSet])
            topCombineData.lineData = lineData

            let oiDataSet = generateLineDataSet(entries: oiEntries, color: colorOneMinuteLine!, label: "OI", isHighlight: false, axisDependency: .right)
            let volumeDataSet = generateBarDataSet(entries: volumeEntries, color: colorAverageLine!, label: "Volume", isHighlight: true)
            let oiLineData = LineChartData(dataSet: oiDataSet)
            let volumeBarData = BarChartData(dataSet: volumeDataSet)
            middleCombineData.lineData = oiLineData
            middleCombineData.barData = volumeBarData
            middleCombineData.barData.barWidth = 0.01

            topChartViewBase.data = topCombineData
            (topChartViewBase.xAxis as! MyXAxis).labels = labels
            topChartViewBase.setVisibleXRangeMinimum(range)
            topChartViewBase.xAxis.axisMinimum = topCombineData.xMin - 0.35
            topChartViewBase.xAxis.axisMaximum = topCombineData.xMax + 0.35
            (topChartViewBase.marker as! CurrentDayMarkerView).resizeXib(heiht: topChartViewBase.viewPortHandler.contentHeight, width: topChartViewBase.viewPortHandler.contentWidth)

            middleChartViewBase.data = middleCombineData
            (middleChartViewBase.xAxis as! MyXAxis).labels = labels
            middleChartViewBase.setVisibleXRangeMinimum(range)
            middleChartViewBase.xAxis.axisMinimum = middleCombineData.xMin - 0.35
            middleChartViewBase.xAxis.axisMaximum = middleCombineData.xMax + 0.35

        }
    }


    private func generateMultiDataEntry(index: Int, data: Kline.Data) -> [ChartDataEntry] {
        let oi = Double("\(data.close_oi ?? 0)") ?? 0.0
        let volume = Double("\(data.volume ?? 0)") ?? 0.0
        let close = Double("\(data.close ?? 0.0)") ?? 0.0
        let dateTime = (data.datetime as? Int ?? 0) / 1000000000
        let x = Double(index)
        sumVolume += volume
        sumVolumeDic[index] = volume
        let cv = volume * close
        sumCV += cv
        sumCVDic[index] = cv
        let average = sumVolume != 0 ? (sumCV / sumVolume) : 0
        let oneMinuteEntry = ChartDataEntry(x: x, y: close)
        let averageEntry = ChartDataEntry(x: x, y: average)
        let oiEntry = ChartDataEntry(x: x, y: oi)
        let volumeEntry = BarChartDataEntry(x: x, y: volume)
        xVals[index] = dateTime
        let date = Date(timeIntervalSince1970: TimeInterval(dateTime))
        let time = simpleDateFormat.string(from: date)
        if index == trading_day_start_id {
            labels[index] = time
        }else if index == trading_day_end_id {
            let dateEnd = Date(timeIntervalSince1970: TimeInterval(dateTime + 60))
            let timeEnd = simpleDateFormat.string(from: dateEnd)
            labels[index] = timeEnd
        }else if let dateTimePre = xVals[index - 1]{
            if (dateTime - dateTimePre) != 60 {
                labels[index] = time
            }
        }
        return [oneMinuteEntry, averageEntry, oiEntry, volumeEntry]
    }

    //生成成交量数据集
    func generateBarDataSet(entries: [BarChartDataEntry], color: UIColor, label: String, isHighlight: Bool) -> BarChartDataSet {
        let set = BarChartDataSet(values: entries, label: label)
        set.barBorderColor = color
        set.colors = [color]
        set.barBorderWidth = 0
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
            refreshYAxisRange(lineDataSet: set)
            set.highlightLineWidth = 0.7
            set.highlightColor = UIColor.white
        } else {
            set.highlightEnabled = false
        }
        return set
    }

    private func refreshYAxisRange(lineDataSet: ILineChartDataSet){
        let lowDel = abs(lineDataSet.yMin - preSettlement)
        let highDel = abs(lineDataSet.yMax - preSettlement)
        if lowDel > highDel {
            topChartViewBase.leftAxis.axisMinimum = preSettlement - lowDel
            topChartViewBase.rightAxis.axisMinimum = preSettlement - lowDel
            topChartViewBase.leftAxis.axisMaximum = preSettlement + lowDel
            topChartViewBase.rightAxis.axisMaximum = preSettlement + lowDel
        }else {
            topChartViewBase.leftAxis.axisMinimum = preSettlement - highDel
            topChartViewBase.rightAxis.axisMinimum = preSettlement - highDel
            topChartViewBase.leftAxis.axisMaximum = preSettlement + highDel
            topChartViewBase.rightAxis.axisMaximum = preSettlement + highDel
        }
    }

    override func clearChartView() {
        sumCV = 0.0
        sumCVDic.removeAll()
        sumVolume = 0.0
        sumVolumeDic.removeAll()
        labels.removeAll()
        super.clearChartView()
    }

    //格式化右Y轴数据
    class MyRightYAxisValueFormat: IAxisValueFormatter {

        weak var parent: CurrentDayViewController!

        init(parent: CurrentDayViewController) {
            self.parent = parent
        }

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let number = (value - parent.preSettlement) / parent.preSettlement * 100
            let data = String(format: "%.2f", number) + "%"
            return data
        }
    }

    //格式化左Y轴数据
    class MyLeftYAxisValueFormat: IAxisValueFormatter {

        weak var parent: CurrentDayViewController!

        init(parent: CurrentDayViewController) {
            self.parent = parent
        }

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let decimal = parent.dataManager.getDecimalByPtick(instrumentId: parent.dataManager.sInstrumentId)
            let data = String(format: "%.\(decimal)f", value)
            return data
        }
    }

    //格式化X轴数据
    class MyXAxisValueFormat: IAxisValueFormatter {

        weak var parent: CurrentDayViewController!

        init(parent: CurrentDayViewController) {
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
}
