//
//  Quote.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/26.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class Quote: Hashable {
    var hashValue: Int {
        get {
            return instrument_id.djb2hash
        }
    }

    static func == (lhs: Quote, rhs: Quote) -> Bool {
        return lhs.instrument_name == rhs.instrument_name &&
            lhs.instrument_id == rhs.instrument_id &&
            lhs.last_price == rhs.last_price &&
            lhs.open_interest == rhs.open_interest &&
            lhs.volume == rhs.volume &&
            lhs.change == rhs.change &&
            lhs.change_percent == rhs.change_percent
    }

    var instrument_id: String
    var instrument_name: String
    var datetime: String
    var ask_price1: String
    var ask_volume1: String
    var bid_price1: String
    var bid_volume1: String
    var last_price: String
    var change_percent: String
    var change: String
    var highest: String
    var lowest: String
    var amount: String
    var volume: String
    var open_interest: String
    var pre_open_interest: String
    var pre_close: String
    var open: String
    var close: String
    var lower_limit: String
    var upper_limit: String
    var average: String
    var pre_settlement: String
    var settlement: String
    var status: String

    init(instrument_id: String, instrument_name: String, datetime: String, ask_price1: String, ask_volume1: String, bid_price1: String, bid_volume1: String, last_price: String, change_percent: String, change: String, highest: String, lowest: String, amount: String, volume: String, open_interest: String, pre_open_interest: String, pre_close: String, open: String, close: String, lower_limit: String, upper_limit: String, average: String, pre_settlement: String, settlement: String, status: String) {
        self.instrument_id = instrument_id
        self.instrument_name = instrument_name
        self.datetime = datetime
        self.ask_price1 = ask_price1
        self.ask_volume1 = ask_volume1
        self.bid_price1 = bid_price1
        self.bid_volume1 = bid_volume1
        self.last_price = last_price
        self.change_percent = change_percent
        self.change = change
        self.highest = highest
        self.lowest = lowest
        self.amount = amount
        self.volume = volume
        self.open_interest = open_interest
        self.pre_open_interest = pre_open_interest
        self.pre_close = pre_close
        self.open = open
        self.close = close
        self.lower_limit = lower_limit
        self.upper_limit = upper_limit
        self.average = average
        self.pre_settlement = pre_settlement
        self.settlement = settlement
        self.status = status
    }

    required init?() {
        self.instrument_id = ""
        self.instrument_name = ""
        self.datetime = ""
        self.ask_price1 = ""
        self.ask_volume1 = ""
        self.bid_price1 = ""
        self.bid_volume1 = ""
        self.last_price = ""
        self.change_percent = ""
        self.change = ""
        self.highest = ""
        self.lowest = ""
        self.amount = ""
        self.volume = ""
        self.open_interest = ""
        self.pre_open_interest = ""
        self.pre_close = ""
        self.open = ""
        self.close = ""
        self.lower_limit = ""
        self.upper_limit = ""
        self.average = ""
        self.pre_settlement = ""
        self.settlement = ""
        self.status = ""

    }
}

extension String {
    var djb2hash: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }

}
