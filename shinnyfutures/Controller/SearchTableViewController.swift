//
//  SearchTableViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/2.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {

    // MARK: Properties
    var searchHistory = [Search]()
    var searchController: UISearchController!
    var searchResults: [Search] = []
    var dataManager = DataManager.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "合约代码\\拼音\\中文\\交易所"
        searchController.searchBar.barStyle = .black

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false

        // make tableview look better in ipad
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()

        // Load the sample data
        loadData()
    }

    deinit {
        print("搜索页销毁")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResults.count
        } else {
            return searchHistory.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SearchTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TradeTableViewCell.")
        }

        // Fetches the appropriate quote for the data source layout.
        let quote = (searchController.isActive) ? searchResults[indexPath.row] : searchHistory[indexPath.row]

        cell.instrumentName.text = quote.instrument_name
        cell.instrumentId.text = "(" + "\(quote.instrument_id ?? "")" + ")"
        cell.exchangeName.text = quote.exchange_name

        let optional = FileUtils.getOptional()
        if let ins = quote.instrument_id {
            if !optional.contains(ins) {
                cell.save.setImage(UIImage(named: "heart_outline", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil), for: .normal)
            }else{
                cell.save.setImage(UIImage(named: "heart", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil), for: .normal)
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            if searchController.isActive {
                let instrumentId = searchResults[indexPath.row].instrument_id!
                dataManager.sInstrumentId = instrumentId
                if !dataManager.sSearchHistoryEntities.contains(where: {$0.key.elementsEqual(instrumentId)}) {
                    dataManager.sSearchHistoryEntities[instrumentId] = dataManager.sSearchEntities[instrumentId]
                }
                searchController.isActive = false
            } else {
                dataManager.sInstrumentId = searchHistory[indexPath.row].instrument_id!
            }
            DataManager.getInstance().sToQuoteTarget = ""
            DataManager.getInstance().sPreInsList = DataManager.getInstance().sRtnMD.ins_list
        }
    }

    // MARK: Action
    @IBAction func back(_ sender: UIBarButtonItem) {
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
    }

    // MARK: Private Methods
    private func loadData() {
        searchHistory = dataManager.sSearchHistoryEntities.sorted(by: {
            if let pre_volume0 = (dataManager.sSearchEntities[$0.key]?.pre_volume), let pre_volume1 = (dataManager.sSearchEntities[$1.key]?.pre_volume){
                if pre_volume0 != pre_volume1{
                    return pre_volume0 > pre_volume1
                }else{
                    return $0.key > $1.key
                }
            }
            return $0.key > $1.key

        }).map {$0.value}
    }

    func filterContent(for searchText: String) {
        searchResults = dataManager.sSearchEntities.filter({ (_, search) -> Bool in
            let isMatch = search.instrument_id!.localizedCaseInsensitiveContains(searchText) || search.instrument_name!.localizedCaseInsensitiveContains(searchText) ||
                search.py!.localizedCaseInsensitiveContains(searchText)
            return isMatch
        }).sorted(by: {
            if let pre_volume0 = (dataManager.sSearchEntities[$0.key]?.pre_volume), let pre_volume1 = (dataManager.sSearchEntities[$1.key]?.pre_volume){
                if pre_volume0 != pre_volume1{
                    return pre_volume0 > pre_volume1
                }else{
                    return $0.key > $1.key
                }
            }
            return $0.key > $1.key

        }).map {$0.value}
    }

    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
}
