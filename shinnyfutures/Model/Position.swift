//
//  Position.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/5.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Position: NSObject {

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

    override var hash: Int {
        return ("\(exchange_id ?? "")" + "." + "\(instrument_id ?? "")").hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Position {
            let position_id_l = "\(self.exchange_id ?? "")" + "." + "\(self.instrument_id ?? "")"
            let position_id_r = "\(other.exchange_id ?? "")" + "." + "\(other.instrument_id ?? "")"

            let volume_long_frozen_his_l = "\(self.volume_long_frozen_his ?? "")"
            let volume_long_frozen_his_r = "\(other.volume_long_frozen_his ?? "")"

            let volume_long_frozen_today_l = "\(self.volume_long_frozen_today ?? "")"
            let volume_long_frozen_today_r = "\(other.volume_long_frozen_today ?? "")"

            let volume_long_l = "\(self.volume_long ?? "")"
            let volume_long_r = "\(other.volume_long ?? "")"

            let open_price_long_l = "\(self.open_price_long ?? "")"
            let open_price_long_r = "\(other.open_price_long ?? "")"

            let open_cost_long_l = "\(self.open_cost_long ?? "")"
            let open_cost_long_r = "\(other.open_cost_long ?? "")"

            let float_profit_long_l = "\(self.float_profit_long ?? "")"
            let float_profit_long_r = "\(other.float_profit_long ?? "")"

            let volume_short_frozen_his_l = "\(self.volume_short_frozen_his ?? "")"
            let volume_short_frozen_his_r = "\(other.volume_short_frozen_his ?? "")"

            let volume_short_frozen_today_l = "\(self.volume_short_frozen_today ?? "")"
            let volume_short_frozen_today_r = "\(other.volume_short_frozen_today ?? "")"

            let volume_short_l = "\(self.volume_short ?? "")"
            let volume_short_r = "\(other.volume_short ?? "")"

            let open_price_short_l = "\(self.open_price_short ?? "")"
            let open_price_short_r = "\(other.open_price_short ?? "")"

            let open_cost_short_l = "\(self.open_cost_short ?? "")"
            let open_cost_short_r = "\(other.open_cost_short ?? "")"

            let float_profit_short_l = "\(self.float_profit_short ?? "")"
            let float_profit_short_r = "\(other.float_profit_short ?? "")"
            
            return (position_id_l == position_id_r && volume_long_frozen_his_l == volume_long_frozen_his_r && volume_long_frozen_today_l == volume_long_frozen_today_r && volume_long_l == volume_long_r && open_price_long_l == open_price_long_r && open_cost_long_l == open_cost_long_r && float_profit_long_l == float_profit_long_r && volume_short_frozen_his_l == volume_short_frozen_his_r && volume_short_frozen_today_l == volume_short_frozen_today_r && volume_short_l == volume_short_r && open_price_short_l == open_price_short_r && open_cost_short_l == open_cost_short_r && float_profit_short_l == float_profit_short_r)
        }else{
            return false
        }
    }

}
