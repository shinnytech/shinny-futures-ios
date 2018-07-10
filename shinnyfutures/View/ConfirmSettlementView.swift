//
//  ConfirmSettlementView.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/10.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class ConfirmSettlementView {
    private let label: UITextView!
    private let ok: UIButton!
    private let cancel: UIButton!

    private static let instance: ConfirmSettlementView = {
        let confirmSettlementView = ConfirmSettlementView()
        return confirmSettlementView
    }()

    class func getInstance() -> ConfirmSettlementView {
        return instance
    }

    private init() {
        label = UITextView(frame: CGRect.zero )
        ok = UIButton(frame: CGRect.zero)
        cancel = UIButton(frame: CGRect.zero)

        label.isEditable = false
        label.textAlignment = NSTextAlignment.center
        label.text = "message"
        label.backgroundColor =   UIColor.white //UIColor.whiteColor()
        label.textColor = UIColor.black //TEXT COLOR
        label.sizeToFit()
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 4, height: 3)
        label.layer.shadowOpacity = 0.3
        label.alpha = 1
        let font = UIFont(name: "Menlo", size: 10)
        label.font = font
        label.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - 64)

        ok.setTitle("确定", for: .normal)
        ok.setTitleColor(UIColor.black, for: .normal)
        ok.backgroundColor = UIColor.gray
        ok.layer.cornerRadius = 10.0
        ok.layer.masksToBounds = true
        ok.frame = CGRect(x: 10, y: UIApplication.shared.statusBarFrame.height + label.frame.height + 10, width: (UIScreen.main.bounds.width - 30) / 2, height: 44)
        ok.addTarget(self, action: #selector(okAction), for: .touchUpInside)

        cancel.setTitle("取消", for: .normal)
        cancel.setTitleColor(UIColor.black, for: .normal)
        cancel.backgroundColor = UIColor.gray
        cancel.layer.cornerRadius = 10.0
        cancel.layer.masksToBounds = true
        cancel.frame = CGRect(x: 20 + ok.frame.width, y: UIApplication.shared.statusBarFrame.height + label.frame.height + 10, width: (UIScreen.main.bounds.width - 30) / 2, height: 44)
        cancel.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)

    }

    @objc func okAction() {
        if DataManager.getInstance().sMobileConfirmSettlement[RtnTDConstants.ret].stringValue.elementsEqual("-1") {
            dismiss()
        }
        if DataManager.getInstance().sMobileConfirmSettlement[RtnTDConstants.ret].stringValue.elementsEqual("1") {
            TDWebSocketUtils.getInstance().sendReqConfirmSettlement(reqId: "5", msg: "yes")
            dismiss()
        }
    }

    @objc func cancelAction() {
        if DataManager.getInstance().sMobileConfirmSettlement[RtnTDConstants.ret].stringValue.elementsEqual("-1") {
            dismiss()
        }
        if DataManager.getInstance().sMobileConfirmSettlement[RtnTDConstants.ret].stringValue.elementsEqual("1") {
            TDWebSocketUtils.getInstance().sendReqConfirmSettlement(reqId: "6", msg: "no")
        }

    }

    private func dismiss() {
        self.label.removeFromSuperview()
        self.ok.removeFromSuperview()
        self.cancel.removeFromSuperview()
    }

    func showConfirmSettlement(message: String) {
        label.text = message
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.addSubview(label)
        appDelegate.window!.addSubview(ok)
        appDelegate.window!.addSubview(cancel)
    }
}
