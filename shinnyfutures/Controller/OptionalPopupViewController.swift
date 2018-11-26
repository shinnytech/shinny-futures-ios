//
//  OptionalPopupViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/7.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class OptionalPopupViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var drag: UIButton!
    var instrumentId: String?
    var isOptional = false
    let manager = DataManager.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        let optional = FileUtils.getOptional()
        if let ins = instrumentId, !optional.contains(ins) {
            save.setImage(UIImage(named: "heart_outline", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil), for: .normal)
            save.setTitle("添加自选", for: .normal)
        }else{
            save.setImage(UIImage(named: "heart", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil), for: .normal)
            save.setTitle("删除自选", for: .normal)
        }

        if isOptional {
            drag.isHidden = false
        }else{
            drag.isHidden = true
        }
    }

    // MARK: Actions
    @IBAction func save(_ sender: UIButton) {
        if let ins = instrumentId {
            manager.saveOrRemoveIns(ins: ins)
            let optional = FileUtils.getOptional()
            if let ins = instrumentId, !optional.contains(ins) {
                save.setImage(UIImage(named: "heart_outline", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil), for: .normal)
                save.setTitle("添加自选", for: .normal)
            }else{
                save.setImage(UIImage(named: "heart", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil), for: .normal)
                save.setTitle("删除自选", for: .normal)
            }
            if isOptional {
                MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: FileUtils.getOptional().joined(separator: ","))
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func drag(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.PopupOptionalInsListNotification), object: nil)
        }
    }
}
