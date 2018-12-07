//
//  DragOptionalQuoteTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/11/23.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import UIKit
import DeepDiff

class OptionalPopupTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, OptionalTableViewCellDelegate {

    // MARK: Properties
    let dataManager = DataManager.getInstance()
    var quotes = [Quote]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // make tableview look better in ipad
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()
        tableView.isEditing = true

        quotes = dataManager.sQuotes[0].map {$0.value}
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "OptionalTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OptionalTableViewCell  else {
            fatalError("The dequeued cell is not an instance of OptionalTableViewCell.")
        }

        //全屏分割线
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.delegate = self
        cell.tag = indexPath.row

        // Fetches the appropriate quote for the data source layout.
        let quote = quotes[indexPath.row]
        var insturmentName = quote.instrument_id as? String
        if let instrumentId = insturmentName {
            insturmentName = dataManager.sSearchEntities[instrumentId]?.instrument_name
        }
        cell.instrumentId.text = insturmentName

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let quote = quotes.remove(at: sourceIndexPath.row)
        quotes.insert(quote, at: destinationIndexPath.row)
        dataManager.resortOptional(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }

    func didCutButton(_ tag: Int) {
        let quote = quotes[tag]
        let instrument_id = "\(quote.instrument_id ?? "")"
        self.quotes.remove(at: tag)
        dataManager.saveOrRemoveIns(ins: instrument_id)
        let indexPath = IndexPath(row: tag, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }

    func didTopButton(_ tag: Int) {
        let quote = quotes.remove(at: tag)
        quotes.insert(quote, at: 0)
        dataManager.resortOptional(fromIndex: tag, toIndex: 0)
        tableView.moveRow(at: IndexPath(row: tag, section: 0), to: IndexPath(row: 0, section: 0))
        tableView.reloadData()
    }

}



