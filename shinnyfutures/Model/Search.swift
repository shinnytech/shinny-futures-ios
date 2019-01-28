//
//  Search.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/2.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class Search {
    var ins_id: String?
    var product_id: String?
    var instrument_id: String?
    var instrument_name: String?
    var exchange_name: String?
    var exchange_id: String?
    var py: String?
    var p_tick: String?
    var p_decs: Int?
    var vm: String?
    var sort_key: Int?
    var margin: Int?
    var underlying_symbol: String?
    var pre_volume: Int?
    var leg1_symbol: String?
    var leg2_symbol: String?

    init(ins_id: String?, product_id: String?, instrument_id: String?, instrument_name: String?, exchange_name: String?, exchange_id: String?, py: String?, p_tick: String?, p_decs: Int?, vm: String?, sort_key: Int?, margin: Int?, underlying_symbol: String?, pre_volume: Int?, leg1_symbol: String?, leg2_symbol: String?) {
        self.ins_id = ins_id
        self.product_id = product_id
        self.instrument_id = instrument_id
        self.instrument_name = instrument_name
        self.exchange_name = exchange_name
        self.exchange_id = exchange_id
        self.py = py
        self.p_tick = p_tick
        self.p_decs = p_decs
        self.vm = vm
        self.sort_key = sort_key
        self.margin = margin
        self.underlying_symbol = underlying_symbol
        self.pre_volume = pre_volume
        self.leg1_symbol = leg1_symbol
        self.leg2_symbol = leg2_symbol
    }

    required init?() {
        self.ins_id = ""
        self.product_id = ""
        self.instrument_id = ""
        self.instrument_name = ""
        self.exchange_name = ""
        self.exchange_id = ""
        self.py = ""
        self.p_tick = ""
        self.p_decs = 0
        self.vm = ""
        self.sort_key = 0
        self.margin = 0
        self.underlying_symbol = ""
        self.pre_volume = 0
        self.leg1_symbol = ""
        self.leg2_symbol = ""
    }

}
