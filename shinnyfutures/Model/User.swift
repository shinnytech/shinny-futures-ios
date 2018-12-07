//
//  User.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/5.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class User: NSObject {
    @objc var user_id: Any?
    @objc var accounts = [String: Account]()
    @objc var positions = [String: Position]()
    @objc var orders = [String: Order]()
    @objc var trades = [String: Trade]()
    @objc var transfers = [String: Transfer]()
    @objc var banks = [String: Bank]()
}
