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
    @IBOutlet weak var user: UILabel!
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
        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        for (_, account) in  user.accounts {
            let static_balance = "\(account.static_balance ?? 0.0)"
            let close_profit = "\(account.close_profit ?? 0.0)"
            let position_profit = "\(account.position_profit ?? 0.0)"
            let commission = "\(account.commission ?? 0.0)"
            let balance = "\(account.balance ?? 0.0)"
            let margin = "\(account.margin ?? 0.0)"
            let margin_frozen = "\(account.frozen_margin ?? 0.0)"
            let commission_frozen = "\(account.frozen_commission ?? 0.0)"
            let premium_frozen = "\(account.frozen_premium ?? 0.0)"
            let available = "\(account.available ?? 0.0)"
            let deposit = "\(account.deposit ?? 0.0)"
            let withdraw = "\(account.withdraw ?? 0.0)"

            self.user.text = dataManager.sUser_id
            self.static_balance.text = dataManager.saveDecimalByPtick(decimal: 2, data: static_balance)
            self.close_profit.text = dataManager.saveDecimalByPtick(decimal: 2, data: close_profit)
            self.position_profit.text = dataManager.saveDecimalByPtick(decimal: 2, data: position_profit)
            self.commission.text = dataManager.saveDecimalByPtick(decimal: 2, data: commission)
            self.balance.text = dataManager.saveDecimalByPtick(decimal: 2, data: balance)
            self.margin.text = dataManager.saveDecimalByPtick(decimal: 2, data: margin)
            self.margin_frozen.text = dataManager.saveDecimalByPtick(decimal: 2, data: margin_frozen)
            self.commission_frozen.text = dataManager.saveDecimalByPtick(decimal: 2, data: commission_frozen)
            self.premium_frozen.text = dataManager.saveDecimalByPtick(decimal: 2, data: premium_frozen)
            self.available.text = dataManager.saveDecimalByPtick(decimal: 2, data: available)
            self.deposit.text = dataManager.saveDecimalByPtick(decimal: 2, data: deposit)
            self.withdraw.text = dataManager.saveDecimalByPtick(decimal: 2, data: withdraw)
        }

    }
}
