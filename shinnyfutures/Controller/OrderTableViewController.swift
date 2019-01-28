//
//  OrderTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/4.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import DeepDiff

class OrderTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    // MARK: Properties
    var orders = [Order]()
    let dataManager = DataManager.getInstance()
    let dateFormat = DateFormatter()
    var isRefresh = true
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    var isShowAlert = true

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.addTarget(self, action: #selector(segmentValueChange), for: .valueChanged)
        dateFormat.dateFormat = "HH:mm:ss"

        // make tableview look better in ipad
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()

        self.isShowAlert = UserDefaults.standard.bool(forKey: CommonConstants.CONFIG_SETTING_TRANSACTION_SHOW_ORDER)
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshPage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        print("挂单页销毁")
    }

    func refreshPage() {
        loadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "OrderTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderTableViewCell  else {
            fatalError("The dequeued cell is not an instance of OrderTableViewCell.")
        }

        // Fetches the appropriate quote for the data source layout.
        // 切换挂单种类手动reloadData时需要判空
        if orders.count != 0 {
            let order = orders[indexPath.row]

            let instrumentId = "\(order.exchange_id ?? "")" + "." + "\(order.instrument_id ?? "")"
            if let search = dataManager.sSearchEntities[instrumentId] {
                cell.name.text = search.instrument_name
            } else {
                cell.name.text = "\(order.instrument_id ?? "")"
            }

            cell.status.text = "\(order.last_msg ?? "")"
            let offset = "\(order.offset ?? "")"
            switch offset {
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
            let direction = "\(order.direction ?? "")"
            switch direction {
            case "BUY":
                cell.offset.textColor = CommonConstants.RED_TEXT
            case "SELL":
                cell.offset.textColor = CommonConstants.GREEN_TEXT
            default:
                cell.offset.textColor = CommonConstants.RED_TEXT
            }
            let decimal = dataManager.getDecimalByPtick(instrumentId: instrumentId)

            let price = "\(order.limit_price ?? "-")"
            cell.price.text = dataManager.saveDecimalByPtick(decimal: decimal, data: price)
            let volume_left = (order.volume_left as? Int) ?? 0
            let volume_origin = (order.volume_orign as? Int) ?? 0
            let volume_trade = volume_origin - volume_left
            cell.volume.text = "\(volume_trade)" + "/" + "\(volume_origin)"
            let trade_time = Double("\(order.insert_date_time ?? 0)") ?? 0.0
            //错单时间为0
            if trade_time == 0{
                cell.time.text = "-"
            }else {
                let date = Date(timeIntervalSince1970: (trade_time / 1000000000))
                cell.time.text = dateFormat.string(from: date)
            }

        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if orders.count != 0 {
            let order = orders[indexPath.row]
            let status = "\(order.status ?? "")"
            if "ALIVE".elementsEqual(status) {
                let order_id = "\(order.order_id ?? "")"
                if isShowAlert {
                    let instrument_id = "\(order.instrument_id ?? "")"
                    let exchange_id = "\(order.exchange_id ?? "")"
                    let direction = "\(order.direction ?? "")"
                    var direction_title = ""
                    if "SELL".elementsEqual(direction){
                        direction_title = "卖"
                    }else if "BUY".elementsEqual(direction){
                        direction_title = "买"
                    }
                    let volume = "\(order.volume_left ?? 0)"
                    let p_decs = dataManager.getDecimalByPtick(instrumentId: exchange_id + "." + instrument_id)
                    let price = dataManager.saveDecimalByPtick(decimal: p_decs, data: "\(order.limit_price ?? 0.0)")
                    let title = "您确定要撤单吗？"
                    let message = "合约：\(instrument_id), 价格：\(price), 方向：\(direction_title), 手数：\(volume)手"
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确认", style: .default, handler: {action in
                        switch action.style {
                        case .default:
                            TDWebSocketUtils.getInstance().sendReqCancelOrder(order_id: order_id)
                        default:
                            break
                        }}))
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                }else {
                    TDWebSocketUtils.getInstance().sendReqCancelOrder(order_id: order_id)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        let state = UILabel()
        state.font = UIFont(name: "Helvetica Neue", size: 15.0)
        state.adjustsFontSizeToFitWidth = true
        state.text = "状态"
        state.textAlignment = .center
        state.textColor = UIColor.white
        let direction = UILabel()
        direction.font = UIFont(name: "Helvetica Neue", size: 15.0)
        direction.adjustsFontSizeToFitWidth = true
        direction.text = "开平"
        direction.textAlignment = .center
        direction.textColor = UIColor.white
        let price = UILabel()
        price.font = UIFont(name: "Helvetica Neue", size: 15.0)
        price.adjustsFontSizeToFitWidth = true
        price.text = "委托价"
        price.textAlignment = .right
        price.textColor = UIColor.white
        let volume = UILabel()
        volume.font = UIFont(name: "Helvetica Neue", size: 15.0)
        volume.adjustsFontSizeToFitWidth = true
        volume.text = "数量"
        volume.textAlignment = .right
        volume.textColor = UIColor.white
        let time = UILabel()
        time.font = UIFont(name: "Helvetica Neue", size: 15.0)
        time.adjustsFontSizeToFitWidth = true
        time.text = "时间"
        time.textAlignment = .center
        time.textColor = UIColor.white
        stackView.addArrangedSubview(name)
        stackView.addArrangedSubview(state)
        stackView.addArrangedSubview(direction)
        stackView.addArrangedSubview(price)
        stackView.addArrangedSubview(volume)
        stackView.addArrangedSubview(time)
        headerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            name.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2),
            state.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2),
            direction.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.1),
            price.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2),
            volume.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.1),
            time.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2)
            ])
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToScrollStop { isRefresh = true }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let dragToDragStop = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
            if dragToDragStop { isRefresh = true }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isRefresh = false
    }


    @objc func segmentValueChange() {
        orders.removeAll()
        tableView.reloadData()
        loadData()
    }
    
    // MARK: objc Methods
    @objc private func loadData() {
        if !isRefresh{return}
        guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
        let orders_tmp = user.orders.sorted{ "\($0.value.insert_date_time ?? 0)" > "\($1.value.insert_date_time ?? 0)" }.map {$0.value}
        let oldData = orders
        orders.removeAll()
        for order in orders_tmp {
            let order_copy = order.copy() as! Order
            if segmentControl.selectedSegmentIndex == 1 {
                orders.append(order_copy)
            }else{
                let status = "\(order.status ?? "")"
                if "ALIVE".elementsEqual(status) {
                    orders.append(order_copy)
                }
            }
        }

        if oldData.count == 0 {
            tableView.reloadData()
        } else {
            let change = diff(old: oldData, new: orders)
            tableView.reload(changes: change, section: 0, insertionAnimation: .none, deletionAnimation: .none, replacementAnimation: .none, completion: {_ in})
        }
    }

}
