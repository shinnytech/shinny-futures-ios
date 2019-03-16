//
//  MyLineChartRenderer.swift
//  shinnyfutures
//
//  Created by chenli on 2019/3/3.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import Foundation
import CoreGraphics
import Charts

#if !os(OSX)
import UIKit
#endif

open class MyLineChartRenderer: LineChartRenderer
{
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData
            else { return }

        let chartXMax = dataProvider.chartXMax

        context.saveGState()

        for high in indices
        {
            guard let set = lineData.getDataSetByIndex(high.dataSetIndex) as? ILineChartDataSet
                , set.isHighlightEnabled
                else { continue }

            guard let e = set.entryForXValue(high.x, closestToY: high.y) else { continue }

            if !isInBoundsX(entry: e, dataSet: set)
            {
                continue
            }

            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            if set.highlightLineDashLengths != nil
            {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }

            let x = high.x // get the x-position
            let y = high.y * Double(animator.phaseY)

            if x > chartXMax * animator.phaseX
            {
                continue
            }

            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)

            let pt = trans.pixelForValues(x: x, y: y)
            let xp = pt.x
            let xMax = viewPortHandler.contentRight

            // draw vertical highlight lines
            context.beginPath()
            context.move(to: CGPoint(x: xp, y: 15))
            context.addLine(to: CGPoint(x: xp, y: viewPortHandler.chartHeight))
            context.strokePath()

            let drawY = high.drawY
            if drawY >= 0 && drawY <= viewPortHandler.contentBottom{
                // draw horizontal highlight lines
                context.beginPath()
                context.move(to: CGPoint(x: 0, y: drawY))
                context.addLine(to: CGPoint(x: xMax, y: drawY))
                context.strokePath()        }

            }

        context.restoreGState()
    }

    open override func drawValues(context: CGContext) {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData
            else { return }

        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            var dataSets = lineData.dataSets

            let phaseY = animator.phaseY

            var pt = CGPoint()

            for i in 0 ..< dataSets.count
            {
                guard let dataSet = dataSets[i] as? ILineChartDataSet else { continue }

                if dataSet.entryCount == 0{return}

                if !shouldDrawValues(forDataSet: dataSet)
                {
                    continue
                }

                let valueFont = dataSet.valueFont

                guard let formatter = dataSet.valueFormatter else { continue }

                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix

                let iconsOffset = dataSet.iconsOffset

                // make sure the values do not interfear with the circles
                var valOffset = Int(dataSet.circleRadius * 1.75)

                if !dataSet.isDrawCirclesEnabled
                {
                    valOffset = valOffset / 2
                }

                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)

                for j in stride(from: _xBounds.min, through: min(_xBounds.min + _xBounds.range, _xBounds.max), by: 1)
                {
                    guard let e = dataSet.entryForIndex(j) else { break }

                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)

                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }

                    if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }

                    if dataSet.isDrawValuesEnabled {
                        ChartUtils.drawText(
                            context: context,
                            text: formatter.stringForValue(
                                e.y,
                                entry: e,
                                dataSetIndex: i,
                                viewPortHandler: viewPortHandler),
                            point: CGPoint(
                                x: pt.x,
                                y: pt.y - CGFloat(valOffset) - valueFont.lineHeight),
                            align: .center,
                            attributes: [NSAttributedStringKey.font: valueFont, NSAttributedStringKey.foregroundColor: dataSet.valueTextColorAt(j)])
                    }

                    if let icon = e.icon, dataSet.isDrawIconsEnabled
                    {
                        ChartUtils.drawImage(context: context,
                                             image: icon,
                                             x: pt.x + iconsOffset.x,
                                             y: pt.y + iconsOffset.y,
                                             size: icon.size)
                    }
                }
            }
        }
    }
}
