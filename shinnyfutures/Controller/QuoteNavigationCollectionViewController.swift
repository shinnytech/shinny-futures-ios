//
//  QuoteNavigationCollectionViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/17.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class QuoteNavigationCollectionViewController: UICollectionViewController {
    // MARK: Properties
    var quotes = [String]()
    var mainViewController: MainViewController!
    let mananger = DataManager.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadDatas(index: 1)

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(CommonConstants.LatestFileParsedNotification), object: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        mainViewController = self.parent as! MainViewController
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
        return quotes.count

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuoteNavigationCollectionViewCell", for: indexPath) as! QuoteNavigationCollectionViewCell

        cell.quote.text = quotes[indexPath.row]

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? QuoteNavigationCollectionViewCell {
            if let instrumentName = cell.quote.text {
                if let quoteTableViewController = mainViewController.quotePageViewController.viewControllers?.first as? QuoteTableViewController {
                    var count = 0
                    let quotes = DataManager.getInstance().sQuotes[quoteTableViewController.index].sorted(by: {$0.key < $1.key}).map {$0.value}
                    for quote in quotes {
                        if quote.instrument_name.contains(instrumentName) {
                            quoteTableViewController.tableView.scrollToRow(at: IndexPath(row: count, section: 0), at: .top, animated: false)
                            quoteTableViewController.sendSubscribeQuotes()
                        }
                        count += 1
                    }
                }
            }

        }
    }

    // MARK: Public Methods
    func loadDatas(index: Int) {
        quotes.removeAll()
        if index >= mananger.sInsListNames.count {
            return
        }
        for instrumentName in mananger.sInsListNames[index] {
            if instrumentName.contains("&") {
                let combineName = DataManager.getInstance().sSearchEntities[String(instrumentName.split(separator: " ")[1].split(separator: "&")[0])]?.instrument_name
                let pattern = "\\d+"
                guard let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0)) else {
                    return
                }
                let results = regex.matches(in: combineName!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: combineName!.count))
                for result in results {
                    quotes.append(combineName!.replacingOccurrences(of: (combineName! as NSString).substring(with: result.range), with: ""))
                }
            } else {
                quotes.append(instrumentName)
            }
        }
        collectionView?.reloadData()
        //collectionView更改数据源清空collectionviewLayout的缓存，让autolayout重新计算UICollectionView的cell的size，防止崩溃
        collectionView?.collectionViewLayout.invalidateLayout()

    }

    //latestFile文件解析完毕后刷新导航列表
    @objc func refresh() {
        quotes.removeAll()
        let index = 1
        if index >= mananger.sInsListNames.count {
            return
        }
        for instrumentName in mananger.sInsListNames[index] {
            if instrumentName.contains("&") {
                let combineName = DataManager.getInstance().sSearchEntities[String(instrumentName.split(separator: " ")[1].split(separator: "&")[0])]?.instrument_name
                let pattern = "\\d+"
                guard let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0)) else {
                    return
                }
                let results = regex.matches(in: combineName!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: combineName!.count))
                for result in results {
                    quotes.append(combineName!.replacingOccurrences(of: (combineName! as NSString).substring(with: result.range), with: ""))
                }
            } else {
                quotes.append(instrumentName)
            }
        }
        self.collectionView?.reloadData()
        //collectionView更改数据源清空collectionviewLayout的缓存，让autolayout重新计算UICollectionView的cell的size，防止崩溃
        self.collectionView?.collectionViewLayout.invalidateLayout()

    }

}
