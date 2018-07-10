//
//  ToastUtils.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/10.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class ToastUtils {
    class private func showAlert(backgroundColor: UIColor, textColor: UIColor, message: String) {

        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = NSTextAlignment.center
        label.text = message
        label.font = UIFont(name: "", size: 15)
        label.adjustsFontSizeToFitWidth = true

        label.backgroundColor =  backgroundColor //UIColor.whiteColor()
        label.textColor = textColor //TEXT COLOR

        label.sizeToFit()
        label.numberOfLines = 4
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 4, height: 3)
        label.layer.shadowOpacity = 0.3
        label.frame = CGRect(x: appDelegate.window!.frame.size.width, y: 64, width: appDelegate.window!.frame.size.width, height: 44)

        label.alpha = 1

        appDelegate.window!.addSubview(label)

        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            label.frame.origin.x = 0
        }, completion: {
            (_: Bool) in
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                label.alpha = 0
            }, completion: { (_: Bool) in
                label.removeFromSuperview()
            })
        })
        
    }

    class func showPositiveMessage(message: String) {
        showAlert(backgroundColor: UIColor.green, textColor: UIColor.black, message: message)
    }
    class func showNegativeMessage(message: String) {
        showAlert(backgroundColor: UIColor.red, textColor: UIColor.black, message: message)
    }
}
