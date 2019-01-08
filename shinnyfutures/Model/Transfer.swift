//
//  Transfer.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/5.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import Foundation

class Transfer: NSObject {
    @objc var datetime: Any?
    @objc var currency: Any?
    @objc var amount: Any?
    @objc var error_id: Any?
    @objc var error_msg: Any?

    override var hash: Int {
        return "\(datetime ?? "")".hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Transfer {
            let datetime_l = "\(self.datetime ?? 0)"
            let datetime_r = "\(other.datetime ?? 0)"
            return (datetime_l == datetime_r)
        }else{
            return false
        }
    }

}
