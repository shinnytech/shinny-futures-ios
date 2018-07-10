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

    init(instrument_id: String, instrument_name: String, exchange_name: String, exchange_id: String, py: String, p_tick: String, vm: String) {
        self.instrument_id = instrument_id
        self.instrument_name = instrument_name
        self.exchange_name = exchange_name
        self.exchange_id = exchange_id
        self.py = py
        self.p_tick = p_tick
        self.vm = vm
    }

    required init?() {
        self.instrument_id = ""
        self.instrument_name = ""
        self.exchange_name = ""
        self.exchange_id = ""
        self.py = ""
        self.p_tick = ""
        vm = ""
    }

}
