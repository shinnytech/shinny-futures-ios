//
//  KlinePopupViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/18.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class KlinePopupViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var position: UISwitch!
    @IBOutlet weak var order: UISwitch!
    @IBOutlet weak var averageLine: UISwitch!
    @IBOutlet weak var md5: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        averageLine.setOn(UserDefaults.standard.bool(forKey: CommonConstants.CONFIG_AVERAGE_LINE), animated: false)
        position.setOn(UserDefaults.standard.bool(forKey: CommonConstants.CONFIG_POSITION_LINE), animated: false)
        order.setOn(UserDefaults.standard.bool(forKey: CommonConstants.CONFIG_ORDER_LINE), animated: false)
        md5.setOn(UserDefaults.standard.bool(forKey: CommonConstants.CONFIG_MD5), animated: false)
    }

    // MARK: Actions
    @IBAction func position(_ sender: UISwitch) {
        UserDefaults.standard.set(position.isOn, forKey: CommonConstants.CONFIG_POSITION_LINE)
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.ControlPositionLineNotification), object: position.isOn)
    }

    @IBAction func order(_ sender: UISwitch) {
       UserDefaults.standard.set(order.isOn, forKey: CommonConstants.CONFIG_ORDER_LINE)
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.ControlOrderLineNotification), object: order.isOn)
    }

    @IBAction func averageLine(_ sender: UISwitch) {
        UserDefaults.standard.set(averageLine.isOn, forKey: CommonConstants.CONFIG_AVERAGE_LINE)
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.ControlAverageLineNotification), object: averageLine.isOn)
    }

    @IBAction func md5(_ sender: UISwitch) {
        UserDefaults.standard.set(md5.isOn, forKey: CommonConstants.CONFIG_MD5)
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.ControlMD5Notification), object: md5.isOn)
    }


}
