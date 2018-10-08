//
//  ConfirmSettlementView.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/10.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class ResponsibilityView {
    private let label: UITextView!
    private let ok: UIButton!
    private let background: UIView!

    private static let instance: ResponsibilityView = {
        let confirmSettlementView = ResponsibilityView()
        return confirmSettlementView
    }()

    class func getInstance() -> ResponsibilityView {
        return instance
    }

    private init() {
        label = UITextView(frame: CGRect.zero )
        ok = UIButton(frame: CGRect.zero)
        background = UIView(frame: CGRect.zero)

        label.isEditable = false
        label.isSelectable = false
        label.textAlignment = NSTextAlignment.left
        label.text = "message"
        label.backgroundColor =   UIColor.darkGray //UIColor.whiteColor()
        label.textColor = UIColor.white //TEXT COLOR
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 4, height: 3)
        label.layer.shadowOpacity = 0.3
        if let font = UIFont(name: "Helvetica Neue", size: 20) {
            label.font = font
        }
        label.frame = CGRect(x: UIScreen.main.bounds.width, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - 44)

        ok.setTitle("同意", for: .normal)
        ok.showsTouchWhenHighlighted = true
        ok.setTitleColor(UIColor.white, for: .normal)
        ok.backgroundColor = UIColor.black
        ok.layer.cornerRadius = 10.0
        ok.layer.masksToBounds = true
        ok.frame = CGRect(x: UIScreen.main.bounds.width, y: UIApplication.shared.statusBarFrame.height + label.frame.height, width: UIScreen.main.bounds.width, height: 44)
        ok.addTarget(self, action: #selector(okAction), for: .touchUpInside)

        background.backgroundColor = UIColor.darkGray
        background.frame = CGRect(x: UIScreen.main.bounds.width, y: UIApplication.shared.statusBarFrame.height + label.frame.height, width: UIScreen.main.bounds.width, height: 44)
    }

    @objc func okAction() {
        dismiss()
    }

    private func dismiss() {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.label.alpha = 0
            self.ok.alpha = 0
            self.background.alpha = 0
        }, completion: { (_: Bool) in
            self.label.removeFromSuperview()
            self.ok.removeFromSuperview()
            self.background.removeFromSuperview()
        })

    }

    func showResponsibility() {
        label.text = "\n" +

        "免责条款声明\n\n" +

        "上海信易信息科技股份有限公司（其中包括但不限于公司的董事、执行官、雇员、顾问和代理商）明确拒绝对快期软件做" +
        "任何明示或暗示的担保。由于软件系统开发本身的复杂性，无法保证软件完全没有错误。您选择使用快期期货交易终端软件" +
        "即表示您同意错误和/或遗漏的存在，在任何情况下上海信易信息科技股份有限公司对于直接、间接、特殊的、偶然的、或" +
        "间接产生的、使用或无法使用本软件进行交易和投资造成的盈亏、直接或间接引起的赔偿、损失、债务或是任何交易中止均" +
        "不承担责任和义务。\n\n" +

        "本公司授权用户在协议约定的服务期限内可以使用本软件及随本软件提供的服务。本软件作为客户端软件，是整体软件系统" +
        "的一个组成部分；任何情况下，本公司不向任何客户转让本软件的所有权。\n\n" +

        "此声明永久有效。\n\n" +

        "上海信易信息科技股份有限公司\n\n"
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.addSubview(label)
        appDelegate.window!.addSubview(background)
        appDelegate.window!.addSubview(ok)

        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.label.frame.origin.x = 0
            self.ok.frame.origin.x = 0
            self.background.frame.origin.x = 0
        }, completion: nil)

    }
}
