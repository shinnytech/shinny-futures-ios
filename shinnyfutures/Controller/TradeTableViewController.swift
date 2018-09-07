//
//  TradeTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/3.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import SwiftyJSON
import DeepDiff

class TradeTableViewController: UITableViewController {

    // MARK: Properties
    var trades = [JSON]()
    let dataManager = DataManager.getInstance()
    var isRefresh = true
    let dateFormat = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        // make tableview look better in ipad
        tableView.cellLayoutMarginsFollowReadableWidth = true
        dateFormat.dateFormat = "HH:mm:ss"
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        print("成交记录页销毁")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return trades.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "TradeTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TradeTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TradeTableViewCell.")
        }

        // Fetches the appropriate quote for the data source layout.
        let trade = trades[indexPath.row]
        let instrumentId = trade[TradeConstants.exchange_id].stringValue + "." +  trade[TradeConstants.instrument_id].stringValue
        if let search = dataManager.sSearchEntities[instrumentId] {
            cell.name.text = search.instrument_name
        } else {
            cell.name.text = instrumentId
        }
        switch trade[TradeConstants.offset].stringValue {
        case "OPEN":
            cell.offset.text = "开仓"
        case "CLOSETODAY":
            cell.offset.text = "平今"
        case "CLOSEHISTORY":
            cell.offset.text = "平昨"
        case "CLOSE":
            cell.offset.text = "平仓"
        case "FORCECLOSE":
            cell.offset.text = "强平"
        default:
            cell.offset.text = ""
        }
        switch trade[TradeConstants.direction].stringValue {
        case "BUY":
            cell.offset.textColor = UIColor.red
        case "SELL":
            cell.offset.textColor = UIColor.green
        default:
            cell.offset.textColor = UIColor.red
        }
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)
        let price = trade[TradeConstants.price].stringValue
        cell.price.text = dataManager.saveDecimalByPtick(decimal: decimal, data: price)
        cell.volume.text = trade[TradeConstants.volume].stringValue
        let trade_time = trade[TradeConstants.trade_date_time].doubleValue
        let date = Date(timeIntervalSince1970: (trade_time / 1000000000))
        cell.time.text = dateFormat.string(from: date)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
        headerView.backgroundColor = UIColor.darkGray
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width - 10, height: 44.0))
        stackView.distribution = .fillEqually
        let name = UILabel()
        name.text = "合约名称"
        name.textAlignment = .center
        let direction = UILabel()
        direction.text = "开平"
        direction.textAlignment = .center
        let price = UILabel()
        price.text = "成交价"
        price.textAlignment = .right
        let volume = UILabel()
        volume.text = "成交量"
        volume.textAlignment = .center
        let datetime = UILabel()
        datetime.text = "成交时间"
        datetime.textAlignment = .center
        stackView.addArrangedSubview(name)
        stackView.addArrangedSubview(direction)
        stackView.addArrangedSubview(price)
        stackView.addArrangedSubview(volume)
        stackView.addArrangedSubview(datetime)
        headerView.addSubview(stackView)
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToScrollStop { isRefresh = true }
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let dragToDragStop = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
            if dragToDragStop { isRefresh = true }
        }
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isRefresh = false
    }


    // MARK: objc Methods
    @objc private func loadData() {
        if !isRefresh {return}
        let user = dataManager.sRtnTD[dataManager.sUser_id]
        let rtnTrades = user[RtnTDConstants.trades].dictionaryValue.sorted(by: >).map {$0.value}
        let oldData = trades
        trades = rtnTrades
        if oldData.count == 0 {
            tableView.reloadData()
        } else {
            let change = diff(old: oldData, new: trades)
            tableView.reload(changes: change, section: 0, insertionAnimation: .none, deletionAnimation: .none, replacementAnimation: .none, completion: {_ in})
        }

    }

}
