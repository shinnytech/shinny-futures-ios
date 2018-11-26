//
//  OptionalPopupCollectionViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/10.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class OptionalPopupCollectionViewController: UICollectionViewController {

    // MARK: Properties
    var insList = FileUtils.getOptional()
    let dataManager = DataManager.getInstance()

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionalCollectionViewCell", for: indexPath) as! OptionalCollectionViewCell

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
        let instrumentId = insList[index]
        if let button = self.popoverPresentationController?.sourceView as? UIButton {
            dataManager.sInstrumentId = instrumentId
            let title = dataManager.getButtonTitle()
            button.setTitle(title, for: .normal)
        }
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.ClearChartViewNotification), object: nil)
        self.dismiss(animated: true, completion: nil)
    }

}
