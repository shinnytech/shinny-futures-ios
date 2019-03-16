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

        if let button = self.popoverPresentationController?.sourceView as? UIButton {
            dataManager.sInstrumentId = data
            //刷新标题
            var title = dataManager.getButtonTitle() ?? ""
            title = title + " ▼"
            let size = title.size(withAttributes:[.font: UIFont.systemFont(ofSize:15.0)])
            button.frame = CGRect(x: 0, y: 0, width: size.width + 40, height: 40)
            button.setTitle(title, for: .normal)
            button.layoutIfNeeded()
        }
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.ClearChartViewNotification), object: nil)

        self.dismiss(animated: true, completion: nil)
    }

}
