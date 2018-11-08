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
    @IBOutlet weak var brokerLabel: UILabel!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    let sDataManager = DataManager.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userName = UserDefaults.standard.string(forKey: "userName") {
            self.userName.text = userName
        }
        
        if let userPassword = UserDefaults.standard.string(forKey: "userPassword") {
            self.userPassword.text = userPassword
        }
        
        //Configure the button
        let button = DropDownBtn.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitle("", for: .normal)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 100
        
        //Add Button to the View Controller
        self.view.addSubview(button)
        
        //button Constraints, add width/height constrait to itself, add left/right/top/bottom to superVierw
        button.superview?.addConstraint(NSLayoutConstraint.init(item: button, attribute: .left, relatedBy: .equal, toItem: userName, attribute: .left, multiplier: 1.0, constant: 0))
        button.superview?.addConstraint(NSLayoutConstraint.init(item: button, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: -20))
        button.superview?.addConstraint(NSLayoutConstraint.init(item: button, attribute: .top, relatedBy: .equal, toItem: brokerLabel, attribute: .top, multiplier: 1.0, constant: 0))
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        loadBrokerInfo()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadBrokerInfo), name: Notification.Name(CommonConstants.BrokerInfoNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginResult), name: Notification.Name(CommonConstants.LoginNotification), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        let button = self.view.viewWithTag(100)
        button?.removeFromSuperview()
        print("登陆页销毁")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        userName.resignFirstResponder()
        userPassword.resignFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func login(_ sender: UIButton) {
        let button = self.view.viewWithTag(100) as! DropDownBtn
        if button.dropView.dropDownOptions.count == 0{
            ToastUtils.showNegativeMessage(message: "期货公司列表为空～")
            return
        }
        if button.dropView.selected_index == -1 {
            ToastUtils.showNegativeMessage(message: "请先选择期货公司～")
            return
        }
        let broker_info = button.dropView.dropDownOptions[button.dropView.selected_index]
        let user_name = userName.text
        let password = userPassword.text
        if user_name?.count == 0 {
            ToastUtils.showNegativeMessage(message: "用户名为空～")
            return
        }
        if password?.count == 0 {
            ToastUtils.showNegativeMessage(message: "密码为空～")
            return
        }
        TDWebSocketUtils.getInstance().sendReqLogin(bid: broker_info, user_name: user_name!, password: password!)
        sDataManager.sUser_id = user_name!
    }


    @IBAction func back(_ sender: UIBarButtonItem) {
        if let navigationController = self.navigationController  {
            navigationController.popViewController(animated: true)
        }
    }

    //Set the drop down menu's options
    @objc func loadBrokerInfo() {
        let jsonArray = sDataManager.sRtnBrokers[RtnTDConstants.brokers].arrayValue
        let button = self.view.viewWithTag(100) as! DropDownBtn
        for json in jsonArray {
            button.dropView.dropDownOptions.append(json.stringValue)
            button.dropView.tableView?.reloadData()
        }
        if jsonArray.count != 0 {
            if let brokerInfo = UserDefaults.standard.string(forKey: "brokerInfo") {
                var index = Int(brokerInfo)!
                if index > button.dropView.dropDownOptions.count {
                    index = 0
                }
                button.dropView.selected_index = index
                button.setTitle(button.dropView.dropDownOptions[index], for: .normal)
            } else {
                button.setTitle("请选择期货公司", for: .normal)
            }
        }else{
            TDWebSocketUtils.getInstance().reconnectTD(url: CommonConstants.TRANSACTION_URL)
        }
    }
    
    // MARK: objc methods
    @objc func loginResult() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            let button = self.view.viewWithTag(100) as! DropDownBtn
            //登陆成功的提示在DataManager中的showMessage解析中弹出
            self.sDataManager.sIsLogin = true
            UserDefaults.standard.set(self.userName.text!, forKey: "userName")
            UserDefaults.standard.set(self.userPassword.text!, forKey: "userPassword")
            UserDefaults.standard.set(String(button.dropView.selected_index), forKey: "brokerInfo")
            //手动式segue，代码触发；自动式指通过点击某个按钮出发
            switch self.sDataManager.sToLoginTarget {
            case "Account":
                self.performSegue(withIdentifier: CommonConstants.LoginToAccount, sender: self.login)
            case "Position":
                self.performSegue(withIdentifier: CommonConstants.LoginToQuote, sender: self.login)
                let instrumentId = self.sDataManager.sQuotes[1].map {$0.key}[0]
                self.sDataManager.sInstrumentId = instrumentId
                self.sDataManager.sPreInsList = self.sDataManager.sRtnMD[RtnMDConstants.ins_list].stringValue
                MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: instrumentId)
                MDWebSocketUtils.getInstance().sendSetChart(insList: instrumentId)
                MDWebSocketUtils.getInstance().sendSetChartDay(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
                MDWebSocketUtils.getInstance().sendSetChartHour(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
                MDWebSocketUtils.getInstance().sendSetChartMinute(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
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
    @IBAction func userNameDone(_ sender: UITextField) {
        userName.resignFirstResponder()
    }

    @IBAction func passwordDone(_ sender: UITextField) {
        userPassword.resignFirstResponder()
    }
}



