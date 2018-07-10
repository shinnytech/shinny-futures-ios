//
//  HandicapViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/9.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class HandicapViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var ask_price1: UILabel!
    @IBOutlet weak var ask_volume1: UILabel!
    @IBOutlet weak var bid_price1: UILabel!
    @IBOutlet weak var bid_volume1: UILabel!
    @IBOutlet weak var latest: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var highest: UILabel!
    @IBOutlet weak var open_interest: UILabel!
    @IBOutlet weak var lowest: UILabel!
    @IBOutlet weak var sub_open_interest: UILabel!
    @IBOutlet weak var average: UILabel!
    @IBOutlet weak var settlement: UILabel!
    @IBOutlet weak var pre_close: UILabel!
    @IBOutlet weak var upper_limit: UILabel!
    @IBOutlet weak var pre_settlement: UILabel!
    @IBOutlet weak var lower_limit: UILabel!
    let dataManager = DataManager.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshPage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDatas), name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        print("盘口页销毁")
    }
    
    func refreshPage() {
        refreshDatas()
    }
    
    // MARK: objc methods
    @objc private func refreshDatas() {
        let instrumentId = dataManager.sRtnMD[RtnMDConstants.ins_list].stringValue
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)
        let quoteJson = dataManager.sRtnMD[RtnMDConstants.quotes][instrumentId]
        let ask_price1 = quoteJson[QuoteConstants.ask_price1].floatValue
        let ask_volume1 = quoteJson[QuoteConstants.ask_volume1].intValue
        let bid_price1 = quoteJson[QuoteConstants.bid_price1].floatValue
        let bid_volume1 = quoteJson[QuoteConstants.bid_volume1].intValue
        let last_price = quoteJson[QuoteConstants.last_price].floatValue
        let open = quoteJson[QuoteConstants.open].floatValue
        let volume = quoteJson[QuoteConstants.volume].intValue
        let highest = quoteJson[QuoteConstants.highest].floatValue
        let open_interest = quoteJson[QuoteConstants.open_interest].intValue
        let pre_open_interest = quoteJson[QuoteConstants.pre_open_interest].intValue
        let lowest = quoteJson[QuoteConstants.lowest].floatValue
        let average = quoteJson[QuoteConstants.average].floatValue
        let pre_close = quoteJson[QuoteConstants.pre_close].floatValue
        let upper_limit = quoteJson[QuoteConstants.upper_limit].floatValue
        let pre_settlement = quoteJson[QuoteConstants.pre_settlement].floatValue
        let lower_limit = quoteJson[QuoteConstants.lower_limit].floatValue
        let settlement = quoteJson[QuoteConstants.settlement].floatValue
        
        self.ask_price1.text = String(format: "%.\(decimal)f", ask_price1)
        self.ask_volume1.text = "\(ask_volume1)"
        self.bid_price1.text = String(format: "%.\(decimal)f", bid_price1)
        self.bid_volume1.text = "\(bid_volume1)"
        self.latest.text = String(format: "%.\(decimal)f", last_price)
        self.change.text = String(format: "%.\(decimal)f", last_price - pre_settlement)
        self.open.text = String(format: "%.\(decimal)f", open)
        self.volume.text = "\(volume)"
        self.highest.text = String(format: "%.\(decimal)f", highest)
        self.lowest.text = String(format: "%.\(decimal)f", lowest)
        self.open_interest.text = "\(open_interest)"
        self.sub_open_interest.text = "\(open_interest - pre_open_interest)"
        self.average.text = String(format: "%.\(decimal)f", average)
        self.settlement.text = String(format: "%.\(decimal)f", settlement)
        self.pre_close.text = String(format: "%.\(decimal)f", pre_close)
        self.upper_limit.text = String(format: "%.\(decimal)f", upper_limit)
        self.pre_settlement.text = String(format: "%.\(decimal)f", pre_settlement)
        self.lower_limit.text = String(format: "%.\(decimal)f", lower_limit)
        
        
    }
    
}
