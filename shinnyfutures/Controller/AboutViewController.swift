//
//  AboutViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/10/31.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    //MARKS: Propertiers
    @IBOutlet weak var version: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        version.text = DataManager.getInstance().sAppVersion
    }

    //MARK: actions
    @IBAction func back(_ sender: UIBarButtonItem) {
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
    }
    

}
