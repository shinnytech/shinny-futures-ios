//
//  CurrentDayYAxisRenderer.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/25.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

open class CurrentDayYAxisrenderer: YAxisRenderer {
    var yAxis: MyYAxis?
    
    init(viewPortHandler: ViewPortHandler, yAxis: MyYAxis?, transformer: Transformer?) {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: transformer)
        self.yAxis = yAxis
    }
    
    override open func computeAxisValues(min: Double, max: Double) {
        guard let yAxis = self.yAxis else { return }
        let base = yAxis.baseValue
        let labelCount = yAxis.labelCount
        if base == 0.0{
            super.computeAxisValues(min: min, max: max)
            return
        }
        let interval = (base - min) / Double(labelCount)
        let n = labelCount * 2 + 1
        yAxis.entries = [Double]()
        var f = min
        for _ in stride(from: 0, to: n, by: 1) {
            yAxis.entries.append(f)
            f += interval
        }
    }
    
    override open func renderAxisLabels(context: CGContext) {
        guard let yAxis = self.yAxis else { return }
        
        if !yAxis.isEnabled || !yAxis.isDrawLabelsEnabled
        {
            return
        }
        
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
            xPos = viewPortHandler.contentRight
        }
        drawYLabels(
            context: context,
            fixedPosition: xPos,
            positions: transformedPositions(),
            offset: 0.0,
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
        var labelTextColor = yAxis.labelTextColor
        
        let from = yAxis.isDrawBottomYLabelEntryEnabled ? 0 : 1
        let to = yAxis.isDrawTopYLabelEntryEnabled ? yAxis.entries.count : (yAxis.entries.count - 1)
        
        for i in stride(from: from, to: to, by: 1)
        {
            var label = yAxis.getFormattedLabel(i)
            
            let labelns = label as NSString
            
            let labelHeight = labelns.boundingRect(with: CGSize(), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: labelFont, NSAttributedStringKey.foregroundColor: labelTextColor], context: nil).size.height
            
            var pos = positions[i].y - labelHeight / 2

            if (pos - labelHeight / 2) <= viewPortHandler.contentTop {
                pos = pos + labelHeight / 2
            }else if (pos + labelHeight / 2) >= viewPortHandler.contentBottom{
                pos = pos - labelHeight / 2
            }

            //颜色设置
            if label.contains("%"){
                if label.contains("-"){
                    labelTextColor = CommonConstants.GREEN_TEXT
                }else if label.contains("0.00"){
                    labelTextColor = yAxis.labelTextColor
                }else{
                    label = "+" + label
                    labelTextColor = CommonConstants.RED_TEXT
                }
            }else{
                if Double(label)! > yAxis.baseValue {
                    labelTextColor = CommonConstants.RED_TEXT
                }else if Double(label)! < yAxis.baseValue{
                    labelTextColor = CommonConstants.GREEN_TEXT
                }else {
                    labelTextColor = yAxis.labelTextColor
                }
            }

            ChartUtils.drawText(
                context: context,
                text: label,
                point: CGPoint(x: fixedPosition, y: pos),
                align: textAlign,
                attributes: [NSAttributedStringKey.font: labelFont, NSAttributedStringKey.foregroundColor: labelTextColor])
        }
    }
    
    override open func renderGridLines(context: CGContext) {
        guard let
            yAxis = self.yAxis
            else { return }
        
        if !yAxis.isEnabled
        {
            return
        }
        
        if yAxis.drawGridLinesEnabled
        {
            let positions = transformedPositions()
            
            context.saveGState()
            defer { context.restoreGState() }
            context.clip(to: self.gridClippingRect)
            
            context.setShouldAntialias(yAxis.gridAntialiasEnabled)
            context.setStrokeColor(yAxis.gridColor.cgColor)
            context.setLineWidth(yAxis.gridLineWidth)
            context.setLineCap(yAxis.gridLineCap)
            
            // draw the grid
            for i in 0 ..< positions.count
            {
                //顶部底部不画线
                if i == 0 || i == (positions.count - 1) {
                    continue
                }
                //中间的线为实线，其他为虚线
                if i == 0 || i == (positions.count - 1) || i == (positions.count - 1) / 2{
                    context.setLineDash(phase: 0.0, lengths: [])
                }else {
                    if yAxis.gridLineDashLengths != nil
                    {
                        context.setLineDash(phase: yAxis.gridLineDashPhase, lengths: yAxis.gridLineDashLengths)

                    }
                }
                drawGridLine(context: context, position: positions[i])
            }
        }
        
        if yAxis.drawZeroLineEnabled
        {
            // draw zero line
            drawZeroLine(context: context)
        }
    }
    
    @objc override open func drawGridLine(
        context: CGContext,
        position: CGPoint)
    {
        context.beginPath()
        context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position.y))
        context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: position.y))
        context.strokePath()
    }
    
    
    override open func renderLimitLines(context: CGContext) {
        guard
            let yAxis = self.yAxis,
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
