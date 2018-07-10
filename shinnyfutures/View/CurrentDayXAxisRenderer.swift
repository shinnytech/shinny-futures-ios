//
//  CurrentDayXAxisRenderer.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/25.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

open class CurrentDayXAxisRenderer: XAxisRenderer {
    var xAxis: MyXAxis?
    
    init(viewPortHandler: ViewPortHandler, xAxis: MyXAxis?, transformer: Transformer?) {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer)
        self.xAxis = xAxis
    }
    
    override open func renderAxisLabels(context: CGContext) {
        guard let xAxis = self.xAxis else { return }
        
        if !xAxis.isEnabled || !xAxis.isDrawLabelsEnabled
        {
            return
        }
        
        let yOffset = xAxis.yOffset
        
        if xAxis.labelPosition == .top
        {
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
        }
        else if xAxis.labelPosition == .topInside
        {
            drawLabels(context: context, pos: viewPortHandler.contentTop + yOffset + xAxis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 1.0))
        }
        else if xAxis.labelPosition == .bottom
        {
            //把底部距离去除
            drawLabels(context: context, pos: viewPortHandler.contentBottom, anchor: CGPoint(x: 0.5, y: 0.0))
        }
        else if xAxis.labelPosition == .bottomInside
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom - yOffset - xAxis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 0.0))
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
    }

    //自定义x轴标志
    override open func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint) {
        guard
            let xAxis = self.xAxis,
            let transformer = self.transformer
            else { return }
        
        #if os(OSX)
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        #else
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        #endif
        paraStyle.alignment = .center
        let labelAttrs: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: xAxis.labelFont,
                                                         NSAttributedStringKey.foregroundColor: xAxis.labelTextColor,
                                                         NSAttributedStringKey.paragraphStyle: paraStyle]
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        var labelMaxSize = CGSize()
        if xAxis.isWordWrapEnabled
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }

        var position = CGPoint(x: 0.0, y: 0.0)
        var labelWidth: CGFloat?
        var labelHeight: CGFloat?
        let labels = xAxis.labels.sorted(by: <)

        for i in stride(from: 0, to: labels.count, by: 1)
        {
            position.x = CGFloat(labels[i].key)
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if viewPortHandler.isInBoundsX(position.x)
            {
                let label = labels[i].value
                if label.isEmpty {return}

                let labelns = label as NSString
                if labelWidth == nil {
                    labelWidth = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                }
                if labelHeight == nil{
                     labelHeight = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.height
                }
                
                guard let width = labelWidth else {return}
                guard let height = labelHeight else {return}
                let contentRight = viewPortHandler.contentRight
                let contentLeft = viewPortHandler.contentLeft
                let offsetBottom = viewPortHandler.offsetBottom
                
                if (width / 2 + position.x) > contentRight{
                    position.x = contentRight - width / 2
                }else if (position.x - width / 2) < contentLeft {
                    position.x = contentLeft + width / 2
                }
                
                drawLabel(context: context,
                          formattedLabel: label,
                          x: position.x,
                          y: pos + offsetBottom / 2 - height / 2,
                          attributes: labelAttrs,
                          constrainedToSize: labelMaxSize,
                          anchor: anchor,
                          angleRadians: 0)
            }
        }
    }

    //x轴垂直线
    override open func renderGridLines(context: CGContext) {
        guard
            let xAxis = self.xAxis,
            let transformer = self.transformer
            else { return }
        
        if !xAxis.isDrawGridLinesEnabled || !xAxis.isEnabled {return}
        
        context.saveGState()
        defer { context.restoreGState() }
        context.clip(to: self.gridClippingRect)
        context.setShouldAntialias(xAxis.gridAntialiasEnabled)
        context.setStrokeColor(xAxis.gridColor.cgColor)
        context.setLineWidth(xAxis.gridLineWidth)
        context.setLineCap(xAxis.gridLineCap)
        if xAxis.gridLineDashLengths != nil
        {
            context.setLineDash(phase: xAxis.gridLineDashPhase, lengths: xAxis.gridLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        let labels = xAxis.labels
        let keys = labels.keys.sorted()
        //首尾栅格线不画
        for i in stride(from: 0, to: labels.count, by: 1)
        {
            position.x = CGFloat(keys[i])
            position.y = position.x
            position = position.applying(valueToPixelMatrix)
            
            drawGridLine(context: context, x: position.x, y: position.y)
        }
    }
}
