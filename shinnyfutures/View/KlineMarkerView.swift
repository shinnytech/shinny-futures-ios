//
//  KlineMarkerView.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/23.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import Foundation
import Charts

open class KlineMarkerView: MarkerView {

    // MARK: Properties
    @IBOutlet weak var yValue: UILabel!
    @IBOutlet weak var xValue: UILabel!
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var low: UILabel!
    @IBOutlet weak var close: UILabel!
    @IBOutlet weak var closeChange: UILabel!
    @IBOutlet weak var closeChangePercent: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var closeOi: UILabel!
    @IBOutlet weak var closeOiDelta: UILabel!
    var markerViewState = "right"
    let dataManager = DataManager.getInstance()
    var klineType = ""

    open override func awakeFromNib() {
        self.layer.borderWidth = 2.0;
        self.layer.masksToBounds = true;
        self.layer.borderColor = UIColor.white.cgColor
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let x = Int(entry.x)
        let chart = self.chartView as! KlineCombinedChartView
        klineType = chart.klineType
        let data = dataManager.sRtnMD[RtnMDConstants.klines][dataManager.sInstrumentId][klineType][KlineConstants.data]["\(x)"]
        let dataPre = dataManager.sRtnMD[RtnMDConstants.klines][dataManager.sInstrumentId][klineType][KlineConstants.data]["\(x-1)"]
        let preSettlement = dataManager.sRtnMD[RtnMDConstants.quotes][dataManager.sInstrumentId][QuoteConstants.pre_settlement].floatValue
        if !data.isEmpty && preSettlement != 0{
            let close = data[KlineConstants.close].floatValue
            let open = data[KlineConstants.open].floatValue
            let high = data[KlineConstants.high].floatValue
            let low =  data[KlineConstants.low].floatValue
            let dateTime = Date(timeIntervalSince1970: TimeInterval(data[KlineConstants.datetime].intValue / 1000000000))
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            let yValue = dateformatter.string(from: dateTime)
            dateformatter.dateFormat = "HH:mm"
            let xValue = dateformatter.string(from: dateTime)
            let decimal = dataManager.getDecimalByPtick(instrumentId: dataManager.sInstrumentId)
            let change = String(format: "%.\(decimal)f", close - preSettlement)
            let changePercent = String(format: "%.\(decimal)f", (close - preSettlement) / preSettlement * 100) + "%"
            let volume = data[KlineConstants.volume].intValue
            let closeOi = data[KlineConstants.close_oi].intValue
            self.yValue.text = yValue
            self.xValue.text = xValue
            self.high.text = String(format: "%.\(decimal)f", high)
            self.open.text = String(format: "%.\(decimal)f", open)
            self.low.text = String(format: "%.\(decimal)f", low)
            self.close.text = String(format: "%.\(decimal)f", close)
            self.closeChange.text = change
            self.closeChangePercent.text = changePercent
            self.volume.text = "\(volume)"
            self.closeOi.text = "\(closeOi)"
            if !dataPre.isEmpty{
                let closeOiDelta = closeOi - dataPre[KlineConstants.close_oi].intValue
                self.closeOiDelta.text = "\(closeOiDelta)"
                if closeOiDelta < 0 {
                    self.closeOiDelta.textColor = UIColor.green
                }else{
                    self.closeOiDelta.textColor = UIColor.red
                }
            }else{
                self.closeOiDelta.text = "-"
                self.closeOiDelta.textColor = UIColor.white
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
