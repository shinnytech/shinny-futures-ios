//
//  ChangePasswordViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/1.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPasswordBorder: UIView!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var deleteOldPassword: UIButton!
    @IBOutlet weak var newPasswordBorder: UIView!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var deleteNewPassword: UIButton!
    @IBOutlet weak var confirmPasswordBorder: UIView!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var deleteConfirmPassword: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(changeResult), name: Notification.Name(CommonConstants.ChangeSuccessNotification), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        oldPassword.resignFirstResponder()
        newPassword.resignFirstResponder()
        confirmPassword.resignFirstResponder()
    }

    @IBAction func oldPasswordChange(_ sender: UITextField) {
        if sender.text?.count == 0{
            self.deleteOldPassword.isHidden = true
        }else{
            self.deleteOldPassword.isHidden = false
        }
    }

    @IBAction func oldPasswordBegin(_ sender: UITextField) {
        self.oldPasswordBorder.layer.borderColor = CommonConstants.LOGIN_COLOR
    }

    @IBAction func oldPasswordDone(_ sender: UITextField) {
        self.oldPassword.resignFirstResponder()
        self.oldPasswordBorder.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func deleteOldPassword(_ sender: UIButton) {
        self.oldPassword.text = ""
        self.deleteOldPassword.isHidden = true
    }

    @IBAction func newPasswordChange(_ sender: UITextField) {
        if sender.text?.count == 0{
            self.deleteNewPassword.isHidden = true
        }else{
            self.deleteNewPassword.isHidden = false
        }
    }

    @IBAction func newPasswordBegin(_ sender: UITextField) {
        self.newPasswordBorder.layer.borderColor = CommonConstants.LOGIN_COLOR
    }

    @IBAction func newPasswordDone(_ sender: UITextField) {
        self.newPassword.resignFirstResponder()
        self.newPasswordBorder.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func deleteNewPassword(_ sender: UIButton) {
        self.newPassword.text = ""
        self.deleteNewPassword.isHidden = true
    }

    @IBAction func confirmPasswordChange(_ sender: UITextField) {
        if sender.text?.count == 0{
            self.deleteConfirmPassword.isHidden = true
        }else{
            self.deleteConfirmPassword.isHidden = false
        }
    }

    @IBAction func confirmPasswordBegin(_ sender: UITextField) {
        self.confirmPasswordBorder.layer.borderColor = CommonConstants.LOGIN_COLOR
    }

    @IBAction func confirmPasswordDone(_ sender: UITextField) {
        self.confirmPassword.resignFirstResponder()
        self.confirmPasswordBorder.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func deleteConfirmPassword(_ sender: UIButton) {
        self.confirmPassword.text = ""
        self.deleteConfirmPassword.isHidden = true
    }

    @IBAction func change(_ sender: UIButton) {
        guard let old_password = oldPassword.text else {return}
        guard let new_password = newPassword.text else{return}
        guard let confirm_password = confirmPassword.text else {return}
        if old_password.isEmpty {
            ToastUtils.showNegativeMessage(message: "旧密码不能为空～")
        }
        if new_password.isEmpty {
            ToastUtils.showNegativeMessage(message: "新密码不能为空～")
        }
        if confirm_password.isEmpty {
            ToastUtils.showNegativeMessage(message: "请确认新密码～")
        }
        if !confirm_password.elementsEqual(new_password) {
            ToastUtils.showNegativeMessage(message: "新密码确认不一致～")
        }

        TDWebSocketUtils.getInstance().sendReqPassword(new_password: new_password, old_password: old_password)
        
    }

    // MARK: objc methods
    @objc func changeResult() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.navigationController?.popViewController(animated: true)
        })
    }

    @IBAction func back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }



}
