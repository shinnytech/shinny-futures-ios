//
//  PopupCollectionViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/10.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class PopupCollectionViewController: UICollectionViewController {

    // MARK: Properties
    var insList: [String]!
    let dataManager = DataManager.getInstance()
    var flag: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return insList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopupCollectionViewCell", for: indexPath) as! PopupCollectionViewCell

        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5

        let ins = insList[indexPath.row]

        if let search = dataManager.sSearchEntities[ins] {
            cell.ins.text = search.instrument_name
        } else {
            cell.ins.text = ins
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let data = insList[index]

        if flag.elementsEqual("optional") {
            if let button = self.popoverPresentationController?.sourceView as? UIButton {
                dataManager.sInstrumentId = data
                let title = dataManager.getButtonTitle()
                button.setTitle(title, for: .normal)
            }
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.ClearChartViewNotification), object: nil)
        }else{
            var fragmengType = ""
            if data.contains("秒"){
                UserDefaults.standard.set(CommonConstants.klineDuration[index], forKey: CommonConstants.CONFIG_KLINE_SECOND_TYPE)
                fragmengType = CommonConstants.SECOND_FRAGMENT
            }else if data.contains("分"){
                UserDefaults.standard.set(CommonConstants.klineDuration[index], forKey: CommonConstants.CONFIG_KLINE_MINUTE_TYPE)
                fragmengType = CommonConstants.MINUTE_FRAGMENT
            }else if data.contains("时") {
                UserDefaults.standard.set(CommonConstants.klineDuration[index], forKey: CommonConstants.CONFIG_KLINE_HOUR_TYPE)
                fragmengType = CommonConstants.HOUR_FRAGMENT
            }else{
                UserDefaults.standard.set(CommonConstants.klineDuration[index], forKey: CommonConstants.CONFIG_KLINE_DAY_TYPE)
                fragmengType = CommonConstants.DAY_FRAGMENT
            }
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchKlineNotification), object: nil, userInfo: ["durationIndex": index, "fragmentType": fragmengType])
        }

        self.dismiss(animated: true, completion: nil)
    }

}
