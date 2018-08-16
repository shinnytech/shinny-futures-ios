//
//  Search.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/2.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class Search {
    var instrument_id: String
    var instrument_name: String
    var exchange_name: String
    var exchange_id: String
    var py: String
    var p_tick: String
    var vm: String
    var sort_key: Int
    var margin: Int
    var underlying_symbol: String

    init(instrument_id: String, instrument_name: String, exchange_name: String, exchange_id: String, py: String, p_tick: String, vm: String, sort_key: Int, margin: Int, underlying_symbol: String) {
        self.instrument_id = instrument_id
        self.instrument_name = instrument_name
        self.exchange_name = exchange_name
        self.exchange_id = exchange_id
        self.py = py
        self.p_tick = p_tick
        self.vm = vm
        self.sort_key = sort_key
        self.margin = margin
        self.underlying_symbol = underlying_symbol
    }

    required init?() {
        self.instrument_id = ""
        self.instrument_name = ""
        self.exchange_name = ""
        self.exchange_id = ""
        self.py = ""
        self.p_tick = ""
        self.vm = ""
        self.sort_key = 0
        self.margin = 0
        self.underlying_symbol = ""
    }

}
