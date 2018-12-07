//
//  Kline.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/5.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Kline: NSObject {
    @objc var last_id: Any?
    @objc var trading_day_start_id: Any?
    @objc var trading_day_end_id: Any?
    @objc var datas = [String: Data]()
    @objc var bindings = [String: Binding]()

    class Data: NSObject {
         @objc var datetime: Any?
         @objc var open: Any?
         @objc var high: Any?
         @objc var low: Any?
         @objc var close: Any?
         @objc var volume: Any?
         @objc var open_oi: Any?
         @objc var close_oi: Any?
    }

    class Binding: NSObject {
        @objc var kline_num = [String: Any]()
    }

    override var description: String {
        return ("last_id:" + "\(last_id ?? 0)" + "trading_day_start_id:" + "\(trading_day_start_id ?? 0)" + "trading_day_end_id:" + "\(trading_day_end_id ?? 0)")
    }
}
