//
//  AddDurationCollectionViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2019/2/13.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class AddDurationCollectionViewController: UICollectionViewController {

    // MARK: Properties
    var durations: [String]!
    var durationsDefault: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        durations = CommonConstants.klineDurationAll
        durationsDefault = UserDefaults.standard.stringArray(forKey: CommonConstants.CONFIG_SETTING_KLINE_DURATION_DEFAULT)
        let screenWidth = UIScreen.main.bounds.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: screenWidth/5, height: 50)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectionView!.collectionViewLayout = layout
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return durations.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddDurationCollectionViewCell", for: indexPath) as! AddDurationCollectionViewCell

        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 0.5

        let duration = durations[indexPath.row]
        cell.duration.text = duration

        if durationsDefault.contains(duration) {
            cell.duration.backgroundColor = CommonConstants.ADD_DURATION_SELECTED
        }else {
            cell.duration.backgroundColor = CommonConstants.BOLD_DEVIDER
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let duration = durations[index]
        let cell = collectionView.cellForItem(at: indexPath) as! AddDurationCollectionViewCell
        if durationsDefault.contains(duration) {
            if let index = durationsDefault.index(of: duration){
                durationsDefault.remove(at: index)
                cell.duration.backgroundColor = CommonConstants.BOLD_DEVIDER
            }
        }else{
            durationsDefault.append(duration)
            cell.duration.backgroundColor = CommonConstants.ADD_DURATION_SELECTED
        }
         UserDefaults.standard.set(durationsDefault, forKey: CommonConstants.CONFIG_SETTING_KLINE_DURATION_DEFAULT)

    }
}
