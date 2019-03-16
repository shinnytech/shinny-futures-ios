//
//  MD5ViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2019/2/28.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import UIKit

class MD5ViewController: UIViewController {

    @IBOutlet weak var ask_price5: UILabel!
    @IBOutlet weak var ask_volume5: UILabel!
    @IBOutlet weak var ask_price4: UILabel!
    @IBOutlet weak var ask_volume4: UILabel!
    @IBOutlet weak var ask_price3: UILabel!
    @IBOutlet weak var ask_volume3: UILabel!
    @IBOutlet weak var ask_price2: UILabel!
    @IBOutlet weak var ask_volume2: UILabel!
    @IBOutlet weak var ask_price1: UILabel!
    @IBOutlet weak var ask_volume1: UILabel!
    @IBOutlet weak var bid_price5: UILabel!
    @IBOutlet weak var bid_volume5: UILabel!
    @IBOutlet weak var bid_price4: UILabel!
    @IBOutlet weak var bid_volume4: UILabel!
    @IBOutlet weak var bid_price3: UILabel!
    @IBOutlet weak var bid_volume3: UILabel!
    @IBOutlet weak var bid_price2: UILabel!
    @IBOutlet weak var bid_volume2: UILabel!
    @IBOutlet weak var bid_price1: UILabel!
    @IBOutlet weak var bid_volume1: UILabel!
    @IBOutlet weak var md5StackView: UIStackView!

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

    func refreshPage() {
        refreshDatas()
    }

    // MARK: objc methods
    @objc private func refreshDatas() {
        let instrumentId = dataManager.sInstrumentId
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)
        guard var quote = dataManager.sRtnMD.quotes[instrumentId] else {return}
        if instrumentId.contains("&") && instrumentId.contains(" ") {
            quote = dataManager.calculateCombineQuoteFull(quote: quote.copy() as! Quote)
        }
        let ask_price1 = quote.ask_price1 is NSNull ?  "-" : "\(quote.ask_price1 ?? "-")"
        let ask_volume1 = quote.ask_volume1 is NSNull ? "-" : "\(quote.ask_volume1 ?? "-")"
        let bid_price1 = quote.bid_price1 is NSNull ? "-" : "\(quote.bid_price1 ?? "-")"
        let bid_volume1 = quote.bid_volume1 is NSNull ? "-" : "\(quote.bid_volume1 ?? "-")"

        let ask_price2 = quote.ask_price2 is NSNull ? "-" : "\(quote.ask_price2 ?? "-")"
        let ask_volume2 = quote.ask_volume2 is NSNull ? "-" : "\(quote.ask_volume2 ?? "-")"
        let bid_price2 = quote.bid_price2 is NSNull ? "-" : "\(quote.bid_price2 ?? "-")"
        let bid_volume2 = quote.bid_volume2 is NSNull ? "-" : "\(quote.bid_volume2 ?? "-")"

        let ask_price3 = quote.ask_price3 is NSNull ? "-" : "\(quote.ask_price3 ?? "-")"
        let ask_volume3 = quote.ask_volume3 is NSNull ? "-" : "\(quote.ask_volume3 ?? "-")"
        let bid_price3 = quote.bid_price3 is NSNull ? "-" : "\(quote.bid_price3 ?? "-")"
        let bid_volume3 = quote.bid_volume3 is NSNull ? "-" : "\(quote.bid_volume3 ?? "-")"

        let ask_price4 = quote.ask_price4 is NSNull ? "-" : "\(quote.ask_price4 ?? "-")"
        let ask_volume4 = quote.ask_volume4 is NSNull ? "-" : "\(quote.ask_volume4 ?? "-")"
        let bid_price4 = quote.bid_price4 is NSNull ? "-" : "\(quote.bid_price4 ?? "-")"
        let bid_volume4 = quote.bid_volume4 is NSNull ? "-" : "\(quote.bid_volume4 ?? "-")"

        let ask_price5 = quote.ask_price5 is NSNull ? "-" : "\(quote.ask_price5 ?? "-")"
        let ask_volume5 = quote.ask_volume5 is NSNull ? "-" : "\(quote.ask_volume5 ?? "-")"
        let bid_price5 = quote.bid_price5 is NSNull ? "-" : "\(quote.bid_price5 ?? "-")"
        let bid_volume5 = quote.bid_volume5 is NSNull ? "-" : "\(quote.bid_volume5 ?? "-")"

        self.ask_price1.text = dataManager.saveDecimalByPtick(decimal: decimal, data: ask_price1)
        self.ask_volume1.text = ask_volume1
        self.bid_price1.text = dataManager.saveDecimalByPtick(decimal: decimal, data: bid_price1)
        self.bid_volume1.text = bid_volume1

        self.ask_price2.text = dataManager.saveDecimalByPtick(decimal: decimal, data: ask_price2)
        self.ask_volume2.text = ask_volume2
        self.bid_price2.text = dataManager.saveDecimalByPtick(decimal: decimal, data: bid_price2)
        self.bid_volume2.text = bid_volume2

        self.ask_price3.text = dataManager.saveDecimalByPtick(decimal: decimal, data: ask_price3)
        self.ask_volume3.text = ask_volume3
        self.bid_price3.text = dataManager.saveDecimalByPtick(decimal: decimal, data: bid_price3)
        self.bid_volume3.text = bid_volume3

        self.ask_price4.text = dataManager.saveDecimalByPtick(decimal: decimal, data: ask_price4)
        self.ask_volume4.text = ask_volume4
        self.bid_price4.text = dataManager.saveDecimalByPtick(decimal: decimal, data: bid_price4)
        self.bid_volume4.text = bid_volume4

        self.ask_price5.text = dataManager.saveDecimalByPtick(decimal: decimal, data: ask_price5)
        self.ask_volume5.text = ask_volume5
        self.bid_price5.text = dataManager.saveDecimalByPtick(decimal: decimal, data: bid_price5)
        self.bid_volume5.text = bid_volume5

    }

}
