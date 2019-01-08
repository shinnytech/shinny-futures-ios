//
//  Position.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/5.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Position: NSObject, NSCopying {

    func copyShort() -> Position {
        let p = Position()
        p.user_id = user_id
        p.exchange_id = exchange_id
        p.instrument_id = instrument_id

        p.volume_short_today = volume_short_today
        p.volume_short_his = volume_short_his
        p.volume_short = volume_short
        p.volume_short_frozen_his = volume_short_frozen_his
        p.volume_short_frozen_today = volume_short_frozen_today

        p.open_price_short = open_price_short
        p.open_cost_short = open_cost_short
        p.position_price_short = position_price_short
        p.position_cost_short = position_cost_short
        p.last_price = last_price
        p.float_profit = float_profit
        p.float_profit_short = float_profit_short
        p.position_profit = position_profit
        p.position_profit_short = position_profit_short

        p.margin_short = margin_short
        p.margin = margin
        return p
    }

    func copyLong() -> Position {
        let p = Position()
        p.user_id = user_id
        p.exchange_id = exchange_id
        p.instrument_id = instrument_id

        p.volume_long_today = volume_long_today
        p.volume_long_his = volume_long_his
        p.volume_long = volume_long
        p.volume_long_frozen_his = volume_long_frozen_his
        p.volume_long_frozen_today = volume_long_frozen_today

        p.open_price_long = open_price_long
        p.open_cost_long = open_cost_long
        p.position_price_long = position_price_long
        p.position_cost_long = position_cost_long
        p.last_price = last_price
        p.float_profit = float_profit
        p.float_profit_long = float_profit_long
        p.position_profit = position_profit
        p.position_profit_long = position_profit_long

        p.margin_long = margin_long
        p.margin = margin
        return p
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let p = Position()
        p.user_id = user_id
        p.exchange_id = exchange_id
        p.instrument_id = instrument_id

        p.volume_long_today = volume_long_today
        p.volume_long_his = volume_long_his
        p.volume_long = volume_long
        p.volume_long_frozen_his = volume_long_frozen_his
        p.volume_long_frozen_today = volume_long_frozen_today
        p.volume_short_today = volume_short_today
        p.volume_short_his = volume_short_his
        p.volume_short = volume_short
        p.volume_short_frozen_his = volume_short_frozen_his
        p.volume_short_frozen_today = volume_short_frozen_today

        p.open_price_short = open_price_short
        p.open_price_long = open_price_long
        p.open_cost_short = open_cost_short
        p.open_cost_long = open_cost_long
        p.position_price_long = position_price_long
        p.position_price_short = position_price_short
        p.position_cost_long = position_cost_long
        p.position_cost_short = position_cost_short
        p.last_price = last_price
        p.float_profit = float_profit
        p.float_profit_long = float_profit_long
        p.float_profit_short = float_profit_short
        p.position_profit = position_profit
        p.position_profit_long = position_profit_long
        p.position_profit_short = position_profit_short

        p.margin_long = margin_long
        p.margin_short = margin_short
        p.margin = margin
        return p
    }

    @objc var user_id: Any?
    @objc var exchange_id: Any?
    @objc var instrument_id: Any?

    @objc var volume_long_today: Any?
    @objc var volume_long_his: Any?
    @objc var volume_long: Any?
    @objc var volume_long_frozen_his: Any?
    @objc var volume_long_frozen_today: Any?
    @objc var volume_short_today: Any?
    @objc var volume_short_his: Any?
    @objc var volume_short: Any?
    @objc var volume_short_frozen_his: Any?
    @objc var volume_short_frozen_today: Any?

    @objc var open_price_long: Any?
    @objc var open_price_short: Any?
    @objc var open_cost_long: Any?
    @objc var open_cost_short: Any?
    @objc var position_price_long: Any?
    @objc var position_price_short: Any?
    @objc var position_cost_long: Any?
    @objc var position_cost_short: Any?
    @objc var last_price: Any?
    @objc var float_profit_long: Any?
    @objc var float_profit_short: Any?
    @objc var float_profit: Any?
    @objc var position_profit_long: Any?
    @objc var position_profit_short: Any?
    @objc var position_profit: Any?

    @objc var margin_long: Any?
    @objc var margin_short: Any?
    @objc var margin: Any?

    override var description: String {
        return ("float_profit_long:" + "\(float_profit_long ?? 0)")
    }

    override var hash: Int {
        return ("\(exchange_id ?? "")" + "." + "\(instrument_id ?? "")").hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Position {

            let volume_long_frozen_his_l = "\(self.volume_long_frozen_his ?? 0.0)"
            let volume_long_frozen_his_r = "\(other.volume_long_frozen_his ?? 0.0)"

            let volume_long_frozen_today_l = "\(self.volume_long_frozen_today ?? 0.0)"
            let volume_long_frozen_today_r = "\(other.volume_long_frozen_today ?? 0.0)"

            let volume_long_l = "\(self.volume_long ?? 0.0)"
            let volume_long_r = "\(other.volume_long ?? 0.0)"

            let open_price_long_l = "\(self.open_price_long ?? 0.0)"
            let open_price_long_r = "\(other.open_price_long ?? 0.0)"

            let open_cost_long_l = "\(self.open_cost_long ?? 0.0)"
            let open_cost_long_r = "\(other.open_cost_long ?? 0.0)"

            let float_profit_long_l = "\(self.float_profit_long ?? 0.0)"
            let float_profit_long_r = "\(other.float_profit_long ?? 0.0)"

            let volume_short_frozen_his_l = "\(self.volume_short_frozen_his ?? 0.0)"
            let volume_short_frozen_his_r = "\(other.volume_short_frozen_his ?? 0.0)"

            let volume_short_frozen_today_l = "\(self.volume_short_frozen_today ?? 0.0)"
            let volume_short_frozen_today_r = "\(other.volume_short_frozen_today ?? 0.0)"

            let volume_short_l = "\(self.volume_short ?? 0.0)"
            let volume_short_r = "\(other.volume_short ?? 0.0)"

            let open_price_short_l = "\(self.open_price_short ?? 0.0)"
            let open_price_short_r = "\(other.open_price_short ?? 0.0)"

            let open_cost_short_l = "\(self.open_cost_short ?? 0.0)"
            let open_cost_short_r = "\(other.open_cost_short ?? 0.0)"

            let float_profit_short_l = "\(self.float_profit_short ?? 0.0)"
            let float_profit_short_r = "\(other.float_profit_short ?? 0.0)"

            return (volume_long_frozen_his_l == volume_long_frozen_his_r &&
                volume_long_frozen_today_l == volume_long_frozen_today_r &&
                volume_long_l == volume_long_r &&
                open_price_long_l == open_price_long_r &&
                open_cost_long_l == open_cost_long_r &&
                float_profit_long_l == float_profit_long_r &&
                volume_short_frozen_his_l == volume_short_frozen_his_r &&
                volume_short_frozen_today_l == volume_short_frozen_today_r &&
                volume_short_l == volume_short_r &&
                open_price_short_l == open_price_short_r &&
                open_cost_short_l == open_cost_short_r &&
                float_profit_short_l == float_profit_short_r)
        }else{
            return false
        }
    }

}
