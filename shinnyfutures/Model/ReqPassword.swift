//
//  ReqPassword.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/3.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import Foundation

struct ReqPassword: Codable {
    var aid: String
    var new_password: String
    var old_password: String
}
