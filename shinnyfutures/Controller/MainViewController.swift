//
//  MainViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/28.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainViewController: UIViewController, MDWebSocketUtilsDelegate, TDWebSocketUtilsDelegate, UIPopoverPresentationControllerDelegate {
    // MARK: Properties
    @IBOutlet weak var slideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var menu: UIStackView!
    @IBOutlet weak var optional: UIButton!
    @IBOutlet weak var domain: UIButton!
    @IBOutlet weak var shanghai: UIButton!
    @IBOutlet weak var nengyuan: UIButton!
    @IBOutlet weak var dalian: UIButton!
    @IBOutlet weak var zhengzhou: UIButton!
    @IBOutlet weak var zhongjin: UIButton!
    @IBOutlet weak var dalianzuhe: UIButton!
    @IBOutlet weak var zhengzhouzuhe: UIButton!
    @IBOutlet weak var account: UIButton!
    @IBOutlet weak var position: UIButton!
    @IBOutlet weak var trade: UIButton!
    @IBOutlet weak var transfer: UIButton!
    @IBOutlet weak var feedback: UIButton!
    @IBOutlet weak var background: UIButton!
    @IBOutlet weak var left: UIButton!
    @IBOutlet weak var right: UIButton!
    @IBOutlet weak var quoteNavgationView: UIView!
    @IBOutlet weak var quoteNavigationConstraint: NSLayoutConstraint!
    var isSlideMenuHidden = true
    var quotePageViewController: QuotePageViewController!
    var quoteNavigationCollectionViewController: QuoteNavigationCollectionViewController!
    let mdWebSocketUtils = MDWebSocketUtils.getInstance()
    let tdWebSocketUtils = TDWebSocketUtils.getInstance()
    var lastMDTime = CACurrentMediaTime()
    var lastTDTime = CACurrentMediaTime()
    var mdURLs = [String]()
    var index = 0
    let button =  UIButton(type: .custom)

    func websocketDidReceiveMessage(socket: TDWebSocketUtils, text: String) {
        DispatchQueue.global().async {
            let json = JSON(parseJSON: text)
            let aid = json["aid"].stringValue
            switch aid {
            case "rtn_brokers":
                self.tdWebSocketUtils.ping()
                DataManager.getInstance().parseBrokers(brokers: json)
            case "rtn_data":
                DataManager.getInstance().parseRtnTD(transactionData: json)
            default:
                self.tdWebSocketUtils.reconnectTD(url: CommonConstants.TRANSACTION_URL)
                return
            }

            if (!DataManager.getInstance().isBackground){
                socket.sendPeekMessage()
            }

        }
    }

    func websocketDidReceivePong(socket: TDWebSocketUtils, data: Data?) {
        self.lastTDTime = CACurrentMediaTime()
        NSLog("TDPong")
    }

    ////////////////////////////////////////////////////////////////////////////////

    func websocketDidReceiveMessage(socket: MDWebSocketUtils, text: String) {
        DispatchQueue.global().async {
            let json = JSON(parseJSON: text)
            let aid = json["aid"].stringValue
            switch aid {
            case "rsp_login":
                self.mdWebSocketUtils.ping()
                if DataManager.getInstance().sQuotes.count != 0{
                    socket.sendSubscribeQuote(insList: DataManager.getInstance().sQuotes[1].map {$0.key}[0..<CommonConstants.MAX_SUBSCRIBE_QUOTES].joined(separator: ","))
                }
            case "rtn_data":
                self.index = 0
                DataManager.getInstance().parseRtnMD(rtnData: json)
            default:
                self.index = self.mdWebSocketUtils.reconnectMD(url: self.mdURLs[self.index], index: self.index)
                return
            }

            if (!DataManager.getInstance().isBackground){
                socket.sendPeekMessage()
            }
            
        }
    }

    func websocketDidReceivePong(socket: MDWebSocketUtils, data: Data?) {
        self.lastMDTime = CACurrentMediaTime()
        NSLog("MDPong")
    }

    ////////////////////////////////////////////////////////////////////////////////

    func sessionSimpleDownload(urlString: String, fileName: String) {
        NSLog("合约列表开始下载")
        //下载地址
        let url = URL(string: urlString)
        //请求
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        let handler = { (location: URL?, _: URLResponse?, error: Error?) -> Void in
            NSLog("合约列表下载结束")
            if error != nil {
                print(error.debugDescription)
                return
            }
            do {
                let documentsURL = try
                    FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let savedURL = documentsURL.appendingPathComponent(fileName)
                if FileManager.default.fileExists(atPath: savedURL.path) {
                    try FileManager.default.removeItem(at: savedURL)
                }
                try FileManager.default.copyItem(at: location!, to: savedURL)
                DataManager.getInstance().parseLatestFile()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(CommonConstants.LatestFileParsedNotification), object: nil)
                }
                self.index = self.mdWebSocketUtils.connect(url: self.mdURLs[self.index], index: self.index)
                self.tdWebSocketUtils.connect(url: CommonConstants.TRANSACTION_URL)
            } catch {
                print ("file error: \(error)")
            }
        }
        //下载任务
        let downloadTask = session.downloadTask(with: request, completionHandler: handler)
        //使用resume方法启动任务
        downloadTask.resume()
    }

    ////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        let dict: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
        self.navigationController?.navigationBar.titleTextAttributes = dict as? [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        button.setTitle(CommonConstants.titleArray[1], for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        self.navigationItem.titleView = button
        definesPresentationContext = true
        
        initTMDURLs()
        getAppVersion()
        self.mdWebSocketUtils.mdWebSocketUtilsDelegate = self
        self.tdWebSocketUtils.tdWebSocketUtilsDelegate = self
        sessionSimpleDownload(urlString: CommonConstants.LATEST_FILE_URL, fileName: "latest.json")
        self.DispatchTimer(delay: 15, timeInterval: 15){ timer in

            if (CACurrentMediaTime() - self.lastTDTime) > 20 {
                DataManager.getInstance().sIsLogin = false
                self.tdWebSocketUtils.reconnectTD(url: CommonConstants.TRANSACTION_URL)
                NSLog("TD断线重连")
            } else {
                self.tdWebSocketUtils.ping()
            }

            if (CACurrentMediaTime() - self.lastMDTime) > 20 {
                self.index = self.mdWebSocketUtils.reconnectMD(url: self.mdURLs[self.index], index: self.index)
                NSLog("MD断线重连")
            } else {
                self.mdWebSocketUtils.ping()
            }

        }
        initSlideMenuWidth()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMenu), name: Notification.Name(CommonConstants.BrokerInfoEmptyNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popupOptionalList), name: Notification.Name(CommonConstants.PopupOptionalInsListNotification), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("HomePage")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("HomePage")
    }

    deinit {
        print("主页销毁")
        NotificationCenter.default.removeObserver(self)
    }

    //iPhone下默认是.overFullScreen(全屏显示)，需要返回.none，否则没有弹出框效果，iPad则不需要
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    // change the width of slide menu when the orientation changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        initSlideMenuWidth()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case CommonConstants.MainToFeedback:
            controlSlideMenuVisibility()
        case CommonConstants.MainToAbout:
            controlSlideMenuVisibility()
        case CommonConstants.QuotePageViewController:
            quotePageViewController = segue.destination as! QuotePageViewController
        case CommonConstants.QuoteNavigationCollectionViewController:
            quoteNavigationCollectionViewController = segue.destination as! QuoteNavigationCollectionViewController
        default:
            return
        }
    }

    // MARK: Actions
    @IBAction func accountViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从账户资金来～")
    }

    @IBAction func toAccount(_ sender: UIButton) {
        controlSlideMenuVisibility()
        if !DataManager.getInstance().sIsLogin {
            DataManager.getInstance().sToLoginTarget = "Account"
            performSegue(withIdentifier: CommonConstants.MainToLogin, sender: sender)
        } else {
            performSegue(withIdentifier: CommonConstants.MainToAccount, sender: sender)
        }
    }

    @IBAction func quoteViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从合约详情页来～")
        if let segue = segue.identifier {
            switch segue {
            case CommonConstants.QuoteViewControllerUnwindSegue:
                MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: DataManager.getInstance().sPreInsList)
                MDWebSocketUtils.getInstance().sendSetChart(insList: "")
                MDWebSocketUtils.getInstance().sendSetChartDay(insList: "", viewWidth: CommonConstants.VIEW_WIDTH)
                MDWebSocketUtils.getInstance().sendSetChartHour(insList: "", viewWidth: CommonConstants.VIEW_WIDTH)
                MDWebSocketUtils.getInstance().sendSetChartMinute(insList: "", viewWidth: CommonConstants.VIEW_WIDTH)
            default:
                break
            }
        }
    }

    @IBAction func toPosition(_ sender: UIButton) {
        controlSlideMenuVisibility()
        if !DataManager.getInstance().sIsLogin {
            DataManager.getInstance().sToLoginTarget = "Position"
            performSegue(withIdentifier: CommonConstants.MainToLogin, sender: sender)
        } else {
            performSegue(withIdentifier: CommonConstants.MainToQuote, sender: sender)
            let instrumentId = DataManager.getInstance().sQuotes[1].map {$0.key}[0]
            //进入合约详情页的入口有：合约列表页，登陆页，搜索页，主页
            DataManager.getInstance().sPreInsList = DataManager.getInstance().sRtnMD[RtnMDConstants.ins_list].stringValue
            DataManager.getInstance().sInstrumentId = instrumentId
            MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: instrumentId)
            MDWebSocketUtils.getInstance().sendSetChart(insList: instrumentId)
            MDWebSocketUtils.getInstance().sendSetChartDay(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
            MDWebSocketUtils.getInstance().sendSetChartHour(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
            MDWebSocketUtils.getInstance().sendSetChartMinute(insList: instrumentId, viewWidth: CommonConstants.VIEW_WIDTH)
        }
    }

    @IBAction func tradeTableViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从成交记录来～")
    }

    @IBAction func toTrade(_ sender: UIButton) {
        controlSlideMenuVisibility()
        if !DataManager.getInstance().sIsLogin {
            DataManager.getInstance().sToLoginTarget = "Trade"
            performSegue(withIdentifier: CommonConstants.MainToLogin, sender: sender)
        } else {
            performSegue(withIdentifier: CommonConstants.MainToTrade, sender: sender)
        }
    }

    @IBAction func bankTransferViewControllerUnwindSegue(segue: UIStoryboardSegue){
        print("我从银期转帐来～")
    }

    @IBAction func toBankTransfer(_ sender: UIButton){
        controlSlideMenuVisibility()
        if !DataManager.getInstance().sIsLogin {
            DataManager.getInstance().sToLoginTarget = "BankTransfer"
            performSegue(withIdentifier: CommonConstants.MainToLogin, sender: sender)
        } else {
            performSegue(withIdentifier: CommonConstants.MainToBankTransfer, sender: sender)
        }
    }

    @IBAction func navigation(_ sender: UIBarButtonItem) {
        controlSlideMenuVisibility()
    }

    @IBAction func toOptional(_ sender: UIButton) {
        controlSlideMenuVisibility()
        button.setTitle(CommonConstants.titleArray[0], for: .normal)
        switchPage(index: 0)
    }

    @IBAction func toDomain(_ sender: UIButton) {
        controlSlideMenuVisibility()
        button.setTitle(CommonConstants.titleArray[1], for: .normal)
        switchPage(index: 1)
    }

    @IBAction func toShanghai(_ sender: UIButton) {
        controlSlideMenuVisibility()
        button.setTitle(CommonConstants.titleArray[2], for: .normal)
        switchPage(index: 2)
    }

    @IBAction func toNengyuan(_ sender: UIButton) {
        controlSlideMenuVisibility()
        button.setTitle(CommonConstants.titleArray[3], for: .normal)
        switchPage(index: 3)
    }

    @IBAction func toDalian(_ sender: UIButton) {
        controlSlideMenuVisibility()
        button.setTitle(CommonConstants.titleArray[4], for: .normal)
        switchPage(index: 4)
    }

    @IBAction func toZhengzhou(_ sender: UIButton) {
        controlSlideMenuVisibility()
        button.setTitle(CommonConstants.titleArray[5], for: .normal)
        switchPage(index: 5)
    }

    @IBAction func toZhongjin(_ sender: UIButton) {
        controlSlideMenuVisibility()
        button.setTitle(CommonConstants.titleArray[6], for: .normal)
        switchPage(index: 6)
    }

    @IBAction func toDaLianZuHe(_ sender: UIButton) {
        controlSlideMenuVisibility()
        button.setTitle(CommonConstants.titleArray[7], for: .normal)
        switchPage(index: 7)
    }

    @IBAction func toZhengZhouZuHe(_ sender: UIButton) {
        controlSlideMenuVisibility()
        button.setTitle(CommonConstants.titleArray[8], for: .normal)
        switchPage(index: 8)
    }

    @IBAction func left(_ sender: UIButton) {
        if let collectionView = quoteNavigationCollectionViewController.collectionView {
            var indexPaths = collectionView.indexPathsForVisibleItems
            indexPaths.sort(by: <)
            if let index = indexPaths.first?.row {
                collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .right, animated: false)
            }
        }
    }

    @IBAction func right(_ sender: UIButton) {
        if let collectionView = quoteNavigationCollectionViewController.collectionView {
            var indexPaths = collectionView.indexPathsForVisibleItems
            indexPaths.sort(by: <)
            if let index = indexPaths.last?.row {
                collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: false)
            }
        }
    }

    @IBAction func background(_ sender: UIButton) {
        controlSlideMenuVisibility()
    }

    // MARK: private func
    //初始化侧滑栏约束，控制其隐藏显示
    private func initSlideMenuWidth() {
        switch UIDevice.current.orientation {
        case .portrait:
            slideMenuConstraint.constant = -180
        case .portraitUpsideDown:
            slideMenuConstraint.constant = -180
        case .landscapeLeft:
            slideMenuConstraint.constant = -120
        case .landscapeRight:
            slideMenuConstraint.constant = -120
        default:
            print("什么鬼～")
        }

    }

    //控制侧滑栏隐藏显示
    private func controlSlideMenuVisibility() {
        if isSlideMenuHidden {
            slideMenuConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()})
            UIView.animate(withDuration: 0.3, animations: {
                self.background.alpha = 0.5
            })
        } else {
            slideMenuConstraint.constant = -menu.frame.size.width
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            UIView.animate(withDuration: 0.3, animations: {
                self.background.alpha = 0.0
            })
        }
        isSlideMenuHidden = !isSlideMenuHidden
    }

    //切换交易所行情列表
    private func switchPage(index: Int) {
        if quotePageViewController.currentIndex < index {
            quotePageViewController.forwardPage(index: index)
        } else if quotePageViewController.currentIndex > index {
            quotePageViewController.backwardPage(index: index)
        }

        loadQuoteNavigation(index: index)
    }

    //加载导航栏
    func loadQuoteNavigation(index: Int) {
        if index == 0 {
            quoteNavgationView.isHidden = true
            left.isHidden = true
            right.isHidden = true
            quoteNavigationConstraint.constant = 0
        } else {
            quoteNavgationView.isHidden = false
            left.isHidden = false
            right.isHidden = false
            quoteNavigationConstraint.constant = -44
        }
        quoteNavigationCollectionViewController.loadDatas(index: index)
    }

    //初始化默认配置
    func initDefaultConfig() {
        if UserDefaults.standard.object(forKey: "positionLine") == nil {
            UserDefaults.standard.set(true, forKey: "positionLine")
        }

        if UserDefaults.standard.object(forKey: "orderLine") == nil {
            UserDefaults.standard.set(true, forKey: "orderLine")
        }

        if UserDefaults.standard.object(forKey: "averageLine") == nil {
            UserDefaults.standard.set(true, forKey: "averageLine")
        }

        if UserDefaults.standard.object(forKey: "isLocked") == nil {
            UserDefaults.standard.set(false, forKey: "isLocked")
        }

    }

    //初始化服务器地址
    func initTMDURLs(){
        let mdURLGroup = shuffle(group: [CommonConstants.MARKET_URL_2, CommonConstants.MARKET_URL_3, CommonConstants.MARKET_URL_4, CommonConstants.MARKET_URL_5, CommonConstants.MARKET_URL_6, CommonConstants.MARKET_URL_7])

        if let myClass = objc_getClass("shinnyfutures.LocalCommonConstants"){
            let myClassType = myClass as! NSObject.Type
            let cl = myClassType.init()
            let url = cl.value(forKey: "MARKET_URL_8") as! String
            let transaction_url = cl.value(forKey: "TRANSACTION_URL") as! String
            let json_url = cl.value(forKey: "LATEST_FILE_URL") as! String
            CommonConstants.LATEST_FILE_URL = json_url
            CommonConstants.TRANSACTION_URL = transaction_url
            mdURLs.append(url)
            let bugly_key = cl.value(forKey: "BUGLY_KEY") as! String
            let umeng_key = cl.value(forKey: "UMENG_KEY") as! String
            let baidu_key = cl.value(forKey: "BAIDU_KEY") as! String
            #if DEBUG // 判断是否在测试环境下
            // TODO
            #else
            Bugly.start(withAppId: bugly_key)
            UMConfigure.initWithAppkey(umeng_key, channel: "AppStore")
            let baidu = BaiduMobStat()
            baidu.start(withAppId: baidu_key)
            #endif
        }else{
            mdURLs.append(CommonConstants.MARKET_URL_1)
        }
        mdURLs += mdURLGroup
    }

    func shuffle(group: [String]) -> [String] {
        var items = group
        var last = items.count - 1
        while(last > 0)
        {
            let rand = Int(arc4random_uniform(UInt32(last)))
            items.swapAt(last, rand)
            last -= 1
        }
        return items
    }

    //获取软件版本
    func getAppVersion() {
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String, let appBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as? String{
            DataManager.getInstance().sAppVersion = appVersion
            DataManager.getInstance().sAppBuild = appBuild
            let versionCode = UserDefaults.standard.integer(forKey: "versionCode")
            if let versionCodeNow = Int(appBuild){
                if versionCode < versionCodeNow {
                    //免责条款
                    ResponsibilityView.getInstance().showResponsibility()
                    UserDefaults.standard.set(versionCodeNow, forKey: "versionCode")
                }
            }
        }
    }

    /// GCD定时器循环操作
    func DispatchTimer(delay: Double, timeInterval: Double, handler:@escaping (DispatchSourceTimer?)->())
    {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer.schedule(deadline: .now() + delay, repeating: timeInterval)
        timer.setEventHandler {
            DispatchQueue.main.async {
                handler(timer)
            }
        }
        timer.resume()
    }

    @objc func refreshMenu(){
        menu.removeArrangedSubview(account)
        menu.removeArrangedSubview(position)
        menu.removeArrangedSubview(trade)
        menu.removeArrangedSubview(transfer)
    }

    @objc func popupOptionalList(){
        if let optionalPopupView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: CommonConstants.OptionalPopupTableViewController) as? OptionalPopupTableViewController {

            optionalPopupView.modalPresentationStyle = .popover
            //箭头所指向的区域
            optionalPopupView.popoverPresentationController?.sourceView = self.navigationItem.titleView
            optionalPopupView.popoverPresentationController?.sourceRect = (self.navigationItem.titleView?.bounds)!
            //箭头方向
            optionalPopupView.popoverPresentationController?.permittedArrowDirections = .up
            //设置代理
            optionalPopupView.popoverPresentationController?.delegate = self
            //弹出框口大小
            //optionalPopupView.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 44.0)
            self.present(optionalPopupView, animated: true, completion: nil)
        }
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: FileUtils.getOptional().joined(separator: ","))
    }

}
