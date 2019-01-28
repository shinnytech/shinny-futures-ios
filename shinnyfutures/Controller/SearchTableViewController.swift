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
        let search = (searchController.isActive) ? searchResults[indexPath.row] : searchHistory[indexPath.row]

        cell.instrumentName.text = search.instrument_name
        cell.instrumentId.text = "(" + "\(search.ins_id ?? "")" + ")"
        cell.exchangeName.text = search.exchange_name
        cell.instrument_id = search.instrument_id

        let optional = FileUtils.getOptional()
        if let ins = search.instrument_id {
            if !optional.contains(ins) {
                cell.save.setImage(UIImage(named: "favorite_border", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil), for: .normal)
            }else{
                cell.save.setImage(UIImage(named: "favorite", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil), for: .normal)
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
        searchResults.removeAll()
        var results0 = [String: Search]()
        var results1 = [String: Search]()
        var results2 = [String: Search]()
        var results3 = [String: Search]()
        var results4 = [String: Search]()
        for (key, value) in dataManager.sSearchEntities{
            if value.ins_id!.localizedCaseInsensitiveContains(searchText){
                results0[key] = value
                continue
            }
            if value.py!.localizedCaseInsensitiveContains(searchText){
                results1[key] = value
                continue
            }
            if value.instrument_name!.localizedCaseInsensitiveContains(searchText){
                results2[key] = value
                continue
            }
            if value.exchange_id!.localizedCaseInsensitiveContains(searchText){
                results3[key] = value
                continue
            }
            if value.exchange_name!.localizedCaseInsensitiveContains(searchText){
                results4[key] = value
                continue
            }

        }
        searchResults.append(contentsOf: sort(datas: results0))
        searchResults.append(contentsOf: sort(datas: results1))
        searchResults.append(contentsOf: sort(datas: results2))
        searchResults.append(contentsOf: sort(datas: results3))
        searchResults.append(contentsOf: sort(datas: results4))
        tableView.reloadData()
    }

    func sort(datas: [String: Search]) -> [Search] {
        return datas.sorted(by: {
            let search0 = dataManager.sSearchEntities[$0.key]
            let search1 = dataManager.sSearchEntities[$1.key]
            let product_id0 = search0?.product_id ?? ""
            let product_id1 = search1?.product_id ?? ""
            if product_id0.count != product_id1.count{
                if product_id0.isEmpty{return false}
                if product_id1.isEmpty{return true}
                return product_id0.count < product_id1.count
            }else {
                if product_id0 == product_id1{
                    let pre_volume0 = search0?.pre_volume ?? 0
                    let pre_volume1 = search1?.pre_volume ?? 0
                    if pre_volume0 == pre_volume1{
                        let ins_id0 = search0?.ins_id ?? ""
                        let ins_id1 = search1?.ins_id ?? ""
                        return ins_id0 > ins_id1
                    }
                    return pre_volume0 > pre_volume1
                }
                return product_id0 < product_id1
            }
        }).map {$0.value}
    }

    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
        }
    }
}
