//
//  RightTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/31.
//  Copyright © 2018 shinnytech. All rights reserved.
//

import UIKit

class RightTableViewController: UITableViewController {

    var mainViewController: MainViewController!
    var datas = CommonConstants.rightTitleArray

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorColor = UIColor.black
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return datas.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return datas[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightNavigationTableViewCell", for: indexPath) as! RightNavigationTableViewCell

        let data = datas[indexPath.section][indexPath.row]
        cell.icon.setImage(UIImage(named: data[0]), for: .normal)
        cell.title.text = data[1]
        cell.id = data[0]
        return cell
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 44.0
        }
        return 3
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
            let name = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
            name.textColor = UIColor.white
            name.text = "菜单栏"
            name.font = UIFont.systemFont(ofSize: 20)
            name.textAlignment = .center
            headerView.backgroundColor = CommonConstants.QUOTE_PAGE_HEADER
            headerView.addSubview(name)
            return headerView
        }else{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 5))
            headerView.backgroundColor = CommonConstants.BOLD_DEVIDER
            return headerView
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.closeRight()
        tableView.deselectRow(at: indexPath, animated: false)
        if let cell = tableView.cellForRow(at: indexPath) as? RightNavigationTableViewCell{
            changeViewController(title: cell.id)
        }
    }

    func changeViewController(title: String) {
        switch title {
        case "login":
            if DataManager.getInstance().sIsLogin{
                DataManager.getInstance().clearAccount()
                UserDefaults.standard.set("", forKey: CommonConstants.CONFIG_LOGIN_DATE)
                TDWebSocketUtils.getInstance().reconnectTD(url: CommonConstants.TRANSACTION_URL)
            }else{
                mainViewController.toLogin()
            }
            break
        case "setting":
            mainViewController.toSetting()
            break
        case "account":
            mainViewController.toAccount()
            break
        case "password":
            mainViewController.toChangePassword()
            break
        case "position":
            mainViewController.toPosition()
            break
        case "trade":
            mainViewController.toTrade()
            break
        case "bank":
            mainViewController.toBankTransfer()
            break
        case "open_account":
            mainViewController.toOpenAccount()
            break
        case "feedback":
            mainViewController.toFeedback()
            break
        case "about":
            mainViewController.toAbout()
            break
        default:
            break
        }
    }

}
