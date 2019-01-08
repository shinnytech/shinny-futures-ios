//
//  Order.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/5.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Order: NSObject, NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        let o = Order()
        o.user_id = user_id
        o.order_id = order_id
        o.exchange_id = exchange_id
        o.instrument_id = instrument_id
        o.direction = direction
        o.offset = offset
        o.volume_orign = volume_orign
        o.price_type = price_type
        o.limit_price = limit_price
        o.time_condition = time_condition
        o.volume_condition = volume_condition
        o.exchange_order_id = exchange_order_id
        o.insert_date_time = insert_date_time
        o.last_msg = last_msg
        o.status = status
        o.volume_left = volume_left
        return o
    }

    @objc var user_id: Any?
    @objc var order_id: Any?
    @objc var exchange_id: Any?
    @objc var instrument_id: Any?
    @objc var direction: Any?
    @objc var offset: Any?
    @objc var volume_orign: Any?
    @objc var price_type: Any?
    @objc var limit_price: Any?
    @objc var time_condition: Any?
    @objc var volume_condition: Any?

    @objc var exchange_order_id: Any?
    @objc var insert_date_time: Any?

    @objc var last_msg: Any?
    @objc var status: Any?
    @objc var volume_left: Any?

    override var hash: Int {
        return "\(order_id ?? "")".hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Order {

            let status_l = "\(self.status ?? "")"
            let status_r = "\(other.status ?? "")"

            let volume_left_l = "\(self.volume_left ?? 0)"
            let volume_left_r = "\(other.volume_left ?? 0)"

            return (status_l == status_r && volume_left_l == volume_left_r)
        }else{
            return false
        }
    }

}
