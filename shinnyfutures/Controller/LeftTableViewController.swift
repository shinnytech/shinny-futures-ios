//
//  LeftTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/12/31.
//  Copyright © 2018 shinnytech. All rights reserved.
//

import UIKit

class LeftTableViewController: UITableViewController {

    var mainViewController: MainViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorColor = UIColor.black
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return CommonConstants.titleArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftNavigationTableViewCell", for: indexPath) as! LeftNavigationTableViewCell

        cell.menu.text = CommonConstants.titleArray[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
        let name = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0 ))
        name.textColor = UIColor.white
        name.text = "选择页面"
        name.font = UIFont.systemFont(ofSize: 20)
        name.textAlignment = .center
        headerView.backgroundColor = CommonConstants.QUOTE_PAGE_HEADER
        headerView.addSubview(name)
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.closeLeft()
        tableView.deselectRow(at: indexPath, animated: false)
        mainViewController.switchPage(index: indexPath.row)
    }

}
