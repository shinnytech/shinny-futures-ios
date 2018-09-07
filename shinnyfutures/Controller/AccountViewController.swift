//
//  AccountViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/28.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var static_balance: UILabel!
    @IBOutlet weak var close_profit: UILabel!
    @IBOutlet weak var position_profit: UILabel!
    @IBOutlet weak var commission: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var margin: UILabel!
    @IBOutlet weak var margin_frozen: UILabel!
    @IBOutlet weak var commission_frozen: UILabel!
    @IBOutlet weak var premium_frozen: UILabel!
    @IBOutlet weak var available: UILabel!
    @IBOutlet weak var deposit: UILabel!
    @IBOutlet weak var withdraw: UILabel!
    let dataManager = DataManager.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        let now = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy年MM日dd日"
        date.text = dateFormat.string(from: now)
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        print("账户页销毁")
    }

    // MARK: objc methods
    @objc func loadData() {
        let user = dataManager.sRtnTD[dataManager.sUser_id]
        let acounts = user[RtnTDConstants.accounts].dictionaryValue
        for (_, account) in acounts {
            let static_balance = account[AccountConstants.static_balance].doubleValue
            let close_profit = account[AccountConstants.close_profit].doubleValue
            let position_profit = account[AccountConstants.position_profit].doubleValue
            let commission = account[AccountConstants.commission].doubleValue
            let balance = account[AccountConstants.balance].doubleValue
            let margin = account[AccountConstants.margin].doubleValue
            let margin_frozen = account[AccountConstants.frozen_margin].doubleValue
            let commission_frozen = account[AccountConstants.frozen_commission].doubleValue
            let premium_frozen = account[AccountConstants.frozen_premium].doubleValue
            let available = account[AccountConstants.available].doubleValue
            let deposit = account[AccountConstants.deposit].doubleValue
            let withdraw = account[AccountConstants.withdraw].doubleValue

            self.static_balance.text = String(format: "%.2f", static_balance)
            self.close_profit.text = String(format: "%.2f", close_profit)
            self.position_profit.text = String(format: "%.2f", position_profit)
            self.commission.text = String(format: "%.2f", commission)
            self.balance.text = String(format: "%.2f", balance)
            self.margin.text = String(format: "%.2f", margin)
            self.margin_frozen.text = String(format: "%.2f", margin_frozen)
            self.commission_frozen.text = String(format: "%.2f", commission_frozen)
            self.premium_frozen.text = String(format: "%.2f", premium_frozen)
            self.available.text = String(format: "%.2f", available)
            self.deposit.text = String(format: "%.2f", deposit)
            self.withdraw.text = String(format: "%.2f", withdraw)
        }

    }

}
