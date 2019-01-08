//
//  ReqLogin.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/3.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import Foundation

struct ReqLogin: Codable {
    var aid: String
    var bid: String
    var user_name: String
    var password: String
}
