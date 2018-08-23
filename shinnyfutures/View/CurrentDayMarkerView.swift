//
//  CurrentDayMarkerView.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/23.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import Foundation
import Charts

open class CurrentDayMarkerView: MarkerView {

    // MARK: Properties:
    @IBOutlet weak var yValue: UILabel!
    @IBOutlet weak var xValue: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var average: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var changePercent: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var volumeDalta: UILabel!
    @IBOutlet weak var closeOi: UILabel!
    @IBOutlet weak var closeOiDelta: UILabel!
    var markerViewState = "right"
    let dataManager = DataManager.getInstance()
    let klineType = CommonConstants.CURRENT_DAY

    open override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 2.0;
        self.layer.masksToBounds = true;
        self.layer.borderColor = UIColor.white.cgColor
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let x = Int(entry.x)
        let data = dataManager.sRtnMD[RtnMDConstants.klines][dataManager.sInstrumentId][klineType][KlineConstants.data]["\(x)"]
        let chart = self.chartView as! CurrentDayCombinedChartView
        guard let averageEntry = chart.lineData?.dataSets[1].entryForXValue(entry.x, closestToY: entry.y) else {return}
        let dataPre = dataManager.sRtnMD[RtnMDConstants.klines][dataManager.sInstrumentId][klineType][KlineConstants.data]["\(x-1)"]
        if !data.isEmpty && !dataPre.isEmpty {
            let closePre = dataPre[KlineConstants.close].floatValue
            let close = data[KlineConstants.close].floatValue
            let dateTime = Date(timeIntervalSince1970: TimeInterval(data[KlineConstants.datetime].intValue / 1000000000))
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            let yValue = dateformatter.string(from: dateTime)
            dateformatter.dateFormat = "HH:mm"
            let xValue = dateformatter.string(from: dateTime)
            let decimal = dataManager.getDecimalByPtick(instrumentId: dataManager.sInstrumentId)
            let price = String(format: "%.\(decimal)f", data[KlineConstants.close].floatValue)
            let average = String(format: "%.\(decimal)f", averageEntry.y)
            let change = String(format: "%.\(decimal)f", close - closePre)
            let changePercent = String(format: "%.2f", (close - closePre) / closePre * 100) + "%"
            let volume = data[KlineConstants.volume].intValue
            let closeOi = data[KlineConstants.close_oi].intValue
            self.yValue.text = yValue
            self.xValue.text = xValue
            self.price.text = price
            self.average.text = average
            self.change.text = change
            self.changePercent.text = changePercent
            self.volume.text = "\(volume)"
            self.closeOi.text = "\(closeOi)"

            if !dataPre.isEmpty{
                let volumeDelta = volume - dataPre[KlineConstants.volume].intValue
                self.volumeDalta.text = "\(volumeDelta)"
                if volumeDelta < 0 {
                    self.volumeDalta.textColor = UIColor.green
                }else{
                    self.volumeDalta.textColor = UIColor.red
                }

                let closeOiDelta = closeOi - dataPre[KlineConstants.close_oi].intValue
                self.closeOiDelta.text = "\(closeOiDelta)"
                if closeOiDelta < 0 {
                    self.closeOiDelta.textColor = UIColor.green
                }else{
                    self.closeOiDelta.textColor = UIColor.red
                }
            }else{
                self.volumeDalta.text = "-"
                self.closeOiDelta.text = "-"
                self.closeOiDelta.textColor = UIColor.white
                self.volumeDalta.textColor = UIColor.white
            }
        }
        super.refreshContent(entry: entry, highlight: highlight)
    }

    open override func draw(context: CGContext, point: CGPoint) {
        guard let chart = chartView else { return }
        var pointModified = CGPoint(x: 0, y: chart.viewPortHandler.offsetTop)
        let width = self.bounds.size.width
        let deadlineRight = chart.bounds.size.width - width
        let deadlineLeft = width
        let posX = point.x
        if posX <= deadlineLeft {
            pointModified.x = deadlineRight
            markerViewState = "right"
        } else if posX >= deadlineRight {
            pointModified.x = 0
            markerViewState = "left"
        } else {
            if markerViewState.elementsEqual("right") {
                pointModified.x = deadlineRight
            } else {
                pointModified.x = 0
            }
        }

        super.draw(context: context, point: pointModified)
    }
}
