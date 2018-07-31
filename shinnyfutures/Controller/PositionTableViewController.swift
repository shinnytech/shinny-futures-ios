//
//  PositionTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/4.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import SwiftyJSON
import DeepDiff

class PositionTableViewController: UITableViewController {
    // MARK: Properties
    var positions = [JSON]()
    let dataManager = DataManager.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        // make tableview look better in ipad
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshPage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Notification.Name(CommonConstants.PositionNotification), object: nil)
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
        let instrumentId = position[PositionConstants.instrument_id].stringValue
        var vm = 1
        if let search = dataManager.sSearchEntities[instrumentId] {
            cell.name.text = search.instrument_name
            vm = Int(search.vm)!
        } else {
            cell.name.text = instrumentId
        }
        let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId) + 1
        let available_long = position[PositionConstants.volume_long_today].intValue + position[PositionConstants.volume_long_his].intValue
        let volume_long = available_long + position[PositionConstants.volume_long_frozen].intValue
        let available_short = position[PositionConstants.volume_short_today].intValue + position[PositionConstants.volume_short_his].intValue
        let volume_short = available_short + position[PositionConstants.volume_short_frozen].intValue
        var profit = 0.0

        if volume_long != 0 && volume_short == 0 {
            cell.direction.text = "多"
            cell.direction.textColor = UIColor.red
            cell.available.text = "\(available_long)"
            cell.volume.text = "\(volume_long)"
            let open_cost_long = position[PositionConstants.open_cost_long].floatValue
            var open_price_long = position[PositionConstants.open_price_long].floatValue
            open_price_long = dataManager.getPrice(open_cost: open_cost_long, open_price: open_price_long, vm: vm, volume: volume_long)
            cell.openPrice.text = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(open_price_long)")
            profit = position[PositionConstants.float_profit_long].doubleValue
            cell.profit.text = "\(profit)"
        } else if volume_long == 0 && volume_short != 0 {
            cell.direction.text = "空"
            cell.direction.textColor = UIColor.green
            cell.available.text = "\(available_short)"
            cell.volume.text = "\(volume_short)"
            let open_cost_short = position[PositionConstants.open_cost_short].floatValue
            var open_price_short = position[PositionConstants.open_price_short].floatValue
            open_price_short = dataManager.getPrice(open_cost: open_cost_short, open_price: open_price_short, vm: vm, volume: volume_short)
            cell.openPrice.text = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(open_price_short)")
            profit = position[PositionConstants.float_profit_short].doubleValue
            cell.profit.text = "\(profit)"
        } else if volume_long != 0 && volume_short != 0 {
            cell.direction.text = "双向"
            cell.direction.textColor = UIColor.white
            cell.available.text = "\(available_long)" + "/" + "\(available_short)"
            cell.volume.text = "\(volume_long)" + "/" + "\(volume_short)"
            let open_cost_long = position[PositionConstants.open_cost_long].floatValue
            var open_price_long = position[PositionConstants.open_price_long].floatValue
            open_price_long = dataManager.getPrice(open_cost: open_cost_long, open_price: open_price_long, vm: vm, volume: volume_long)
            let open_price_long_s = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(open_price_long)")
            let open_cost_short = position[PositionConstants.open_cost_short].floatValue
            var open_price_short = position[PositionConstants.open_price_short].floatValue
            open_price_short = dataManager.getPrice(open_cost: open_cost_short, open_price: open_price_short, vm: vm, volume: volume_short)
            let open_price_short_s = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(open_price_short)")
            cell.openPrice.text = open_price_long_s + "/" + open_price_short_s
            let profit_long = position[PositionConstants.float_profit_long].stringValue
            let profit_short = position[PositionConstants.float_profit_short].stringValue
            cell.profit.text = profit_long + "/" + profit_short
            profit = position[PositionConstants.float_profit_long].doubleValue
        }else{
            cell.direction.text = "--"
            cell.direction.textColor = UIColor.white
            cell.available.text = "--"
            cell.volume.text = "--"
            cell.openPrice.text = "--"
            cell.profit.text = "--"
            cell.profit.textColor = UIColor.white
        }

        if profit > 0 {
            cell.profit.textColor = UIColor.red
        } else if profit < 0 {
            cell.profit.textColor = UIColor.green
        } else {
            cell.profit.textColor = UIColor.white
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let instrumentId = positions[indexPath.row][PositionConstants.exchange_id].stringValue + "." + positions[indexPath.row][PositionConstants.instrument_id].stringValue
        if !dataManager.sInstrumentId.elementsEqual(instrumentId){
            dataManager.sInstrumentId = instrumentId
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.ClearChartViewNotification), object: nil)
        }
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchToTransactionNotification), object: nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35.0))
        headerView.backgroundColor = UIColor.darkGray
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35.0))
        stackView.distribution = .fillEqually
        let name = UILabel()
        name.adjustsFontSizeToFitWidth = true
        name.textColor = UIColor.white
        name.text = "合约"
        name.textAlignment = .center
        let direction = UILabel()
        direction.adjustsFontSizeToFitWidth = true
        direction.textColor = UIColor.white
        direction.text = "多空"
        direction.textAlignment = .center
        let volume = UILabel()
        volume.adjustsFontSizeToFitWidth = true
        volume.textColor = UIColor.white
        volume.text = "手数"
        volume.textAlignment = .center
        let available = UILabel()
        available.adjustsFontSizeToFitWidth = true
        available.textColor = UIColor.white
        available.text = "可用"
        available.textAlignment = .center
        let openInterest = UILabel()
        openInterest.adjustsFontSizeToFitWidth = true
        openInterest.textColor = UIColor.white
        openInterest.text = "开仓均价"
        openInterest.textAlignment = .center
        let profit = UILabel()
        profit.adjustsFontSizeToFitWidth = true
        profit.textColor = UIColor.white
        profit.text = "逐笔盈亏"
        profit.textAlignment = .center
        stackView.addArrangedSubview(name)
        stackView.addArrangedSubview(direction)
        stackView.addArrangedSubview(volume)
        stackView.addArrangedSubview(available)
        stackView.addArrangedSubview(openInterest)
        stackView.addArrangedSubview(profit)
        headerView.addSubview(stackView)
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }

    // MARK: objc Methods
    @objc private func loadData() {
        if positions.count == 0 {
            positions = dataManager.sRtnPositions.sorted(by: <).map {$0.value}
            tableView.reloadData()
        } else {
            let oldData = positions
            positions = dataManager.sRtnPositions.sorted(by: <).map {$0.value}

            let change = diff(old: oldData, new: positions)

            tableView.reload(changes: change, section: 0, insertionAnimation: .none, deletionAnimation: .none, replacementAnimation: .none, completion: {_ in})
        }
    }

}

