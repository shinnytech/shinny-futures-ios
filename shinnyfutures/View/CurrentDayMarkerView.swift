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

    func resizeXib(heiht: CGFloat, width: CGFloat){
        var Rect: CGRect = self.frame
        Rect.size.height = heiht * 0.9
        Rect.size.width = width / 6
        self.frame = Rect
        self.layoutIfNeeded()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 2.0;
        self.layer.masksToBounds = true;
        self.layer.borderColor = UIColor.white.cgColor
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let x = Int(entry.x)
        guard let data = dataManager.sRtnMD.klines[dataManager.sInstrumentId]?[klineType]?.datas["\(x)"] else {return}
        guard let dataPre = dataManager.sRtnMD.klines[dataManager.sInstrumentId]?[klineType]?.datas["\(x-1)"] else {return}
        let chart = self.chartView as! CurrentDayCombinedChartView
        guard let averageEntry = chart.lineData?.dataSets[1].entryForXValue(entry.x, closestToY: entry.y) else {return}
        let closePre = Float("\(dataPre.close ?? 0.0)") ?? 0.0
        let close = Float("\(data.close ?? 0.0)") ?? 0.0
        let datetime = (data.datetime as? Int ?? 0) / 1000000000
        let volume = data.volume as? Int ?? 0
        let volumePre = dataPre.volume as? Int ?? 0
        let closeOi = data.close_oi as? Int ?? 0
        let closeOiPre = dataPre.close_oi as? Int ?? 0
        let dateTime = Date(timeIntervalSince1970: TimeInterval(datetime))
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMdd"
        let yValue = dateformatter.string(from: dateTime)
        dateformatter.dateFormat = "HH:mm"
        let xValue = dateformatter.string(from: dateTime)
        let decimal = dataManager.getDecimalByPtick(instrumentId: dataManager.sInstrumentId)
        let price = String(format: "%.\(decimal)f", close)
        let average = String(format: "%.\(decimal)f", averageEntry.y)
        let change = String(format: "%.\(decimal)f", close - closePre)
        let changePercent = String(format: "%.2f", (close - closePre) / closePre * 100) + "%"

        self.yValue.text = yValue
        self.xValue.text = xValue
        self.price.text = price
        self.average.text = average
        self.change.text = change
        self.changePercent.text = changePercent
        self.volume.text = "\(volume)"
        self.closeOi.text = "\(closeOi)"

        let volumeDelta = volume - volumePre
        self.volumeDalta.text = "\(volumeDelta)"
        if volumeDelta < 0 {
            self.volumeDalta.textColor = CommonConstants.MARK_GREEN
        }else{
            self.volumeDalta.textColor = CommonConstants.MARK_RED
        }

        let closeOiDelta = closeOi - closeOiPre
        self.closeOiDelta.text = "\(closeOiDelta)"
        if closeOiDelta < 0 {
            self.closeOiDelta.textColor = CommonConstants.MARK_GREEN
        }else{
            self.closeOiDelta.textColor = CommonConstants.MARK_RED
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
