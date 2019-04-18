//
//  LoginViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/28.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK：Properties
    @IBOutlet weak var brokerImage: UIImageView!
    @IBOutlet weak var brokerLabel: UILabel!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var passwordLock: UIButton!
    @IBOutlet weak var nameLock: UIButton!
    @IBOutlet weak var deleteName: UIButton!
    @IBOutlet weak var deletePassword: UIButton!
    @IBOutlet weak var nameBorder: UIView!
    @IBOutlet weak var passwordBorder: UIView!

    let sDataManager = DataManager.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureRecognizerLabel = UITapGestureRecognizer(target: self, action: #selector(toBrokerList))
        brokerLabel.addGestureRecognizer(gestureRecognizerLabel)
        let gestureRecognizerImage = UITapGestureRecognizer(target: self, action: #selector(toBrokerList))
        brokerImage.addGestureRecognizer(gestureRecognizerImage)
        if let brokerInfo = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_BROKER) {
            self.brokerLabel.text = brokerInfo
        }else if !sDataManager.sBrokers.isEmpty{
            self.brokerLabel.text = sDataManager.sBrokers[0]
        }

        var isLockUserName = false
        var isLockPassword = false

        isLockUserName = UserDefaults.standard.bool(forKey: CommonConstants.CONFIG_LOCK_USER_NAME)
        if isLockUserName{
            nameLock.setTitle("✓", for: .normal)
        }else{
            nameLock.setTitle("", for: .normal)
        }

        isLockPassword = UserDefaults.standard.bool(forKey: CommonConstants.CONFIG_LOCK_PASSWORD)
        if isLockPassword{
            passwordLock.setTitle("✓", for: .normal)
        }else{
            passwordLock.setTitle("", for: .normal)
        }

        if let userName = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_USER_NAME) {
            if isLockUserName {
                self.userName.text = userName
            }else{
                self.userName.text = ""
            }

            if self.userName.text!.isEmpty{
                self.deleteName.isHidden = true
            }else{
                self.deleteName.isHidden = false
            }

        }

        if let userPassword = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_PASSWORD) {
            if isLockPassword {
                self.userPassword.text = userPassword
            }else {
                self.userPassword.text = ""
            }

            if self.userPassword.text!.isEmpty{
                self.deletePassword.isHidden = true
            }else{
                self.deletePassword.isHidden = false
            }

        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadBrokerInfo), name: Notification.Name(CommonConstants.BrokerInfoNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginResult), name: Notification.Name(CommonConstants.LoginNotification), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(changePassword), name: Notification.Name(CommonConstants.WeakPasswordNotification), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        print("登陆页销毁")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        userName.resignFirstResponder()
        userPassword.resignFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func login(_ sender: UIButton) {

        let broker_info = brokerLabel.text
        let user_name = userName.text
        let password = userPassword.text

        if broker_info?.count == 0 {
            ToastUtils.showNegativeMessage(message: "期货公司为空～")
            return
        }

        if user_name?.count == 0 {
            ToastUtils.showNegativeMessage(message: "用户名为空～")
            return
        }
        if password?.count == 0 {
            ToastUtils.showNegativeMessage(message: "密码为空～")
            return
        }
        TDWebSocketUtils.getInstance().sendReqLogin(bid: broker_info!, user_name: user_name!, password: password!)
    }

    //Set the drop down menu's options
    @objc func loadBrokerInfo() {
        let brokerArray = sDataManager.sBrokers
        guard let broker = self.brokerLabel.text else{return}
        if broker.isEmpty && !brokerArray.isEmpty {
            self.brokerLabel.text = brokerArray[0]
        }
    }
    
    // MARK: objc methods
    @objc func loginResult() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            //登陆成功的提示在DataManager中的showMessage解析中弹出
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy年MM日dd日"
            let date = dateFormat.string(from: Date())
            UserDefaults.standard.set(date, forKey: CommonConstants.CONFIG_LOGIN_DATE)
            UserDefaults.standard.set(self.brokerLabel.text!, forKey: CommonConstants.CONFIG_BROKER)
            UserDefaults.standard.set(self.userName.text!, forKey: CommonConstants.CONFIG_USER_NAME)
            UserDefaults.standard.set(self.userPassword.text!, forKey: CommonConstants.CONFIG_PASSWORD)

            //手动式segue，代码触发；自动式指通过点击某个按钮出发
            switch self.sDataManager.sToLoginTarget {
            case "Login":
                self.navigationController?.popViewController(animated: true)
            case "Account":
                self.performSegue(withIdentifier: CommonConstants.LoginToAccount, sender: self.login)
            case "Position":
                self.performSegue(withIdentifier: CommonConstants.LoginToQuote, sender: self.login)
                let instrumentId = self.sDataManager.sQuotes[1].map {$0.key}[0]
                self.sDataManager.sInstrumentId = instrumentId
                self.sDataManager.sPreInsList = self.sDataManager.sRtnMD.ins_list
            case "Trade":
                self.performSegue(withIdentifier: CommonConstants.LoginToTrade, sender: self.login)
            case "BankTransfer":
                self.performSegue(withIdentifier: CommonConstants.LoginToBankTransfer, sender: self.login)
            case "SwitchToPosition":
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchToPositionNotification), object: nil)
                if let navigationController = self.navigationController  {
                    navigationController.popViewController(animated: true)
                }
                break
            case "SwitchToOrder":
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchToOrderNotification), object: nil)
                if let navigationController = self.navigationController  {
                    navigationController.popViewController(animated: true)
                }
                break
            case "SwitchToTransaction":
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchToTransactionNotification), object: nil)
                if let navigationController = self.navigationController  {
                    navigationController.popViewController(animated: true)
                }
                break
            default:
                break
            }
            
        })
    }

    //弱密码修改
    @objc func changePassword(){
        self.userPassword.text = ""
        self.performSegue(withIdentifier: CommonConstants.LoginToChangePassword, sender: self.login)
    }

    @objc func toBrokerList(){
        self.performSegue(withIdentifier: CommonConstants.LoginToBroker, sender: self.brokerLabel)
    }

    @IBAction func brokerViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? BrokerTableViewController {
            let broker = sourceViewController.dataRetrurn
            if !broker.isEmpty{
                self.brokerLabel.text = broker
            }
        }
        print("我从期货公司列表页来～")
    }

    @IBAction func userNameChange(_ sender: UITextField) {
        if sender.text?.count == 0{
            self.deleteName.isHidden = true
        }else{
            self.deleteName.isHidden = false
        }
    }

    @IBAction func userNameBegin(_ sender: UITextField) {
        self.nameBorder.layer.borderColor = CommonConstants.LOGIN_COLOR
    }


    @IBAction func userNameDone(_ sender: UITextField) {
        self.userName.resignFirstResponder()
        self.nameBorder.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func deleteUserName(_ sender: UIButton) {
        self.userName.text = ""
        self.deleteName.isHidden = true
    }

    @IBAction func passwordChange(_ sender: UITextField) {
        if sender.text?.count == 0{
            self.deletePassword.isHidden = true
        }else{
            self.deletePassword.isHidden = false
        }
    }

    @IBAction func passwordBegin(_ sender: UITextField) {
        self.passwordBorder.layer.borderColor = CommonConstants.LOGIN_COLOR
    }


    @IBAction func passwordDone(_ sender: UITextField) {
        self.userPassword.resignFirstResponder()
        self.passwordBorder.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func deletePassword(_ sender: UIButton) {
        self.userPassword.text = ""
        self.deletePassword.isHidden = true
    }

    @IBAction func lockOrUnlockPassword(_ sender: UIButton) {
        guard let title = passwordLock.title(for: .normal)else {return}
        if !title.isEmpty{
            passwordLock.setTitle("", for: .normal)
            UserDefaults.standard.set(false, forKey: CommonConstants.CONFIG_LOCK_PASSWORD)
        }else{
            passwordLock.setTitle("✓", for: .normal)
            UserDefaults.standard.set(true, forKey: CommonConstants.CONFIG_LOCK_PASSWORD)
        }
    }

    @IBAction func lockOrUnlockName(_ sender: UIButton) {
        guard let title = nameLock.title(for: .normal)else {return}
        if !title.isEmpty{
            nameLock.setTitle("", for: .normal)
            UserDefaults.standard.set(false, forKey: CommonConstants.CONFIG_LOCK_USER_NAME)
        }else{
            nameLock.setTitle("✓", for: .normal)
            UserDefaults.standard.set(true, forKey: CommonConstants.CONFIG_LOCK_USER_NAME)
        }
    }

    @IBAction func back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
}



