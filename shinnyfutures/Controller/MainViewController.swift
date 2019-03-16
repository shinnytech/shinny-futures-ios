//
//  MainViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/28.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, MDWebSocketUtilsDelegate, TDWebSocketUtilsDelegate, UIPopoverPresentationControllerDelegate, SlideMenuControllerDelegate {
    // MARK: Properties
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
    let button =  UIButton(type: .custom)
    let dataManager = DataManager.getInstance()

    func websocketDidReceiveMessage(socket: TDWebSocketUtils, text: String) {
        DispatchQueue.global().async {
            guard let data = text.data(using: .utf8) else {return}
            do{
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {return}
                let aid = json[RtnTDConstants.aid] as? String
                switch aid {
                case "rtn_brokers":
                    self.tdWebSocketUtils.ping()
                    self.dataManager.parseBrokers(rtnData: json)
                case "rtn_data":
                    self.dataManager.parseRtnTD(rtnData: json)
                default:
                    self.tdWebSocketUtils.reconnectTD(url: CommonConstants.TRANSACTION_URL)
                    return
                }

                socket.sendPeekMessage()

            }catch{
                print(error.localizedDescription)
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
            guard let data = text.data(using: .utf8) else {return}
            do{
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {return}
                let aid = json[RtnMDConstants.aid] as? String
                switch aid {
                case "rsp_login":
                    self.mdWebSocketUtils.ping()

                    let ins_list = self.dataManager.sRtnMD.ins_list
                    if !ins_list.isEmpty{
                        socket.sendSubscribeQuote(insList: ins_list)
                    }else if self.dataManager.sQuotes.count != 0{
                        if self.dataManager.sQuotes[0].isEmpty{
                            socket.sendSubscribeQuote(insList: self.dataManager.sQuotes[1].map {$0.key}[0..<CommonConstants.MAX_SUBSCRIBE_QUOTES].joined(separator: ","))
                        }else if self.dataManager.sQuotes[0].count < CommonConstants.MAX_SUBSCRIBE_QUOTES{
                            let insList = self.dataManager.getCombineInsList(data: self.dataManager.sQuotes[0].map {$0.key})
                            socket.sendSubscribeQuote(insList: insList.joined(separator: ","))
                        }else {
                            let insList = self.dataManager.getCombineInsList(data: Array(self.dataManager.sQuotes[0].map {$0.key}[0..<CommonConstants.MAX_SUBSCRIBE_QUOTES]))
                            socket.sendSubscribeQuote(insList: insList.joined(separator: ","))
                        }
                    }

                    let charts = self.dataManager.sRtnMD.charts
                    if charts.count != 0{
                        for key in charts.keys{
                            guard let chart = charts[key] else {continue}
                            let duration = "\(chart.state?.duration ?? "")"
                            let ins = "\(chart.state?.ins_list ?? "")"
                            if CommonConstants.CURRENT_DAY_FRAGMENT.elementsEqual(key){
                                socket.sendSetChart(insList: ins)
                            }else{
                                socket.sendSetChartKline(insList: ins, klineType: duration, viewWidth: CommonConstants.VIEW_WIDTH)
                            }
                        }
                    }

                case "rtn_data":
                    self.dataManager.index = 0
                    self.dataManager.parseRtnMD(rtnData: json)
                default:
                    self.dataManager.index = self.mdWebSocketUtils.reconnectMD(url: self.dataManager.mdURLs[self.dataManager.index], index: self.dataManager.index)
                    return
                }

                socket.sendPeekMessage()

            }catch{
                print(error.localizedDescription)
            }

        }
    }

    func websocketDidReceivePong(socket: MDWebSocketUtils, data: Data?) {
        self.lastMDTime = CACurrentMediaTime()
        NSLog("MDPong")
    }

    ////////////////////////////////////////////////////////////////////////////////

    func sessionSimpleDownload(urlString: String) {
        guard let url = URL(string: urlString) else {return}
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else { return }
            self.dataManager.parseLatestFile(latestData: data)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.LatestFileParsedNotification), object: nil)
            }
            self.dataManager.index = self.mdWebSocketUtils.connect(url: self.dataManager.mdURLs[self.dataManager.index], index: self.dataManager.index)
            self.tdWebSocketUtils.connect(url: CommonConstants.TRANSACTION_URL)
        }
        task.resume()
    }

    ////////////////////////////////////////////////////////////////////////////////

    //设置statubar的字体颜色为白
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let dict: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
        self.navigationController?.navigationBar.titleTextAttributes = dict as? [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.barTintColor = CommonConstants.QUOTE_PAGE_HEADER
        self.navigationController?.navigationBar.backgroundColor = CommonConstants.QUOTE_PAGE_HEADER
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.setNeedsStatusBarAppearanceUpdate()
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        if FileUtils.getOptional().isEmpty  {
            button.setTitle(CommonConstants.titleArray[1], for: .normal)
        }else{
            button.setTitle(CommonConstants.titleArray[0], for: .normal)
        }
        button.setTitleColor(UIColor.white, for: .normal)
        self.navigationItem.titleView = button
        definesPresentationContext = true

        initDefaultConfig()
        initTMDURLs()
        getAppVersion()
        self.mdWebSocketUtils.mdWebSocketUtilsDelegate = self
        self.tdWebSocketUtils.tdWebSocketUtilsDelegate = self
        sessionSimpleDownload(urlString: CommonConstants.LATEST_FILE_URL)
        self.DispatchTimer(delay: 15, timeInterval: 15){ timer in

            if (CACurrentMediaTime() - self.lastTDTime) > 20 {
                self.dataManager.sIsLogin = false
                self.tdWebSocketUtils.reconnectTD(url: CommonConstants.TRANSACTION_URL)
                NSLog("TD断线重连")
            } else {
                self.tdWebSocketUtils.ping()
            }

            if (CACurrentMediaTime() - self.lastMDTime) > 20 {
                self.dataManager.index = self.mdWebSocketUtils.reconnectMD(url: self.dataManager.mdURLs[self.dataManager.index], index: self.dataManager.index)
                NSLog("MD断线重连")
            } else {
                self.mdWebSocketUtils.ping()
            }

        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMenu), name: Notification.Name(CommonConstants.BrokerInfoEmptyNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popupOptionalList), name: Notification.Name(CommonConstants.PopupOptionalInsListNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(CommonConstants.LatestFileParsedNotification), object: nil)
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
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case CommonConstants.MainToSearch:
            if let searchViewController = segue.destination as? SearchTableViewController{
                searchViewController.segueIdentify = CommonConstants.MainToSearch
            }
        case CommonConstants.QuotePageViewController:
            quotePageViewController = segue.destination as? QuotePageViewController
        case CommonConstants.QuoteNavigationCollectionViewController:
            quoteNavigationCollectionViewController = segue.destination as? QuoteNavigationCollectionViewController
        default:
            return
        }
    }

    //初始化默认配置
    func initDefaultConfig() {

        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_SETTING_KLINE_DURATION_DEFAULT) == nil {
            UserDefaults.standard.set(CommonConstants.klineDurationDefault, forKey: CommonConstants.CONFIG_SETTING_KLINE_DURATION_DEFAULT)
        }

        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_SETTING_PARA_MA) == nil {
        UserDefaults.standard.set(CommonConstants.PARA_MA, forKey: CommonConstants.CONFIG_SETTING_PARA_MA)
        }

        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_SETTING_TRANSACTION_SHOW_ORDER) == nil {
            UserDefaults.standard.set(true, forKey: CommonConstants.CONFIG_SETTING_TRANSACTION_SHOW_ORDER)
        }

        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_POSITION_LINE) == nil {
            UserDefaults.standard.set(true, forKey: CommonConstants.CONFIG_POSITION_LINE)
        }

        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_ORDER_LINE) == nil {
            UserDefaults.standard.set(true, forKey: CommonConstants.CONFIG_ORDER_LINE)
        }

        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_AVERAGE_LINE) == nil {
            UserDefaults.standard.set(true, forKey: CommonConstants.CONFIG_AVERAGE_LINE)
        }

        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_MD5) == nil {
            UserDefaults.standard.set(true, forKey: CommonConstants.CONFIG_MD5)
        }


        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_KLINE_DAY_TYPE) == nil {
            UserDefaults.standard.set(CommonConstants.KLINE_1_DAY, forKey: CommonConstants.CONFIG_KLINE_DAY_TYPE)
        }

        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_KLINE_HOUR_TYPE) == nil {
            UserDefaults.standard.set(CommonConstants.KLINE_1_HOUR, forKey: CommonConstants.CONFIG_KLINE_HOUR_TYPE)
        }

        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_KLINE_MINUTE_TYPE) == nil {
            UserDefaults.standard.set(CommonConstants.KLINE_5_MINUTE, forKey: CommonConstants.CONFIG_KLINE_MINUTE_TYPE)
        }

        if UserDefaults.standard.object(forKey: CommonConstants.CONFIG_KLINE_SECOND_TYPE) == nil {
            UserDefaults.standard.set(CommonConstants.KLINE_3_SECOND, forKey: CommonConstants.CONFIG_KLINE_SECOND_TYPE)
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
            self.dataManager.mdURLs.append(url)
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
            self.dataManager.mdURLs.append(CommonConstants.MARKET_URL_1)
        }
        self.dataManager.mdURLs += mdURLGroup
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
            self.dataManager.sAppVersion = appVersion
            self.dataManager.sAppBuild = appBuild
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

    // MARK: Actions
    @IBAction func settingViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从设置页来～")
    }

    func toSetting() {
        performSegue(withIdentifier: CommonConstants.MainToSetting, sender: nil)
    }

    @IBAction func feedbackViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从反馈页来～")
    }

    func toFeedback() {
        performSegue(withIdentifier: CommonConstants.MainToFeedback, sender: nil)
    }

    @IBAction func aboutViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从关于页来～")
    }

    func toAbout() {
        performSegue(withIdentifier: CommonConstants.MainToAbout, sender: nil)
    }

    func toLogin() {
        self.dataManager.sToLoginTarget = "Login"
        performSegue(withIdentifier: CommonConstants.MainToLogin, sender: nil)
    }

    @IBAction func accountViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从账户资金页来～")
    }

    func toAccount() {
        if !self.dataManager.sIsLogin {
            self.dataManager.sToLoginTarget = "Account"
            performSegue(withIdentifier: CommonConstants.MainToLogin, sender: nil)
        } else {
            performSegue(withIdentifier: CommonConstants.MainToAccount, sender: nil)
        }
    }

    @IBAction func changePasswordViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从修改密码页来～")
    }

    func toChangePassword() {
        performSegue(withIdentifier: CommonConstants.MainToChangePassword, sender: nil)
    }

    @IBAction func quoteViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从合约详情页来～")
        if let segue = segue.identifier {
            switch segue {
            case CommonConstants.QuoteViewControllerUnwindSegue:
                MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: self.dataManager.sPreInsList)
            default:
                break
            }
        }
    }

    func toPosition() {
        self.dataManager.sToQuoteTarget = "Position"
        if !self.dataManager.sIsLogin {
            self.dataManager.sToLoginTarget = "Position"
            performSegue(withIdentifier: CommonConstants.MainToLogin, sender: nil)
        } else {
            performSegue(withIdentifier: CommonConstants.MainToQuote, sender: nil)
            let instrumentId = self.dataManager.sQuotes[1].map {$0.key}[0]
            //进入合约详情页的入口有：合约列表页，登陆页，搜索页，主页
            self.dataManager.sPreInsList = self.dataManager.sRtnMD.ins_list
            self.dataManager.sInstrumentId = instrumentId
        }
    }

    @IBAction func tradeTableViewControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从成交记录来～")
    }

    func toTrade() {
        if !self.dataManager.sIsLogin {
            self.dataManager.sToLoginTarget = "Trade"
            performSegue(withIdentifier: CommonConstants.MainToLogin, sender: nil)
        } else {
            performSegue(withIdentifier: CommonConstants.MainToTrade, sender: nil)
        }
    }

    @IBAction func bankTransferViewControllerUnwindSegue(segue: UIStoryboardSegue){
        print("我从银期转帐来～")
    }

    func toBankTransfer(){
        if !self.dataManager.sIsLogin {
            self.dataManager.sToLoginTarget = "BankTransfer"
            performSegue(withIdentifier: CommonConstants.MainToLogin, sender: nil)
        } else {
            performSegue(withIdentifier: CommonConstants.MainToBankTransfer, sender: nil)
        }
    }

    func toOpenAccount() {
        let appString = "https://itunes.apple.com/cn/app/%E6%9C%9F%E8%B4%A7%E5%BC%80%E6%88%B7%E4%BA%91/id1058174819?mt=8"
        let appUrl = URL(string: appString)
        UIApplication.shared.open(appUrl!)
    }

    @IBAction func navigation(_ sender: UIBarButtonItem) {
        if let slide = self.slideMenuController() {
            slide.openLeft()
        }
    }

    @IBAction func right_navigation(_ sender: UIBarButtonItem) {
        if let slide = self.slideMenuController() {
            if let right = slide.rightViewController as? RightTableViewController{
                if self.dataManager.sIsEmpty{
                    right.datas = CommonConstants.rightArray
                }else if self.dataManager.sIsLogin {
                    right.datas = CommonConstants.rightTitleArrayLogged
                }else{
                    right.datas = CommonConstants.rightTitleArray
                }
                right.tableView.reloadData()
                slide.openRight()
            }
        }
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

    @objc func refreshMenu(){
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

    //latestFile文件解析完毕后刷新导航列表
    @objc func refresh() {
        if dataManager.sQuotes[0].isEmpty {
            loadQuoteNavigation(index: 1)
        }else{
            loadQuoteNavigation(index: 0)
        }
    }

    //切换交易所行情列表
    func switchPage(index: Int) {
        button.setTitle(CommonConstants.titleArray[index], for: .normal)
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

}
