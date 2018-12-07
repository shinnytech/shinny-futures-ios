//
//  Quote.swift
//  shinnyfutures
//
//  Created by chenli on 2018/11/30.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Quote: NSObject {
    @objc var instrument_id: Any?
    @objc var datetime: Any?
    @objc var ask_price1: Any?
    @objc var ask_volume1: Any?
    @objc var bid_price1: Any?
    @objc var bid_volume1: Any?
    @objc var last_price: Any?
    @objc var highest: Any?
    @objc var lowest: Any?
    @objc var amount: Any?
    @objc var volume: Any?
    @objc var open_interest: Any?
    @objc var pre_open_interest: Any?
    @objc var pre_close: Any?
    @objc var open: Any?
    @objc var close: Any?
    @objc var lower_limit: Any?
    @objc var upper_limit: Any?
    @objc var average: Any?
    @objc var pre_settlement: Any?
    @objc var settlement: Any?
    @objc var status: Any?

    override var description: String {
        return ("last_price:" + "\(last_price ?? 0)")
    }

    override var hash: Int {
         return "\(instrument_id ?? "")".hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Quote {
            let last_l = (self.last_price as? NSNumber)?.stringValue
            let last_r = (other.last_price as? NSNumber)?.stringValue

            let pre_settlement_l = (self.pre_settlement as? NSNumber)?.stringValue
            let pre_settlement_r = (other.pre_settlement as? NSNumber)?.stringValue

            let open_insterest_l = (self.open_interest as? NSNumber)?.stringValue
            let open_insterest_r = (other.open_interest as? NSNumber)?.stringValue

            let volume_l = (self.volume as? NSNumber)?.stringValue
            let volume_r = (other.volume as? NSNumber)?.stringValue
            return (last_l == last_r) && (pre_settlement_l == pre_settlement_r) && (open_insterest_l == open_insterest_r) && (volume_l == volume_r)
        }else{
            return false
        }
    }
}
