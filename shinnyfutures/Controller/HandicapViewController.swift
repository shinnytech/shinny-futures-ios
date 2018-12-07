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
        let instrumentId = dataManager.sInstrumentId
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)
        guard let quote = dataManager.sRtnMD.quotes[instrumentId] else {return}
        let ask_price1 = "\(quote.ask_price1 ?? 0)"
        let ask_volume1 = "\(quote.ask_volume1 ?? 0)"
        let bid_price1 = "\(quote.bid_price1 ?? 0)"
        let bid_volume1 = "\(quote.bid_volume1 ?? 0)"
        let last_price = "\(quote.last_price ?? 0)"
        let open = "\(quote.open ?? 0)"
        let volume = "\(quote.volume ?? 0)"
        let highest = "\(quote.highest ?? 0)"
        let open_interest = "\(quote.open_interest ?? 0)"
        let pre_open_interest = "\(quote.pre_open_interest ?? 0)"
        let lowest = "\(quote.lowest ?? 0)"
        let average = "\(quote.average ?? 0)"
        let pre_close = "\(quote.pre_close ?? 0)"
        let upper_limit = "\(quote.upper_limit ?? 0)"
        let pre_settlement = "\(quote.pre_settlement ?? 0)"
        let lower_limit = "\(quote.lower_limit ?? 0)"
        let settlement = "\(quote.settlement ?? 0)"
        var change = Float()
        if let last = Float(last_price), let pre_settlement = Float(pre_settlement){
            change = last - pre_settlement
        }
        var sub_open_interest = Int()
        if let open_interest = Int(open_interest), let pre_open_interest = Int(pre_open_interest){
            sub_open_interest = open_interest - pre_open_interest
        }
        
        self.ask_price1.text = dataManager.saveDecimalByPtick(decimal: decimal, data: ask_price1)
        self.ask_volume1.text = ask_volume1
        self.bid_price1.text = dataManager.saveDecimalByPtick(decimal: decimal, data: bid_price1)
        self.bid_volume1.text = bid_volume1
        self.latest.text = dataManager.saveDecimalByPtick(decimal: decimal, data: last_price)
        self.change.text = String(format: "%.\(decimal)f", change)
        self.open.text = dataManager.saveDecimalByPtick(decimal: decimal, data: open)
        self.volume.text = volume
        self.highest.text = dataManager.saveDecimalByPtick(decimal: decimal, data: highest)
        self.lowest.text = dataManager.saveDecimalByPtick(decimal: decimal, data: lowest)
        self.open_interest.text = open_interest
        self.sub_open_interest.text = "\(sub_open_interest)"
        self.average.text = dataManager.saveDecimalByPtick(decimal: decimal, data: average)
        self.settlement.text = dataManager.saveDecimalByPtick(decimal: decimal, data: settlement)
        self.pre_close.text = dataManager.saveDecimalByPtick(decimal: decimal, data: pre_close)
        self.upper_limit.text = dataManager.saveDecimalByPtick(decimal: decimal, data: upper_limit)
        self.pre_settlement.text = dataManager.saveDecimalByPtick(decimal: decimal, data: pre_settlement)
        self.lower_limit.text = dataManager.saveDecimalByPtick(decimal: decimal, data: lower_limit)
        
        
    }
    
}
