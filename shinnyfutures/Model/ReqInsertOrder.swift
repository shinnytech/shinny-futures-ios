//
//  ReqInsertOrder.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/3.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import Foundation

struct ReqInsertOrder: Codable {
    var aid: String
    var user_id: String
    var order_id: String
    var exchange_id: String
    var instrument_id: String
    var direction: String
    var offset: String
    var volume: Int
    var price_type: String
    var limit_price: Double
    var volume_condition: String
    var time_condition: String
}
