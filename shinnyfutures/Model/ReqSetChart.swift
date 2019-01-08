//
//  ReqSetChart.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/3.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import Foundation

struct ReqSetChart: Codable {
    var aid: String
    var chart_id: String
    var ins_list: String
    var duration: Int64
    var trading_day_start: Int
    var trading_day_count: Int64
}
