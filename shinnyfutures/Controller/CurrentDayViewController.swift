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
    @IBOutlet weak var currentDayChartView: CurrentDayCombinedChartView!
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

    override func viewDidLoad() {
        chartView = currentDayChartView
        super.viewDidLoad()
        
    }
    
    override func initChart() {
        super.initChart()

        colorOneMinuteLine = UIColor.white
        colorAverageLine = UIColor.yellow
        simpleDateFormat = DateFormatter()
        simpleDateFormat.dateFormat = "HH:mm:ss"
        simpleDateFormat.locale = Locale.autoupdatingCurrent

        chartView.setScaleEnabled(false)
        let markerView = CurrentDayMarkerView.viewFromXib()!
        markerView.chartView = chartView
        chartView.marker = markerView

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisLineWidth = 0.5
        xAxis.axisLineColor = colorGrid!
        xAxis.gridColor = colorGrid!
        xAxis.labelTextColor = colorText!
        xAxis.granularity = 1
        xAxis.gridLineWidth = 0.2
        xAxis.valueFormatter = MyXAxisValueFormat(parent: self)

        let rightAxis = chartView.rightAxis
        rightAxis.labelPosition = .insideChart
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawAxisLineEnabled = false
        rightAxis.labelCount = 3
        rightAxis.labelTextColor = colorText!
        rightAxis.valueFormatter = MyRightYAxisValueFormat(parent: self)

        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .insideChart
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelCount = 3
        leftAxis.gridLineWidth = 0.2
        leftAxis.gridLineDashLengths = [2, 2, 2, 2]
        leftAxis.gridLineDashPhase = 0
        leftAxis.gridColor = colorGrid!
        leftAxis.labelTextColor = colorText!
        leftAxis.valueFormatter = MyLeftYAxisValueFormat(parent: self)

        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.textColor = UIColor.white
    }

    override func highlight() {
        let position = doubleTap.location(in: chartView)
        let highlight = chartView.getHighlightByTouchPoint(position)
        chartView.highlightValue(highlight)
        chartView.addGestureRecognizer(singleTap)
    }

    override func Unhighlight() {
        chartView.highlightValue(nil)
        chartView.removeGestureRecognizer(singleTap)
    }

    override func refreshKline() {
        guard let quote = dataManager.sRtnMD.quotes[dataManager.sInstrumentId] else {return}
        guard let kline = dataManager.sRtnMD.klines[dataManager.sInstrumentId]?[klineType] else {return}
        preSettlement = quote.pre_settlement as? Double ?? 0.0
        let last_id_t = kline.last_id as? Int ?? -1
        let datas = kline.datas
        if last_id_t == -1 || datas.isEmpty {return}

        if chartView.data != nil && (chartView.data?.dataSetCount)! > 0 {
            let combineData = chartView.combinedData
            let lineData = combineData?.lineData

            if last_id_t == last_id {
                //NSLog("分时图刷新")
                lineData?.removeEntry(xValue: Double(last_id), dataSetIndex: 0)
                lineData?.removeEntry(xValue: Double(last_id), dataSetIndex: 1)
                guard let volume = sumVolumeDic[last_id] else {return}
                sumVolume -= volume
                guard let cv = sumCVDic[last_id] else {return}
                sumCV -= cv
                let entries = generateLineDataEntry(index: last_id, datas: datas)
                lineData?.addEntry(entries[0], dataSetIndex: 0)
                lineData?.addEntry(entries[1], dataSetIndex: 1)

            } else {
                //NSLog("分时图加载多个数据")
                for index in (last_id + 1)...last_id_t {
                    let entries = generateLineDataEntry(index: index, datas: datas)
                    lineData?.addEntry(entries[0], dataSetIndex: 0)
                    lineData?.addEntry(entries[1], dataSetIndex: 1)
                }
                last_id = last_id_t
            }
            refreshYAxisRange(lineDataSet: lineData?.getDataSetByIndex(0) as! ILineChartDataSet)
            (chartView.xAxis as! MyXAxis).labels = labels
            combineData?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            trading_day_start_id = kline.trading_day_start_id as? Int ?? -1
            trading_day_end_id = kline.trading_day_end_id as? Int ?? -1
            if trading_day_end_id == -1 || trading_day_start_id == -1 {return}
            last_id = last_id_t
            NSLog("分时图初始化")
            (chartView.leftAxis as! MyYAxis).baseValue = preSettlement
            (chartView.rightAxis as! MyYAxis).baseValue = preSettlement
            var oneMinuteList = [ChartDataEntry]()
            var averageList = [ChartDataEntry]()
            let combineData = CombinedChartData()
            for index in trading_day_start_id...last_id {
                let entries = generateLineDataEntry(index: index, datas: datas)
                oneMinuteList.append(entries[0])
                averageList.append(entries[1])
            }
            let oneMinuteDataSet = generateLineDataSet(entries: oneMinuteList, color: colorOneMinuteLine!, label: "分时图", isHighlight: true)
            let averageDataSet = generateLineDataSet(entries: averageList, color: colorAverageLine!, label: "均线", isHighlight: false)
            let lineData = LineChartData(dataSets: [oneMinuteDataSet, averageDataSet])
            combineData.lineData = lineData
            chartView.data = combineData
            (chartView.xAxis as! MyXAxis).labels = labels
            chartView.setVisibleXRangeMinimum(Double(trading_day_end_id - trading_day_start_id))
            (chartView.marker as! CurrentDayMarkerView).resizeXib(heiht: chartView.viewPortHandler.contentHeight)
        }
    }

    private func generateLineDataEntry(index: Int, datas:[String: Kline.Data]) -> [ChartDataEntry] {
        let data = datas["\(index)"]
        let close = data?.close as? Double ?? 0.0
        let volume = data?.volume as? Double ?? 0.0
        let dateTime = (data?.datetime as? Int ?? 0) / 1000000000
        let x = Double(index)
        sumVolume += volume
        sumVolumeDic[index] = volume
        let cv = volume * close
        sumCV += cv
        sumCVDic[index] = cv
        let average = sumVolume != 0 ? (sumCV / sumVolume) : 0
        let oneMinuteEntry = ChartDataEntry(x: x, y: close)
        let averageEntry = ChartDataEntry(x: x, y: average)
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
        return [oneMinuteEntry, averageEntry]
    }

    private func generateLineDataSet(entries: [ChartDataEntry], color: UIColor, label: String, isHighlight: Bool) -> LineChartDataSet {
        let set = LineChartDataSet(values: entries, label: label)
        set.setColor(color)
        set.lineWidth = 0.7
        set.drawCirclesEnabled = false
        set.drawCircleHoleEnabled = false
        set.drawValuesEnabled = false
        set.axisDependency = .left
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
            chartView.leftAxis.axisMinimum = preSettlement - lowDel
            chartView.rightAxis.axisMinimum = preSettlement - lowDel
            chartView.leftAxis.axisMaximum = preSettlement + lowDel
            chartView.rightAxis.axisMaximum = preSettlement + lowDel
        }else {
            chartView.leftAxis.axisMinimum = preSettlement - highDel
            chartView.rightAxis.axisMinimum = preSettlement - highDel
            chartView.leftAxis.axisMaximum = preSettlement + highDel
            chartView.rightAxis.axisMaximum = preSettlement + highDel
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
