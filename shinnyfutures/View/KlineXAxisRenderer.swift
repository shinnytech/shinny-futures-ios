//
//  KlineXAxisRenderer.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/25.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

open class KlineXAxisRenderer: XAxisRenderer {
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
        let centeringEnabled = xAxis.isCenterAxisLabelsEnabled
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        var labelMaxSize = CGSize()
        if xAxis.isWordWrapEnabled
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }

        var position = CGPoint(x: 0.0, y: 0.0)
        var labelWidth: CGFloat?
        var labelHeight: CGFloat?
        let entries = xAxis.entries

        for i in stride(from: 0, to: entries.count, by: 1)
        {
            if centeringEnabled
            {
                position.x = CGFloat(xAxis.centeredEntries[i])
            }
            else
            {
                position.x = CGFloat(entries[i])
            }
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if viewPortHandler.isInBoundsX(position.x)
            {
                var label = xAxis.valueFormatter?.stringForValue(xAxis.entries[i], axis: xAxis) ?? ""
                if label.isEmpty {return}

                if i != 0 && label.contains("/"){
                    let index = label.index(of: "/")
                    let beginIndex = label.index(index!, offsetBy: 1)
                    label = String(label.suffix(from: beginIndex))
                }

                let labelns = label as NSString
                labelWidth = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                
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

}
