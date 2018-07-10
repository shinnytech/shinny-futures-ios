//
//  KlineYAxisRenderer.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/25.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

open class KlineYAxisRenderer: YAxisRenderer {
    
    var yAxis: MyYAxis?
    
    init(viewPortHandler: ViewPortHandler, yAxis: MyYAxis?, transformer: Transformer?) {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: transformer)
        self.yAxis = yAxis
    }
    
    override open func computeAxisValues(min: Double, max: Double) {
        guard let yAxis = self.yAxis else { return }
        let labelCount = yAxis.labelCount
        let interval = (max - min) / Double(labelCount)
        yAxis.entries = [min + interval, max - interval]
    }
    
    override open func renderAxisLabels(context: CGContext) {
        guard let yAxis = self.yAxis else { return }
        
        if !yAxis.isEnabled || !yAxis.isDrawLabelsEnabled
        {
            return
        }
        
        let yoffset = yAxis.labelFont.lineHeight / 2.5 + yAxis.yOffset
        
        let dependency = yAxis.axisDependency
        let labelPosition = yAxis.labelPosition
        
        var xPos = CGFloat(0.0)
        
        var textAlign: NSTextAlignment
        
        if dependency == .left
        {
            if labelPosition == .outsideChart
            {
                textAlign = .right
            }
            else
            {
                textAlign = .left
            }
            xPos = viewPortHandler.offsetLeft
        }
        else
        {
            if labelPosition == .outsideChart
            {
                textAlign = .left
            }
            else
            {
                textAlign = .right
            }
            xPos = viewPortHandler.offsetRight
        }
        
        drawYLabels(
            context: context,
            fixedPosition: xPos,
            positions: transformedPositions(),
            offset: yoffset - yAxis.labelFont.lineHeight,
            textAlign: textAlign)
    }
    
    override open func drawYLabels(
        context: CGContext,
        fixedPosition: CGFloat,
        positions: [CGPoint],
        offset: CGFloat,
        textAlign: NSTextAlignment)
    {
        guard let yAxis = self.yAxis else { return }

        let labelFont = yAxis.labelFont
        let labelTextColor = yAxis.labelTextColor

        let from = yAxis.isDrawBottomYLabelEntryEnabled ? 0 : 1
        let to = yAxis.isDrawTopYLabelEntryEnabled ? yAxis.entries.count : (yAxis.entries.count - 1)
        
        for i in stride(from: from, to: to, by: 1)
        {
            let label = yAxis.getFormattedLabel(i)
            let labelns = label as NSString
            
            let labelHeight = labelns.boundingRect(with: CGSize(), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: labelFont, NSAttributedStringKey.foregroundColor: labelTextColor], context: nil).size.height
            
            var pos = positions[i].y + offset
            
            if (pos - labelHeight) < viewPortHandler.contentTop {
                pos = viewPortHandler.contentTop + offset * CGFloat(2.5) + CGFloat(3)
            }else if (pos + labelHeight / CGFloat(2)) > viewPortHandler.contentBottom{
                pos = viewPortHandler.contentBottom - CGFloat(3)
            }
            
            ChartUtils.drawText(
                context: context,
                text: label,
                point: CGPoint(x: fixedPosition, y: positions[i].y + offset),
                align: textAlign,
                attributes: [NSAttributedStringKey.font: labelFont, NSAttributedStringKey.foregroundColor: labelTextColor])
        }
    }
    
    override open func renderLimitLines(context: CGContext) {
        guard
            let yAxis = self.axis as? YAxis,
            let transformer = self.transformer
            else { return }
        
        var limitLines = yAxis.limitLines
        
        if limitLines.count == 0
        {
            return
        }
        
        context.saveGState()
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in 0 ..< limitLines.count
        {
            let l = limitLines[i]
            
            if !l.isEnabled
            {
                continue
            }
            
            context.saveGState()
            defer { context.restoreGState() }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.y -= l.lineWidth / 2.0
            clippingRect.size.height += l.lineWidth
            context.clip(to: clippingRect)
            
            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = position.applying(trans)
            
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position.y))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: position.y))
            
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if l.lineDashLengths != nil
            {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            context.strokePath()
            
            let label = l.label
            
            // if drawing the limit-value label is enabled
            if l.drawLabelEnabled && label.count > 0
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let xOffset: CGFloat = 4.0 + l.xOffset
                let yOffset: CGFloat = l.lineWidth + labelLineHeight + l.yOffset
                
                if l.labelPosition == .rightTop
                {
                    ChartUtils.drawText(context: context,
                                        text: label,
                                        point: CGPoint(
                                            x: viewPortHandler.contentRight - xOffset,
                                            y: position.y - yOffset),
                                        align: .right,
                                        attributes: [NSAttributedStringKey.font: l.valueFont, NSAttributedStringKey.foregroundColor: l.valueTextColor])
                }
                else if l.labelPosition == .rightBottom
                {
                    ChartUtils.drawText(context: context,
                                        text: label,
                                        point: CGPoint(
                                            x: viewPortHandler.contentRight - xOffset,
                                            y: position.y + yOffset - labelLineHeight),
                                        align: .right,
                                        attributes: [NSAttributedStringKey.font: l.valueFont, NSAttributedStringKey.foregroundColor: l.valueTextColor])
                }
                else if l.labelPosition == .leftTop
                {
                    ChartUtils.drawText(context: context,
                                        text: label,
                                        point: CGPoint(
                                            x: viewPortHandler.contentLeft + xOffset,
                                            y: position.y - yOffset),
                                        align: .left,
                                        attributes: [NSAttributedStringKey.font: l.valueFont, NSAttributedStringKey.foregroundColor: l.valueTextColor])
                }
                else
                {
                    //持仓和挂单线的字线距太大，距左边界太近
                    ChartUtils.drawText(context: context,
                                        text: label,
                                        point: CGPoint(
                                            x: viewPortHandler.contentRight / 4,
                                            y: position.y),
                                        align: .left,
                                        attributes: [NSAttributedStringKey.font: l.valueFont, NSAttributedStringKey.foregroundColor: l.valueTextColor])
                }
            }
        }
        
        context.restoreGState()
    }
}
