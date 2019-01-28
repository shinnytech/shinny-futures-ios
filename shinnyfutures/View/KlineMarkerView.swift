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

    func resizeXib(heiht: CGFloat, width: CGFloat){
        var Rect: CGRect = self.frame
        Rect.size.height = heiht
        Rect.size.width = width / 6
        self.frame = Rect
        self.layoutIfNeeded()
    }

    open override func awakeFromNib() {
        self.layer.borderWidth = 2.0;
        self.layer.masksToBounds = true;
        self.layer.borderColor = UIColor.white.cgColor
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let x = Int(entry.x)
        let duration = "\(dataManager.sRtnMD.charts[CommonConstants.CHART_ID]?.state?.duration ?? "")"
        guard let data = dataManager.sRtnMD.klines[dataManager.sInstrumentId]?[duration]?.datas["\(x)"] else {return}
        guard let dataPre = dataManager.sRtnMD.klines[dataManager.sInstrumentId]?[duration]?.datas["\(x - 1)"] else {return}
        let closePre = Float("\(dataPre.close ?? 0.0)") ?? 0.0
        let close = Float("\(data.close ?? 0.0)") ?? 0.0
        let open = Float("\(data.open ?? 0.0)") ?? 0.0
        let high = Float("\(data.high ?? 0.0)") ?? 0.0
        let low =  Float("\(data.low ?? 0.0)") ?? 0.0
        let datetime = (data.datetime as? Int ?? 0) / 1000000000
        let dateTime = Date(timeIntervalSince1970: TimeInterval(datetime))
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMdd"
        let yValue = dateformatter.string(from: dateTime)
        dateformatter.dateFormat = "HH:mm:ss"
        let xValue = dateformatter.string(from: dateTime)
        let decimal = dataManager.getDecimalByPtick(instrumentId: dataManager.sInstrumentId)
        let change = String(format: "%.\(decimal)f", close - closePre)
        let changePercent = String(format: "%.2f", (close - closePre) / closePre * 100) + "%"
        let volume = data.volume as? Int ?? 0
        let closeOi = data.close_oi as? Int ?? 0
        let closeOiPre = dataPre.close_oi as? Int ?? 0
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

        if open < closePre {
            self.open.textColor = CommonConstants.MARK_GREEN
        }else{
            self.open.textColor = CommonConstants.MARK_RED
        }

        if high < closePre {
            self.high.textColor = CommonConstants.MARK_GREEN
        }else{
            self.high.textColor = CommonConstants.MARK_RED
        }

        if low < closePre {
            self.low.textColor = CommonConstants.MARK_GREEN
        }else{
            self.low.textColor = CommonConstants.MARK_RED
        }

        if close < closePre {
            self.close.textColor = CommonConstants.MARK_GREEN
        }else{
            self.close.textColor = CommonConstants.MARK_RED
        }

        if close - closePre < 0 {
            self.closeChange.textColor = CommonConstants.MARK_GREEN
            self.closeChangePercent.textColor = CommonConstants.MARK_GREEN
        }else {
            self.closeChange.textColor = CommonConstants.MARK_RED
            self.closeChangePercent.textColor = CommonConstants.MARK_RED
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
