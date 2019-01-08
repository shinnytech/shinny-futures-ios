//
//  RtnMD.swift
//  shinnyfutures
//
//  Created by chenli on 2018/11/30.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class RtnMD {
    var aid = ""
    var ins_list = ""
    var quotes = [String: Quote]()
    var klines = [String: [String: Kline]]()
    var ticks = [String: Tick]()
    var charts = [String: Chart]()
    var mdhis_more_data = false
}
