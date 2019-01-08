//
//  ReqCancelOrder.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/3.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import Foundation

struct ReqCancelOrder: Codable {
    var aid: String
    var user_id: String
    var order_id: String
}
