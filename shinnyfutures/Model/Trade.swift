//
//  Trade.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/5.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Trade: NSObject {
    @objc var user_id: Any?
    @objc var trade_id: Any?
    @objc var exchange_id: Any?
    @objc var instrument_id: Any?
    @objc var order_id: Any?
    @objc var exchange_trade_id: Any?

    @objc var direction: Any?
    @objc var offset: Any?
    @objc var volume: Any?
    @objc var price: Any?
    @objc var trade_date_time: Any?
    @objc var commission: Any?

    override var description: String {
        return ("trade_id:" + "\(trade_id ?? "")")
    }

    override var hash: Int {
         return "\(trade_id ?? "")".hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Trade {
            let trade_date_time_l = "\(self.trade_date_time ?? 0)"
            let trade_date_time_r = "\(other.trade_date_time ?? 0)"
            return (trade_date_time_l == trade_date_time_r)
        }else{
            return false
        }
    }

}
