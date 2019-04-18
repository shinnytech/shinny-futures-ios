//
//  SettingTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/15.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import UIKit
import AliyunLOGiOS

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var setting_transaction_order_click: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // make tableview look better in ipad
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()
        let show_order = UserDefaults.standard.bool(forKey: CommonConstants.CONFIG_SETTING_TRANSACTION_SHOW_ORDER)
        if show_order {
            setting_transaction_order_click.selectedSegmentIndex = 1
        }else{
            setting_transaction_order_click.selectedSegmentIndex = 0
        }
        setting_transaction_order_click.addTarget(self, action: #selector(segmentValueChange), for: .valueChanged)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case 0:
            switch indexPath.row{
            case 0:
                break
            default:
                break
            }
            break
        case 1:
            switch indexPath.row{
            case 0:
                if setting_transaction_order_click.selectedSegmentIndex == 0{
                    setting_transaction_order_click.selectedSegmentIndex = 1
                }else {
                    setting_transaction_order_click.selectedSegmentIndex = 0
                }
                segmentValueChange()
                break
            default:
                break
            }
            break
        case 2:
            switch indexPath.row{
            case 0:
                upload()
                break
            default:
                break
            }
            break
        default:
            break
        }
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 22.0))
        headerView.backgroundColor = CommonConstants.BOLD_DEVIDER
        let name = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width, height: 22.0))
        name.textColor = UIColor.lightGray
        if section == 0{
            name.text = "图表设置"
        }else if section == 1 {
            name.text = "交易设置"
        }else if section == 2{
            name.text = "系统设置"
        }
        name.textAlignment = .left
        headerView.addSubview(name)
        return headerView
    }

    @objc func segmentValueChange() {
        let index = setting_transaction_order_click.selectedSegmentIndex
        if index == 0 {
            UserDefaults.standard.set(false, forKey: CommonConstants.CONFIG_SETTING_TRANSACTION_SHOW_ORDER)
        }else{
            UserDefaults.standard.set(true, forKey: CommonConstants.CONFIG_SETTING_TRANSACTION_SHOW_ORDER)
        }

    }

    // MARK: Actions
    @IBAction func paraViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从指标参数修改页来～")
    }

    @IBAction func klineDurationViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从k线周期设置页来～")
    }

    func upload() {
        let user = DataManager.getInstance().sUser_id
        let version = DataManager.getInstance().sAppVersion
        let logGroup = LogGroup(topic: "user log", source: "V\(version) User id: \(user)")

        let dm = DBManager.defaultManager()
        let lists = dm.fetchRecords(limit: 500)
        for data in lists {
            if let logEntity = data as? Dictionary<String, Any>{
                let content = logEntity["log"] as? String ?? ""
                let log = Log()
                log.PutContent("content", value: content)
                logGroup.PutLog(log)
            }
        }

        /* Post log */
        DataManager.getInstance().sClient?.PostLog(logGroup, logStoreName: "kq-xq"){ response, error in
            //当前回调是在异步线程中，在主线程中同步UI
            if error != nil {
                // handle response however you want
                print("直接发送失败,error : \(String(describing: error?.localizedDescription))")
            }else{
                print("直接发送成功")
                DispatchQueue.main.async {
                    ToastUtils.showPositiveMessage(message: "日志上传成功")
                }
            }
        }
    }

}
