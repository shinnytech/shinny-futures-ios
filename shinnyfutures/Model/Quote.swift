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
        quote.ask_price2 = ask_price2
        quote.ask_volume2 = ask_volume2
        quote.bid_price2 = bid_price2
        quote.bid_volume2 = bid_volume2
        quote.ask_price3 = ask_price3
        quote.ask_volume3 = ask_volume3
        quote.bid_price3 = bid_price3
        quote.bid_volume3 = bid_volume3
        quote.ask_price4 = ask_price4
        quote.ask_volume4 = ask_volume4
        quote.bid_price4 = bid_price4
        quote.bid_volume4 = bid_volume4
        quote.ask_price5 = ask_price5
        quote.ask_volume5 = ask_volume5
        quote.bid_price5 = bid_price5
        quote.bid_volume5 = bid_volume5
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
    @objc var ask_price2: Any?
    @objc var ask_volume2: Any?
    @objc var bid_price2: Any?
    @objc var bid_volume2: Any?
    @objc var ask_price3: Any?
    @objc var ask_volume3: Any?
    @objc var bid_price3: Any?
    @objc var bid_volume3: Any?
    @objc var ask_price4: Any?
    @objc var ask_volume4: Any?
    @objc var bid_price4: Any?
    @objc var bid_volume4: Any?
    @objc var ask_price5: Any?
    @objc var ask_volume5: Any?
    @objc var bid_price5: Any?
    @objc var bid_volume5: Any?
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

            let ask_price1_l = "\(self.ask_price1 ?? 0.0)"
            let ask_price1_r = "\(other.ask_price1 ?? 0.0)"

            let ask_volume1_l = "\(self.ask_volume1 ?? 0)"
            let ask_volume1_r = "\(other.ask_volume1 ?? 0)"

            let bid_price1_l = "\(self.bid_price1 ?? 0.0)"
            let bid_price1_r = "\(other.bid_price1 ?? 0.0)"

            let bid_volume1_l = "\(self.bid_volume1 ?? 0)"
            let bid_volume1_r = "\(other.bid_volume1 ?? 0)"

            let ask_price2_l = "\(self.ask_price2 ?? 0.0)"
            let ask_price2_r = "\(other.ask_price2 ?? 0.0)"

            let ask_volume2_l = "\(self.ask_volume2 ?? 0)"
            let ask_volume2_r = "\(other.ask_volume2 ?? 0)"

            let bid_price2_l = "\(self.bid_price2 ?? 0.0)"
            let bid_price2_r = "\(other.bid_price2 ?? 0.0)"

            let bid_volume2_l = "\(self.bid_volume2 ?? 0)"
            let bid_volume2_r = "\(other.bid_volume2 ?? 0)"

            let ask_price3_l = "\(self.ask_price3 ?? 0.0)"
            let ask_price3_r = "\(other.ask_price3 ?? 0.0)"

            let ask_volume3_l = "\(self.ask_volume3 ?? 0)"
            let ask_volume3_r = "\(other.ask_volume3 ?? 0)"

            let bid_price3_l = "\(self.bid_price3 ?? 0.0)"
            let bid_price3_r = "\(other.bid_price3 ?? 0.0)"

            let bid_volume3_l = "\(self.bid_volume3 ?? 0)"
            let bid_volume3_r = "\(other.bid_volume3 ?? 0)"

            let ask_price4_l = "\(self.ask_price4 ?? 0.0)"
            let ask_price4_r = "\(other.ask_price4 ?? 0.0)"

            let ask_volume4_l = "\(self.ask_volume4 ?? 0)"
            let ask_volume4_r = "\(other.ask_volume4 ?? 0)"

            let bid_price4_l = "\(self.bid_price4 ?? 0.0)"
            let bid_price4_r = "\(other.bid_price4 ?? 0.0)"

            let bid_volume4_l = "\(self.bid_volume4 ?? 0)"
            let bid_volume4_r = "\(other.bid_volume4 ?? 0)"

            let ask_price5_l = "\(self.ask_price5 ?? 0.0)"
            let ask_price5_r = "\(other.ask_price5 ?? 0.0)"

            let ask_volume5_l = "\(self.ask_volume5 ?? 0)"
            let ask_volume5_r = "\(other.ask_volume5 ?? 0)"

            let bid_price5_l = "\(self.bid_price5 ?? 0.0)"
            let bid_price5_r = "\(other.bid_price5 ?? 0.0)"

            let bid_volume5_l = "\(self.bid_volume5 ?? 0)"
            let bid_volume5_r = "\(other.bid_volume5 ?? 0)"

            let pre_settlement_l = "\(self.pre_settlement ?? 0.0)"
            let pre_settlement_r = "\(other.pre_settlement ?? 0.0)"

            let open_insterest_l = "\(self.open_interest ?? 0)"
            let open_insterest_r = "\(other.open_interest ?? 0)"

            let volume_l = "\(self.volume ?? 0)"
            let volume_r = "\(other.volume ?? 0)"

            return (last_l == last_r) && (pre_settlement_l == pre_settlement_r) && (open_insterest_l == open_insterest_r) && (volume_l == volume_r) && (ask_price1_l == ask_price1_r) && (ask_volume1_l == ask_volume1_r) && (bid_price1_l == bid_price1_r) && (bid_volume1_l == bid_volume1_r) && (ask_price2_l == ask_price2_r) && (ask_volume2_l == ask_volume2_r) && (bid_price2_l == bid_price2_r) && (bid_volume2_l == bid_volume2_r) && (ask_price3_l == ask_price3_r) && (ask_volume3_l == ask_volume3_r) && (bid_price3_l == bid_price3_r) && (bid_volume3_l == bid_volume3_r) && (ask_price4_l == ask_price4_r) && (ask_volume4_l == ask_volume4_r) && (bid_price4_l == bid_price4_r) && (bid_volume4_l == bid_volume4_r) && (ask_price5_l == ask_price5_r) && (ask_volume5_l == ask_volume5_r) && (bid_price5_l == bid_price5_r) && (bid_volume5_l == bid_volume5_r)
        }else{
            return false
        }
    }
}
