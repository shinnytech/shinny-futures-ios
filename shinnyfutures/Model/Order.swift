//
//  Order.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/5.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Order: NSObject {
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
            let order_id_l = "\(self.order_id ?? "")"
            let order_id_r = "\(other.order_id ?? "")"

            let status_l = "\(self.status ?? "")"
            let status_r = "\(other.status ?? "")"

            let volume_left_l = "\(self.volume_left ?? "")"
            let volume_left_r = "\(other.volume_left ?? "")"

            return (order_id_l == order_id_r && status_l == status_r && volume_left_l == volume_left_r)
        }else{
            return false
        }
    }

}
