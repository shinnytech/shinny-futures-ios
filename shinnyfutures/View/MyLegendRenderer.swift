//
//  MyLegendRenderer.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/25.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

open class MyLengendRenderer: LegendRenderer {
    var myLegend: MyLegend?
    
    init(viewPortHandler: ViewPortHandler, legend: MyLegend?) {
        super.init(viewPortHandler: viewPortHandler, legend: legend)
        myLegend = legend
    }
    
    override open func renderLegend(context: CGContext) {
        guard let legend = myLegend else { return }
        
        if !legend.enabled
        {
            return
        }
        
        let labelFont = legend.font
        let labelTextColor = legend.textColor
        let labelLineHeight = labelFont.lineHeight
        let formYOffset = labelLineHeight / 2.0
        
        var entries = legend.entries
        
        let defaultFormSize = legend.formSize
        let formToTextSpace = legend.formToTextSpace
        let xEntrySpace = legend.xEntrySpace
        let yEntrySpace = legend.yEntrySpace
        
        let orientation = legend.orientation
        let horizontalAlignment = legend.horizontalAlignment
        let verticalAlignment = legend.verticalAlignment
        let direction = legend.direction
        
        // space between the entries
        let stackSpace = legend.stackSpace
        
        let yoffset = legend.yOffset
        let xoffset = legend.xOffset
        var originPosX: CGFloat = 0.0
        
        switch horizontalAlignment
        {
        case .left:
            
            if orientation == .vertical
            {
                originPosX = xoffset
            }
            else
            {
                originPosX = viewPortHandler.contentLeft + xoffset
            }
            
            if direction == .rightToLeft
            {
                originPosX += legend.neededWidth
            }
            
        case .right:
            
            if orientation == .vertical
            {
                originPosX = viewPortHandler.chartWidth - xoffset
            }
            else
            {
                originPosX = viewPortHandler.contentRight - xoffset
            }
            
            if direction == .leftToRight
            {
                originPosX -= legend.neededWidth
            }
            
        case .center:
            
            if orientation == .vertical
            {
                originPosX = viewPortHandler.chartWidth / 2.0
            }
            else
            {
                originPosX = viewPortHandler.contentLeft
                    + viewPortHandler.contentWidth / 2.0
            }
            
            originPosX += (direction == .leftToRight
                ? +xoffset
                : -xoffset)
            
            // Horizontally layed out legends do the center offset on a line basis,
            // So here we offset the vertical ones only.
            if orientation == .vertical
            {
                if direction == .leftToRight
                {
                    originPosX -= legend.neededWidth / 2.0 - xoffset
                }
                else
                {
                    originPosX += legend.neededWidth / 2.0 - xoffset
                }
            }
        }
        
        switch orientation
        {
        case .horizontal:
            
            var calculatedLineSizes = legend.calculatedLineSizes
            var calculatedLabelSizes = legend.calculatedLabelSizes
            var calculatedLabelBreakPoints = legend.calculatedLabelBreakPoints
            
            var posX: CGFloat = originPosX
            var posY: CGFloat
            
            switch verticalAlignment
            {
            case .top:
                posY = yoffset
                
            case .bottom:
                posY = viewPortHandler.chartHeight - yoffset - legend.neededHeight
                
            case .center:
                posY = (viewPortHandler.chartHeight - legend.neededHeight) / 2.0 + yoffset
            }
            
            var lineIndex: Int = 0
            
            for i in 0 ..< entries.count
            {
                let e = entries[i]
                let drawingForm = e.form != .none
                let formSize = e.formSize.isNaN ? defaultFormSize : e.formSize
                
                if i < calculatedLabelBreakPoints.count &&
                    calculatedLabelBreakPoints[i]
                {
                    posX = originPosX
                    posY += labelLineHeight + yEntrySpace
                }
                
                if posX == originPosX &&
                    horizontalAlignment == .center &&
                    lineIndex < calculatedLineSizes.count
                {
                    posX += (direction == .rightToLeft
                        ? calculatedLineSizes[lineIndex].width
                        : -calculatedLineSizes[lineIndex].width) / 2.0
                    lineIndex += 1
                }
                
                let isStacked = e.label == nil // grouped forms have null labels
                
                if drawingForm
                {
                    if direction == .rightToLeft
                    {
                        posX -= formSize
                    }
                    
                    drawForm(
                        context: context,
                        x: posX,
                        y: posY + formYOffset,
                        entry: e,
                        legend: legend)
                    
                    if direction == .leftToRight
                    {
                        posX += formSize
                    }
                }
                
                if !isStacked
                {
                    if drawingForm
                    {
                        posX += direction == .rightToLeft ? -formToTextSpace : formToTextSpace
                    }
                    
                    if direction == .rightToLeft
                    {
                        posX -= calculatedLabelSizes[i].width
                    }
                    
                    drawLabel(
                        context: context,
                        x: posX,
                        y: posY,
                        label: e.label!,
                        font: labelFont,
                        textColor: labelTextColor)
                    
                    if direction == .leftToRight
                    {
                        posX += calculatedLabelSizes[i].width
                    }
                    
                    posX += direction == .rightToLeft ? -xEntrySpace : xEntrySpace
                }
                else
                {
                    posX += direction == .rightToLeft ? -stackSpace : stackSpace
                }
            }
            
        case .vertical:
            
            // contains the stacked legend size in pixels
            var stack = CGFloat(0.0)
            var wasStacked = false
            
            var posY: CGFloat = 0.0
            
            switch verticalAlignment
            {
            case .top:
                posY = (horizontalAlignment == .center
                    ? 0.0
                    : viewPortHandler.contentTop)
                posY += yoffset
                
            case .bottom:
                posY = (horizontalAlignment == .center
                    ? viewPortHandler.chartHeight
                    : viewPortHandler.contentBottom)
                posY -= legend.neededHeight + yoffset
                
            case .center:
                
                posY = viewPortHandler.chartHeight / 2.0 - legend.neededHeight / 2.0 + legend.yOffset
            }
            
            for i in 0 ..< entries.count
            {
                let e = entries[i]
                let drawingForm = e.form != .none
                let formSize = e.formSize.isNaN ? defaultFormSize : e.formSize
                
                var posX = originPosX
                
                if drawingForm
                {
                    if direction == .leftToRight
                    {
                        posX += stack
                    }
                    else
                    {
                        posX -= formSize - stack
                    }
                    
                    drawForm(
                        context: context,
                        x: posX,
                        y: posY + formYOffset,
                        entry: e,
                        legend: legend)
                    
                    if direction == .leftToRight
                    {
                        posX += formSize
                    }
                }
                
                if e.label != nil
                {
                    if drawingForm && !wasStacked
                    {
                        posX += direction == .leftToRight ? formToTextSpace : -formToTextSpace
                    }
                    else if wasStacked
                    {
                        posX = originPosX
                    }
                    
                    if direction == .rightToLeft
                    {
                        posX -= (e.label! as NSString).size(withAttributes: [.font: labelFont]).width
                    }
                    
                    if !wasStacked
                    {
                        drawLabel(context: context, x: posX, y: posY, label: e.label!, font: labelFont, textColor: labelTextColor)
                    }
                    else
                    {
                        posY += labelLineHeight + yEntrySpace
                        drawLabel(context: context, x: posX, y: posY, label: e.label!, font: labelFont, textColor: labelTextColor)
                    }
                    
                    // make a step down
                    posY += labelLineHeight + yEntrySpace
                    stack = 0.0
                }
                else
                {
                    stack += formSize + stackSpace
                    wasStacked = true
                }
            }
        }
    }
}
