//
//  BrokerTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/3.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import UIKit

class BrokerTableViewController: UITableViewController {

    var datas = [String]()
    var dataRetrurn = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.black
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()
        datas = DataManager.getInstance().sBrokers
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return datas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrokerTableViewCell", for: indexPath) as! BrokerTableViewCell

        cell.broker.text = datas[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        dataRetrurn = datas[indexPath.row]
        performSegue(withIdentifier: CommonConstants.BrokerToLogin, sender: nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    @IBAction func back(_ sender: UIBarButtonItem) {
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
    }

}
