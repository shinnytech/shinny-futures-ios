//
//  MyYAxis.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/24.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Charts

open class MyYAxis: YAxis {
    var  baseValue = 0.0
    override init(position: YAxis.AxisDependency) {
        super.init(position: position)
    }
}
