//
//  KlineCombinedChartView.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/24.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

class KlineCombinedChartView: CombinedChartView {

    override func initialize() {
        super.initialize()
        
        _xAxis = MyXAxis()
        xAxisRenderer = KlineXAxisRenderer(viewPortHandler: viewPortHandler, xAxis: _xAxis as? MyXAxis, transformer: getTransformer(forAxis: .left))

        leftAxis = MyYAxis(position: .left)
        leftYAxisRenderer = KlineYAxisRenderer(viewPortHandler: viewPortHandler, yAxis: leftAxis as? MyYAxis, transformer: getTransformer(forAxis: .left))

        rightAxis = MyYAxis(position: .right)
        rightYAxisRenderer = KlineYAxisRenderer(viewPortHandler: viewPortHandler, yAxis: rightAxis as? MyYAxis, transformer: getTransformer(forAxis: .right))

        renderer = MyCombinedChartRenderer(chart: self, animator: _animator, viewPortHandler: viewPortHandler)
    }

    //k线图画框打补丁，只画顶部线
    override func drawGridBackground(context: CGContext) {
        if drawGridBackgroundEnabled || drawBordersEnabled
        {
            context.saveGState()
        }

        if drawGridBackgroundEnabled
        {
            // draw the grid background
            context.setFillColor(gridBackgroundColor.cgColor)
            context.fill(_viewPortHandler.contentRect)
        }

        if drawBordersEnabled
        {
            context.setLineWidth(0.5)
            context.setStrokeColor(borderColor.cgColor)
            context.strokeLineSegments(between: [CGPoint(x: 0, y: viewPortHandler.offsetTop), CGPoint(x: viewPortHandler.chartWidth, y: viewPortHandler.offsetTop)])
        }

        if drawGridBackgroundEnabled || drawBordersEnabled
        {
            context.restoreGState()
        }
    }

    //marker补丁，解决k线图前端跳动时marker消失十字光标依然存在问题
    open override func drawMarkers(context: CGContext) {

        // if there is no marker view or drawing marker is disabled
        guard
            let marker = marker
            , isDrawMarkersEnabled &&
                valuesToHighlight()
            else { return }

        for highlight in _indicesToHighlight
        {

            guard let
                set = combinedData?.getDataSetByIndex(highlight.dataSetIndex),
                let e = entryForHighlight(highlight)
                else { continue }

            let entryIndex = set.entryIndex(entry: e)
            if entryIndex > Int(Double(set.entryCount) * _animator.phaseX)
            {
                continue
            }

            let pos = getMarkerPosition(highlight: highlight)

            // check bounds
            if !_viewPortHandler.isInBounds(x: pos.x, y: pos.y)
            {
                continue
            }

            // callbacks to update the content
            marker.refreshContent(entry: e, highlight: highlight)

            // draw the marker
            marker.draw(context: context, point: pos)
        }
    }

    /// Get the Entry for a corresponding highlight object
    ///
    /// - parameter highlight:
    /// - returns: The entry that is highlighted
    @objc open func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry?
    {
        guard let dataObjects = combinedData?.allData else {return nil}
        if highlight.dataIndex >= dataObjects.count {
            return nil
        }

        let chartData = dataObjects[highlight.dataIndex]

        if highlight.dataSetIndex >= chartData.dataSetCount
        {
            return nil
        }
        else
        {
            let entries = chartData.getDataSetByIndex(highlight.dataSetIndex).entriesForXValue(highlight.x)
            return entries[0]
        }
    }
}
