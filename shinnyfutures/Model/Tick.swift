//
//  Tick.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/5.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Tick: NSObject {
    @objc var last_id: Any?
    @objc var datas = [String: Data]()

    class Data: NSObject {
        @objc var datetime: Any?
        @objc var last_price: Any?
        @objc var average: Any?
        @objc var highest: Any?
        @objc var lowest: Any?
        @objc var ask_price1: Any?
        @objc var ask_volume1: Any?
        @objc var bid_price1: Any?
        @objc var bid_volume1: Any?
        @objc var volume: Any?
        @objc var amount: Any?
        @objc var open_interest: Any?
    }
}
