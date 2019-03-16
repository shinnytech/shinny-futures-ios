//
//  KlineDurationViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2019/2/12.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import UIKit

class KlineDurationViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate, KlineDurationTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var durations = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()
        tableView.isEditing = true

        durations = UserDefaults.standard.stringArray(forKey: CommonConstants.CONFIG_SETTING_KLINE_DURATION_DEFAULT) ?? [String]()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return durations.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "KlineDurationTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? KlineDurationTableViewCell  else {
            fatalError("The dequeued cell is not an instance of OptionalTableViewCell.")
        }

        //全屏分割线
        cell.delegate = self
        cell.tag = indexPath.row
        cell.duration.text = durations[indexPath.row]
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 44.0
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
//        headerView.backgroundColor = CommonConstants.BOLD_DEVIDER
//        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
//        stackView.distribution = .fillProportionally
//        let remove = UILabel()
//        remove.text = "移除"
//        remove.textAlignment = .center
//        remove.textColor = UIColor.black
//        let duration = UILabel()
//        duration.text = "周期名称"
//        duration.textAlignment = .center
//        duration.textColor = UIColor.black
//        let top = UILabel()
//        top.text = "置顶"
//        top.textAlignment = .center
//        top.textColor = UIColor.black
//        let sort = UILabel()
//        sort.text = "排序"
//        sort.textAlignment = .center
//        sort.textColor = UIColor.black
//        stackView.addArrangedSubview(remove)
//        stackView.addArrangedSubview(duration)
//        stackView.addArrangedSubview(top)
//        stackView.addArrangedSubview(sort)
//        headerView.addSubview(stackView)
//        NSLayoutConstraint.activate([
//            remove.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.1),
//            duration.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.7),
//            top.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.1),
//            sort.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.1)
//            ])
//        return headerView
//    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let duration = durations.remove(at: sourceIndexPath.row)
        durations.insert(duration, at: destinationIndexPath.row)
        UserDefaults.standard.set(durations, forKey: CommonConstants.CONFIG_SETTING_KLINE_DURATION_DEFAULT)
    }

    func didCutButton(_ tag: Int) {
        durations.remove(at: tag)
        let indexPath = IndexPath(row: tag, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
        UserDefaults.standard.set(durations, forKey: CommonConstants.CONFIG_SETTING_KLINE_DURATION_DEFAULT)
    }

    func didTopButton(_ tag: Int) {
        let duration = durations.remove(at: tag)
        durations.insert(duration, at: 0)
        tableView.moveRow(at: IndexPath(row: tag, section: 0), to: IndexPath(row: 0, section: 0))
        tableView.reloadData()
        UserDefaults.standard.set(durations, forKey: CommonConstants.CONFIG_SETTING_KLINE_DURATION_DEFAULT)
    }

    @IBAction func addDurationCollectionViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从添加常用周期来～")
        durations = UserDefaults.standard.stringArray(forKey: CommonConstants.CONFIG_SETTING_KLINE_DURATION_DEFAULT) ?? [String]()
        tableView.reloadData()
    }

}
