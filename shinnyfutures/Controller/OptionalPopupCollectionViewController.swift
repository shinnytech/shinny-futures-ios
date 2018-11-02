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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
            if let name = dataManager.sSearchEntities[instrumentId]?.instrument_name {
                button.setTitle(name, for: .normal)
            } else {
                button.setTitle(instrumentId, for: .normal)
            }
            dataManager.sInstrumentId = instrumentId
        }
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.ClearChartViewNotification), object: nil)
        self.dismiss(animated: true, completion: nil)
    }

}
