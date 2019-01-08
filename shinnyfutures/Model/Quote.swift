//
//  Quote.swift
//  shinnyfutures
//
//  Created by chenli on 2018/11/30.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Quote: NSObject, NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let quote = Quote()
        quote.instrument_id = instrument_id
        quote.datetime = datetime
        quote.ask_price1 = ask_price1
        quote.ask_volume1 = ask_volume1
        quote.bid_price1 = bid_price1
        quote.bid_volume1 = bid_volume1
        quote.last_price = last_price
        quote.highest = highest
        quote.lowest = lowest
        quote.amount = amount
        quote.volume = volume
        quote.open_interest = open_interest
        quote.pre_open_interest = pre_open_interest
        quote.pre_close = pre_close
        quote.open = open
        quote.close = close
        quote.lower_limit = lower_limit
        quote.upper_limit = upper_limit
        quote.average = average
        quote.pre_settlement = pre_settlement
        quote.settlement = settlement
        quote.status = status
        return quote
    }

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
            let last_l = "\(self.last_price ?? 0.0)"
            let last_r = "\(other.last_price ?? 0.0)"

            let pre_settlement_l = "\(self.pre_settlement ?? 0.0)"
            let pre_settlement_r = "\(other.pre_settlement ?? 0.0)"

            let open_insterest_l = "\(self.open_interest ?? 0)"
            let open_insterest_r = "\(other.open_interest ?? 0)"

            let volume_l = "\(self.volume ?? 0)"
            let volume_r = "\(other.volume ?? 0)"
            return (last_l == last_r) && (pre_settlement_l == pre_settlement_r) && (open_insterest_l == open_insterest_r) && (volume_l == volume_r)
        }else{
            return false
        }
    }
}
