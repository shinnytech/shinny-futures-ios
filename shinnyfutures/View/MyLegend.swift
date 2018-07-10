//
//  MyLegend.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/24.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

open class MyLegend: Legend {
    override init() {
        super.init()
        yOffset = CGFloat(-1)
    }
}
