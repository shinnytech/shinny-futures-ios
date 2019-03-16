//
//  MyCandleStickChartRenderer.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/24.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts
import CoreGraphics

//蜡烛图渲染器，给图添加最大最小标志
open class MyCandleStickChartRenderer: CandleStickChartRenderer {
    
    private var _shadowPoints = [CGPoint](repeating: CGPoint(), count: 4)
    private var _rangePoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _openPoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _closePoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _bodyRect = CGRect()
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)

    override init(dataProvider: CandleChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler) {
        super.init(dataProvider: dataProvider, animator: animator, viewPortHandler: viewPortHandler)
    }

    //柱子刻画打补丁，半个柱子会被挡住
    override open func drawDataSet(context: CGContext, dataSet: ICandleChartDataSet) {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        let barSpace = dataSet.barSpace
        let showCandleBar = dataSet.showCandleBar

        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        
        context.setLineWidth(dataSet.shadowWidth)
        
        for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { continue }
            
            let xPos = e.x
            
            let open = e.open
            let close = e.close
            let high = e.high
            let low = e.low
            
            if showCandleBar
            {
                // calculate the shadow
                
                _shadowPoints[0].x = CGFloat(xPos)
                _shadowPoints[1].x = CGFloat(xPos)
                _shadowPoints[2].x = CGFloat(xPos)
                _shadowPoints[3].x = CGFloat(xPos)
                
                if open > close
                {
                    _shadowPoints[0].y = CGFloat(high * phaseY)
                    _shadowPoints[1].y = CGFloat(open * phaseY)
                    _shadowPoints[2].y = CGFloat(low * phaseY)
                    _shadowPoints[3].y = CGFloat(close * phaseY)
                }
                else if open < close
                {
                    _shadowPoints[0].y = CGFloat(high * phaseY)
                    _shadowPoints[1].y = CGFloat(close * phaseY)
                    _shadowPoints[2].y = CGFloat(low * phaseY)
                    _shadowPoints[3].y = CGFloat(open * phaseY)
                }
                else
                {
                    _shadowPoints[0].y = CGFloat(high * phaseY)
                    _shadowPoints[1].y = CGFloat(open * phaseY)
                    _shadowPoints[2].y = CGFloat(low * phaseY)
                    _shadowPoints[3].y = _shadowPoints[1].y
                }
                
                trans.pointValuesToPixel(&_shadowPoints)
                
                // draw the shadows
                
                var shadowColor: NSUIColor! = nil
                if dataSet.shadowColorSameAsCandle
                {
                    if open > close
                    {
                        shadowColor = dataSet.decreasingColor ?? dataSet.color(atIndex: j)
                    }
                    else if open < close
                    {
                        shadowColor = dataSet.increasingColor ?? dataSet.color(atIndex: j)
                    }
                    else
                    {
                        shadowColor = dataSet.neutralColor ?? dataSet.color(atIndex: j)
                    }
                }
                
                if shadowColor === nil
                {
                    shadowColor = dataSet.shadowColor ?? dataSet.color(atIndex: j)
                }
                
                context.setStrokeColor(shadowColor.cgColor)
                context.strokeLineSegments(between: _shadowPoints)
                
                // calculate the body
                
                _bodyRect.origin.x = CGFloat(xPos) - 0.5 + barSpace
                _bodyRect.origin.y = CGFloat(close * phaseY)
                _bodyRect.size.width = (CGFloat(xPos) + 0.5 - barSpace) - _bodyRect.origin.x
                _bodyRect.size.height = CGFloat(open * phaseY) - _bodyRect.origin.y
                
                trans.rectValueToPixel(&_bodyRect)
                
                // draw body differently for increasing and decreasing entry
                
                if open > close
                {
                    let color = dataSet.decreasingColor ?? dataSet.color(atIndex: j)
                    
                    if dataSet.isDecreasingFilled
                    {
                        context.setFillColor(color.cgColor)
                        context.fill(_bodyRect)
                    }
                    else
                    {
                        context.setStrokeColor(color.cgColor)
                        context.stroke(_bodyRect)
                    }
                }
                else if open < close
                {
                    let color = dataSet.increasingColor ?? dataSet.color(atIndex: j)
                    
                    if dataSet.isIncreasingFilled
                    {
                        context.setFillColor(color.cgColor)
                        context.fill(_bodyRect)
                    }
                    else
                    {
                        context.setStrokeColor(color.cgColor)
                        context.stroke(_bodyRect)
                    }
                }
                else
                {
                    let color = dataSet.neutralColor ?? dataSet.color(atIndex: j)
                    
                    context.setStrokeColor(color.cgColor)
                    context.stroke(_bodyRect)
                }
            }
            else
            {
                _rangePoints[0].x = CGFloat(xPos)
                _rangePoints[0].y = CGFloat(high * phaseY)
                _rangePoints[1].x = CGFloat(xPos)
                _rangePoints[1].y = CGFloat(low * phaseY)
                
                _openPoints[0].x = CGFloat(xPos) - 0.5 + barSpace
                _openPoints[0].y = CGFloat(open * phaseY)
                _openPoints[1].x = CGFloat(xPos)
                _openPoints[1].y = CGFloat(open * phaseY)
                
                _closePoints[0].x = CGFloat(xPos) + 0.5 - barSpace
                _closePoints[0].y = CGFloat(close * phaseY)
                _closePoints[1].x = CGFloat(xPos)
                _closePoints[1].y = CGFloat(close * phaseY)
                
                trans.pointValuesToPixel(&_rangePoints)
                trans.pointValuesToPixel(&_openPoints)
                trans.pointValuesToPixel(&_closePoints)
                
                // draw the ranges
                var barColor: NSUIColor! = nil
                
                if open > close
                {
                    barColor = dataSet.decreasingColor ?? dataSet.color(atIndex: j)
                }
                else if open < close
                {
                    barColor = dataSet.increasingColor ?? dataSet.color(atIndex: j)
                }
                else
                {
                    barColor = dataSet.neutralColor ?? dataSet.color(atIndex: j)
                }
                
                context.setStrokeColor(barColor.cgColor)
                context.strokeLineSegments(between: _rangePoints)
                context.strokeLineSegments(between: _openPoints)
                context.strokeLineSegments(between: _closePoints)
            }
        }
        
        context.restoreGState()
    }

    //标出最大值最小值
    open override func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let candleData = dataProvider.candleData
            else { return }

        var dataSets = candleData.dataSets

        let phaseY = animator.phaseY

        var minPt = CGPoint()
        var maxPt = CGPoint()

        for i in 0 ..< dataSets.count
        {
            guard let dataSet = dataSets[i] as? IBarLineScatterCandleBubbleChartDataSet
                else { continue }

            let valueFont = dataSet.valueFont

            guard let formatter = dataSet.valueFormatter else { continue }

            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix

            let yoffset = valueFont.lineHeight

            _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)

            guard var minEntry = dataSet.entryForIndex(_xBounds.min) as? CandleChartDataEntry else { break }
            guard var maxEntry = dataSet.entryForIndex(_xBounds.min) as? CandleChartDataEntry else { break }

            for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
            {
                guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { break }

                if e.high > maxEntry.high {
                    maxEntry = e
                }

                if e.low < minEntry.low {
                    minEntry = e
                }

            }
            maxPt.x = CGFloat(maxEntry.x)
            maxPt.y = CGFloat(maxEntry.high * phaseY)
            maxPt = maxPt.applying(valueToPixelMatrix)

            minPt.x = CGFloat(minEntry.x)
            minPt.y = CGFloat(minEntry.low * phaseY)
            minPt = minPt.applying(valueToPixelMatrix)

            if dataSet.isDrawValuesEnabled
            {
                drawText(
                    context: context,
                    text: formatter.stringForValue(
                        maxEntry.high,
                        entry: maxEntry,
                        dataSetIndex: i,
                        viewPortHandler: viewPortHandler),
                    point: CGPoint(
                        x: maxPt.x,
                        y: maxPt.y - yoffset / 2),
                    align: .left,
                    attributes: [NSAttributedStringKey.font: valueFont, NSAttributedStringKey.foregroundColor: CommonConstants.RED_TEXT])

                drawText(
                    context: context,
                    text: formatter.stringForValue(
                        minEntry.low,
                        entry: minEntry,
                        dataSetIndex: i,
                        viewPortHandler: viewPortHandler),
                    point: CGPoint(
                        x: minPt.x,
                        y: minPt.y - yoffset / 2),
                    align: .left,
                    attributes: [NSAttributedStringKey.font: valueFont, NSAttributedStringKey.foregroundColor: CommonConstants.GREEN_TEXT])
            }
        }
    }

    //画最大最小值补丁
    func drawText(context: CGContext, text: String, point: CGPoint, align: NSTextAlignment, attributes: [NSAttributedStringKey : Any]?)
    {
        var point = point
        var label = text + "--->"
        let width = label.size(withAttributes: attributes).width
        if align == .center
        {
            point.x -= width / 2.0
        }
        else if align == .left
        {
            point.x -= width
            if point.x < viewPortHandler.offsetLeft {
                label = "<---" + text
                point.x += width
            }
        }

        UIGraphicsPushContext(context)

        (label as NSString).draw(at: point, withAttributes: attributes)

        UIGraphicsPopContext()
    }

    //十字光标打补丁
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let candleData = dataProvider.candleData
            else { return }
        
        context.saveGState()
        
        for high in indices
        {
            guard
                let set = candleData.getDataSetByIndex(high.dataSetIndex) as? ICandleChartDataSet,
                set.isHighlightEnabled
                else { continue }
            
            guard let e = set.entryForXValue(high.x, closestToY: high.y) as? CandleChartDataEntry else { continue }
            
            if !isInBoundsX(entry: e, dataSet: set)
            {
                continue
            }
            
            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
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

            let lowValue = e.low * animator.phaseY
            let highValue = e.high * animator.phaseY
            let pt = trans.pixelForValues(x: e.x, y: (lowValue + highValue) / 2)
            let xp = pt.x

            let xMax = viewPortHandler.contentRight
            let contentBottom = viewPortHandler.contentBottom

            //绘制竖线
            context.beginPath()
            context.move(to: CGPoint(x: xp, y: 15))
            context.addLine(to: CGPoint(x: xp, y: viewPortHandler.chartHeight))
            context.strokePath()

            let y = high.drawY
            if y >= 0 && y <= contentBottom{
                context.beginPath()
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: xMax, y: y))
                context.strokePath()
            }
        }
        
        context.restoreGState()
    }

}
