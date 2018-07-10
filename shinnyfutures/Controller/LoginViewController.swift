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
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let userName = UserDefaults.standard.string(forKey: "userName") {
            self.userName.text = userName
        }

        //Configure the button
        let button = DropDownBtn.init(frame: CGRect(x: 120, y: 94, width: 0, height: 0))
        button.setTitle("期货公司列表加载中...", for: .normal)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 100

        //Add Button to the View Controller
        self.view.addSubview(button)

        //button Constraints, add width/height constrait to itself, add left/right/top/bottom to superVierw
        button.superview?.addConstraint(NSLayoutConstraint.init(item: button, attribute: .left, relatedBy: .equal, toItem: brokerLabel, attribute: .right, multiplier: 1.0, constant: 20))
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

    // MARK: Actions
    @IBAction func login(_ sender: UIButton) {
        let button = self.view.viewWithTag(100) as! DropDownBtn
        let broker_info = button.dropView.dropDownOptions[button.dropView.broker_info]
        let user_name = userName.text
        let password = userPassword.text
        if broker_info.elementsEqual("-1") {
            ToastUtils.showNegativeMessage(message: "请先选择期货公司～")
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
        TDWebSocketUtils.getInstance().sendReqLogin(bid: broker_info, user_name: user_name!, password: password!)
        indicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            if self.indicator.isAnimating {
                self.indicator.stopAnimating()
                ToastUtils.showNegativeMessage(message: "连接超时,目前可能无法登录交易服务器～")
            }
        })
    }

    //Set the drop down menu's options
    @objc func loadBrokerInfo() {
        let jsonArray = DataManager.getInstance().sRtnBrokers[RtnTDConstants.brokers].arrayValue
        let button = self.view.viewWithTag(100) as! DropDownBtn
        for json in jsonArray {
            button.dropView.dropDownOptions.append(json.stringValue)
            button.dropView.tableView?.reloadData()
        }
        if jsonArray.count != 0 {
            if let brokerInfo = UserDefaults.standard.string(forKey: "brokerInfo") {
                let index = Int(brokerInfo)!
                button.dropView.broker_info = index
                button.setTitle(button.dropView.dropDownOptions[index], for: .normal)
            } else {
                button.setTitle("请选择期货公司", for: .normal)
            }
        }
    }

    // MARK: objc methods
    @objc func loginResult() {
        self.indicator.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let button = self.view.viewWithTag(100) as! DropDownBtn
            let code = DataManager.getInstance().sRtnLogin[NotifyConstants.code].stringValue
            if code.elementsEqual("0") {
                //登陆成功的提示在DataManager中的showMessage解析中弹出
                DataManager.getInstance().sIsLogin = true
                UserDefaults.standard.set(self.userName.text!, forKey: "userName")
                UserDefaults.standard.set(String(button.dropView.broker_info), forKey: "brokerInfo")
                //手动式segue，代码触发；自动式指通过点击某个按钮出发
                switch DataManager.getInstance().sToLoginTarget {
                case "Account":
                    self.performSegue(withIdentifier: CommonConstants.LoginToAccount, sender: self.login)
                case "Position":
                    self.performSegue(withIdentifier: CommonConstants.LoginToQuote, sender: self.login)
                    let instrumentId = DataManager.getInstance().sQuotes[1].sorted(by: {$0.key < $1.key}).map {$0.key}[0]
                    DataManager.getInstance().sInstrumentId = instrumentId
                    DataManager.getInstance().sPreInsList = DataManager.getInstance().sRtnMD[RtnMDConstants.ins_list].stringValue
                    MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: instrumentId)
                    MDWebSocketUtils.getInstance().sendSetChart(insList: instrumentId)
                    MDWebSocketUtils.getInstance().sendSetChartDay(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
                    MDWebSocketUtils.getInstance().sendSetChartHour(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
                    MDWebSocketUtils.getInstance().sendSetChartMinute(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
                case "Trade":
                    self.performSegue(withIdentifier: CommonConstants.LoginToTrade, sender: self.login)
                default:
                    break
                }
            }
        })
    }

}

protocol DropDownProtocol: class {
    func dropDownPressed(string: String)
}

class DropDownBtn: UIButton, DropDownProtocol {

    func dropDownPressed(string: String) {
        self.setTitle(string, for: .normal)
        self.dismissDropDown()
    }

    var dropView = DropDownView()

    var height = NSLayoutConstraint()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.darkGray

        dropView = DropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func didMoveToSuperview() {
        if let superview = self.superview {
            superview.addSubview(dropView)
            superview.bringSubview(toFront: dropView)
            dropView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            height = dropView.heightAnchor.constraint(equalToConstant: 0)
        }
    }

    deinit {
        dropView.removeFromSuperview()
        print("DropDownBtn销毁")
    }

    var isOpen = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {

            isOpen = true

            NSLayoutConstraint.deactivate([self.height])

            if (self.dropView.tableView?.contentSize.height)! > UIScreen.main.bounds.height / 4 * 3 {
                self.height.constant = UIScreen.main.bounds.height / 4 * 3
            } else {
                self.height.constant = (self.dropView.tableView?.contentSize.height)!
            }

            NSLayoutConstraint.activate([self.height])

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.layoutIfNeeded()
                self.dropView.center.y += self.dropView.frame.height / 2
            }, completion: nil)

        } else {
            isOpen = false

            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.center.y -= self.dropView.frame.height / 2
                self.dropView.layoutIfNeeded()
            }, completion: nil)

        }
    }

    func dismissDropDown() {
        isOpen = false
        NSLayoutConstraint.deactivate([self.height])
        self.height.constant = 0
        NSLayoutConstraint.activate([self.height])
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.dropView.center.y -= self.dropView.frame.height / 2
            self.dropView.layoutIfNeeded()
        }, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DropDownView: UIView, UITableViewDelegate, UITableViewDataSource {

    //期货公司序号
    var broker_info = -1

    var dropDownOptions = [String]()

    weak var tableView: UITableView?

    weak var delegate: DropDownProtocol?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let tableView = UITableView()
        tableView.backgroundColor = UIColor.darkGray
        self.backgroundColor = UIColor.darkGray

        tableView.delegate = self
        tableView.dataSource = self

        tableView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(tableView)
        self.tableView = tableView

        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    }

    deinit {
        self.tableView?.removeFromSuperview()
        print("DropDownView销毁")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        cell.backgroundColor = UIColor.darkGray
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        broker_info = indexPath.row
        self.delegate?.dropDownPressed(string: dropDownOptions[indexPath.row])
        self.tableView?.deselectRow(at: indexPath, animated: true)
    }

}

