//
//  ReqBankTransfer.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/3.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import Foundation

struct ReqBankTransfer: Codable {
    var aid: String
    var future_account: String
    var future_password: String
    var bank_id: String
    var bank_password: String
    var currency: String
    var amount: Float
}
