//
//  QuoteNavigationCollectionViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/17.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class QuoteNavigationCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: Properties
    var insList = [String]()
    var nameList = [String]()
    var mainViewController: MainViewController!
    let manager = DataManager.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        if FileUtils.getOptional().isEmpty {
            loadDatas(index: 1)
        }else{
            loadDatas(index: 0)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(CommonConstants.LatestFileParsedNotification), object: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        mainViewController = self.parent as? MainViewController
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return nameList.count

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuoteNavigationCollectionViewCell", for: indexPath) as! QuoteNavigationCollectionViewCell
        cell.quote.text = nameList[indexPath.row]

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var instrument_id = insList[indexPath.row]
        if instrument_id.contains("&"){
            instrument_id = String(instrument_id.split(separator: "&")[0])
        }
        let ins = instrument_id.components(separatedBy: CharacterSet.decimalDigits).joined()
        if let quoteTableViewController = mainViewController.quotePageViewController.viewControllers?.first as? QuoteTableViewController {
            var count = 0
            for instrumentId in quoteTableViewController.insList {
                if instrumentId.contains(ins) {
                    quoteTableViewController.tableView.scrollToRow(at: IndexPath(row: count, section: 0), at: .top, animated: false)
                    quoteTableViewController.sendSubscribeQuotes()
                    break
                }
                count += 1
            }
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = nameList[indexPath.row]
        let width = textWidth(text: label, font: UIFont(name: "Helvetica Neue", size: 17)) + 10
        return CGSize(width: width, height: 44)
    }

    func textWidth(text: String, font: UIFont?) -> CGFloat {
        let attributes = font != nil ? [NSAttributedStringKey.font: font] : [:]
        return text.size(withAttributes: attributes as [NSAttributedStringKey : Any]).width
    }

    // MARK: Public Methods
    func loadDatas(index: Int) {
        insList.removeAll()
        if index >= manager.sInsListNames.count {
            return
        }

        insList = manager.sInsListNames[index].map{$0.value}

        nameList = manager.sInsListNames[index].map{$0.key}

        collectionView?.reloadData()
        //collectionView更改数据源清空collectionviewLayout的缓存，让autolayout重新计算UICollectionView的cell的size，防止崩溃
        collectionView?.collectionViewLayout.invalidateLayout()

    }

    //latestFile文件解析完毕后刷新导航列表
    @objc func refresh() {
        insList.removeAll()
        var index = 1
        if manager.sQuotes[0].isEmpty {
            index = 1
        }else{
            index = 0
        }

        if index >= manager.sInsListNames.count {
            return
        }

        insList = manager.sInsListNames[index].map{$0.value}

        nameList = manager.sInsListNames[index].map{$0.key}

        self.collectionView?.reloadData()
        //collectionView更改数据源清空collectionviewLayout的缓存，让autolayout重新计算UICollectionView的cell的size，防止崩溃
        self.collectionView?.collectionViewLayout.invalidateLayout()

    }

}