extension JSON: Hashable {

    public var hashValue: Int {

        if (self.dictionaryValue.map {$0.key}).contains(OrderConstants.order_type) {
            return self[OrderConstants.order_id].stringValue.hashValue
        }

        if (self.dictionaryValue.map {$0.key}).contains(TradeConstants.exchange_trade_id) {
            return (self[TradeConstants.order_id].stringValue + "|" + self[TradeConstants.exchange_trade_id].stringValue).hashValue
        }

        if (self.dictionaryValue.map {$0.key}).contains(PositionConstants.position_cost_long) {
            return (self[PositionConstants.exchange_id].stringValue + "." + self[PositionConstants.exchange_id].stringValue).hashValue
        }
        return self.count
    }

    static func == (lhs: JSON, rhs: JSON) -> Bool {
        if (lhs.dictionaryValue.map {$0.key}).contains(PositionConstants.position_cost_long) {
            return lhs[PositionConstants.exchange_id].stringValue == rhs[PositionConstants.exchange_id].stringValue && lhs[PositionConstants.instrument_id].stringValue == rhs[PositionConstants.instrument_id].stringValue && lhs[PositionConstants.volume_long_frozen].stringValue == rhs[PositionConstants.volume_long_frozen].stringValue && lhs[PositionConstants.volume_long_his].stringValue == rhs[PositionConstants.volume_long_his].stringValue && lhs[PositionConstants.volume_long_today].stringValue == rhs[PositionConstants.volume_long_today].stringValue && lhs[PositionConstants.open_price_long].stringValue == rhs[PositionConstants.open_price_long].stringValue && lhs[PositionConstants.open_cost_long].stringValue == rhs[PositionConstants.open_cost_long].stringValue && lhs[PositionConstants.float_profit_long].stringValue == rhs[PositionConstants.float_profit_long].stringValue && lhs[PositionConstants.volume_short_his].stringValue == rhs[PositionConstants.volume_short_his].stringValue && lhs[PositionConstants.volume_short_today].stringValue == rhs[PositionConstants.volume_short_today].stringValue && lhs[PositionConstants.open_price_short].stringValue == rhs[PositionConstants.open_price_short].stringValue && lhs[PositionConstants.open_cost_short].stringValue == rhs[PositionConstants.open_cost_short].stringValue && lhs[PositionConstants.float_profit_short].stringValue == rhs[PositionConstants.float_profit_short].stringValue

        }

        if (lhs.dictionaryValue.map {$0.key}).contains(OrderConstants.order_type) {
            return lhs[OrderConstants.order_id].stringValue == rhs[OrderConstants.order_id].stringValue && lhs[OrderConstants.last_msg].stringValue == rhs[OrderConstants.last_msg].stringValue && lhs[OrderConstants.status].stringValue == rhs[OrderConstants.status].stringValue && lhs[OrderConstants.volume_left].stringValue == rhs[OrderConstants.volume_left].stringValue
        }
        return lhs.hashValue == rhs.hashValue
    }

}
