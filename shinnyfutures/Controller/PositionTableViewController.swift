//
//  PositionTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/4.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import DeepDiff

class PositionTableViewController: UITableViewController {
    // MARK: Properties
    var positions = [Position]()
    var oldData = [Position]()
    let dataManager = DataManager.getInstance()
    var isRefresh = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // make tableview look better in ipad
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshPage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        print("持仓页销毁")
    }

    func refreshPage() {
        loadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return positions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PositionTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PositionTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PositionTableViewCell.")
        }

        // Fetches the appropriate quote for the data source layout.
        let position = positions[indexPath.row]
        let instrumentId = "\(position.exchange_id ?? "")" + "." + "\(position.instrument_id ?? "")"
        if let search = dataManager.sSearchEntities[instrumentId] {
            cell.name.text = search.instrument_name
        } else {
            cell.name.text = instrumentId
        }

        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId) + 1

        let volume_long = (position.volume_long as? Int) ?? 0
        let volume_long_frozen_today = (position.volume_long_frozen_today as? Int) ?? 0
        let volume_long_frozen_his = (position.volume_long_frozen_his as? Int) ?? 0
        let available_long = volume_long - volume_long_frozen_today - volume_long_frozen_his

        let volume_short = (position.volume_short as? Int) ?? 0
        let volume_short_frozen_today = (position.volume_short_frozen_today as? Int) ?? 0
        let volume_short_frozen_his = (position.volume_short_frozen_his as? Int) ?? 0
        let available_short = volume_short - volume_short_frozen_today - volume_short_frozen_his

        var profit = 0.0

        if volume_long != 0 && volume_short == 0 {
            cell.direction.text = "多"
            cell.direction.textColor = CommonConstants.RED_TEXT
            cell.available.text = "\(available_long)"
            cell.volume.text = "\(volume_long)"
            let open_price_long = "\(position.open_price_long ?? 0.0)"
            cell.openPrice.text = dataManager.saveDecimalByPtick(decimal: decimal, data: open_price_long)
            profit = Double("\(position.float_profit_long ?? 0.0)") ?? 0.0
            cell.profit.text = dataManager.saveDecimalByPtick(decimal: 2, data: "\(profit)")
        } else if volume_long == 0 && volume_short != 0 {
            cell.direction.text = "空"
            cell.direction.textColor = CommonConstants.GREEN_TEXT
            cell.available.text = "\(available_short)"
            cell.volume.text = "\(volume_short)"
            let open_price_short = "\(position.open_price_short ?? 0.0)"
            cell.openPrice.text = dataManager.saveDecimalByPtick(decimal: decimal, data: open_price_short)
            profit = Double("\(position.float_profit_short ?? 0.0)") ?? 0.0
            cell.profit.text = dataManager.saveDecimalByPtick(decimal: 2, data: "\(profit)")
        }

        if profit > 0 {
            cell.profit.textColor = CommonConstants.RED_TEXT
        } else if profit < 0 {
            cell.profit.textColor = CommonConstants.GREEN_TEXT
        } else {
            cell.profit.textColor = UIColor.white
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let cell = tableView.cellForRow(at: indexPath) as? PositionTableViewCell{
            dataManager.sPositionDirection = cell.direction.text ?? ""
        }
        let position = positions[indexPath.row]
        let instrumentId = "\(position.exchange_id ?? "")" + "." + "\(position.instrument_id ?? "")"
        if !dataManager.sInstrumentId.elementsEqual(instrumentId){
            dataManager.sInstrumentId = instrumentId
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.ClearChartViewNotification), object: nil)
        }
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchToTransactionNotification), object: nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35.0))
         headerView.backgroundColor = CommonConstants.QUOTE_TABLE_HEADER_1
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35.0))
        stackView.distribution = .fillProportionally
        let name = UILabel()
        name.font = UIFont(name: "Helvetica Neue", size: 15.0)
        name.adjustsFontSizeToFitWidth = true
        name.text = "合约"
        name.textAlignment = .center
        name.textColor = UIColor.white
        let direction = UILabel()
        direction.font = UIFont(name: "Helvetica Neue", size: 15.0)
        direction.adjustsFontSizeToFitWidth = true
        direction.text = "多空"
        direction.textAlignment = .center
        direction.textColor = UIColor.white
        let volume = UILabel()
        volume.font = UIFont(name: "Helvetica Neue", size: 15.0)
        volume.adjustsFontSizeToFitWidth = true
        volume.text = "手数"
        volume.textAlignment = .center
        volume.textColor = UIColor.white
        let available = UILabel()
        available.font = UIFont(name: "Helvetica Neue", size: 15.0)
        available.adjustsFontSizeToFitWidth = true
        available.text = "可用"
        available.textAlignment = .center
        available.textColor = UIColor.white
        let openInterest = UILabel()
        openInterest.font = UIFont(name: "Helvetica Neue", size: 15.0)
        openInterest.adjustsFontSizeToFitWidth = true
        openInterest.text = "开仓均价"
        openInterest.textAlignment = .right
        openInterest.textColor = UIColor.white
        let profit = UILabel()
        profit.font = UIFont(name: "Helvetica Neue", size: 15.0)
        profit.adjustsFontSizeToFitWidth = true
        profit.text = "逐笔盈亏"
        profit.textAlignment = .right
        profit.textColor = UIColor.white
        stackView.addArrangedSubview(name)
        stackView.addArrangedSubview(direction)
        stackView.addArrangedSubview(volume)
        stackView.addArrangedSubview(available)
        stackView.addArrangedSubview(openInterest)
        stackView.addArrangedSubview(profit)
        headerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            name.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2),
            direction.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.1),
            volume.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.1),
            available.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.1),
            openInterest.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.25),
            profit.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.25)
            ])
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
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
        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        let rtnPositions = user.positions.sorted{$0.key < $1.key}.map({$0.value})
        let oldData = positions
        positions.removeAll()
        for position in rtnPositions{
            let volume_long = (position.volume_long as? Int) ?? 0
            let volume_short = (position.volume_short as? Int) ?? 0
            if volume_long != 0 && volume_short != 0{
                positions.append(position.copyLong())
                positions.append(position.copyShort())
            } else if !(volume_long == 0 && volume_short == 0){
                positions.append(position.copy() as! Position)
            }
        }
        if oldData.count == 0 {
            tableView.reloadData()
        } else {
            let change = diff(old: oldData, new: positions)
            tableView.reload(changes: change, section: 0, insertionAnimation: .none, deletionAnimation: .none, replacementAnimation: .none, completion: {_ in})
        }
    }

}

