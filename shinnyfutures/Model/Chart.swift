//
//  Chart.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/5.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Chart: NSObject {
    @objc var right_id: Any?
    @objc var left_id: Any?
    @objc var state: State?

    class State: NSObject {
        @objc var account_id: Any?
        @objc var aid: Any?
        @objc var chart_id: Any?
        @objc var duration: Any?
        @objc var ins_list: Any?
        @objc var session_id: Any?
        @objc var trading_day_count: Any?
        @objc var trading_day_start: Any?
        @objc var view_width: Any?

    }
}
