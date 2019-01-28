//
//  QuoteViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/26.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class QuoteViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    // MARK: Properties
    let button =  UIButton(type: .custom)
    let dataManager = DataManager.getInstance()
    var transactionPageViewController: TransactionPageViewController!
    var klinePageViewController: KlinePageViewController!
    @IBOutlet weak var setup: UIButton!
    @IBOutlet weak var duration: UIButton!
    @IBOutlet weak var save: UIBarButtonItem!
    @IBOutlet weak var upView: UIStackView!
    @IBOutlet weak var currentDay: UIButton!
    @IBOutlet weak var klineDay: UIButton!
    @IBOutlet weak var klineHour: UIButton!
    @IBOutlet weak var klineMinute: UIButton!
    @IBOutlet weak var klineSecond: UIButton!
    @IBOutlet weak var handicap: UIButton!
    @IBOutlet weak var position: UIButton!
    @IBOutlet weak var order: UIButton!
    @IBOutlet weak var transaction: UIButton!
    @IBOutlet weak var downStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let title = dataManager.getButtonTitle()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(named: "down", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil), for: .normal)
        button.layoutIfNeeded()
        button.imageEdgeInsets = UIEdgeInsetsMake(0, (button.titleLabel?.frame.size.width)!, 0, -(button.titleLabel?.frame.size.width)!)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -(button.titleLabel?.frame.origin.x)!, 0, (button.titleLabel?.frame.origin.x)!)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(self.optionalInsListPopup), for: .touchUpInside)
        self.navigationItem.titleView = button
        //设置按钮背景
        let optional = FileUtils.getOptional()
        if optional.contains(dataManager.sInstrumentId){
            save.image = UIImage(named: "heart", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil)
        }

        if let klineType = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_KLINE_DAY_TYPE){
            klineDay.setTitle(getDurationTitle(duration: klineType), for: .normal)
        }
        if let klineType = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_KLINE_HOUR_TYPE){
            klineHour.setTitle(getDurationTitle(duration: klineType), for: .normal)
        }
        if let klineType = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_KLINE_MINUTE_TYPE){
            klineMinute.setTitle(getDurationTitle(duration: klineType), for: .normal)
        }
        if let klineType = UserDefaults.standard.string(forKey: CommonConstants.CONFIG_KLINE_SECOND_TYPE){
            klineSecond.setTitle(getDurationTitle(duration: klineType), for: .normal)
        }

        initUpNavBottomLine(view: currentDay)
        initUpNavBottomLine(view: klineDay)
        initUpNavBottomLine(view: klineHour)
        initUpNavBottomLine(view: klineMinute)
        initUpNavBottomLine(view: klineSecond)
        currentDay.setTitleColor(UIColor.yellow, for: .normal)
        highlightUpNavBottomLine(view: currentDay)

        handicap.setTitleColor(UIColor.yellow, for: .normal)

        if dataManager.sIsEmpty {
            position.isHidden = true
            order.isHidden = true
            transaction.isHidden = true
        }else {
            highlightBottomNavBorderLine(view: handicap)
            unhighlightBottomNavBorderLine(view: position)
            unhighlightBottomNavBorderLine(view: order)
            unhighlightBottomNavBorderLine(view: transaction)

            //从主页导航栏而来
            if dataManager.sToQuoteTarget.elementsEqual("Position") {
                switchToPosition()
            }
        }


        NotificationCenter.default.addObserver(self, selector: #selector(showUpView), name: Notification.Name(CommonConstants.ShowUpViewNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideUpView), name: Notification.Name(CommonConstants.HideUpViewNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToPosition), name: Notification.Name(CommonConstants.SwitchToPositionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToOrder), name: Notification.Name(CommonConstants.SwitchToOrderNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToTransaction), name: Notification.Name(CommonConstants.SwitchToTransactionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendSuscribeQuote), name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchKlineTitle(_:)), name: Notification.Name(CommonConstants.SwitchKlineNotification), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        //从合约列表页过来订阅合约行情
        sendSuscribeQuote()
    }

    deinit {
        print("合约详情页销毁")
        NotificationCenter.default.removeObserver(self)
    }

    //iPhone下默认是.overFullScreen(全屏显示)，需要返回.none，否则没有弹出框效果，iPad则不需要
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case CommonConstants.TransactionPageViewController:
            if let pageViewController = segue.destination as? TransactionPageViewController {
                transactionPageViewController = pageViewController
            }
        case CommonConstants.KlinePageViewController:
            if let pageViewController = segue.destination as? KlinePageViewController {
                klinePageViewController = pageViewController
            }
        case CommonConstants.KlinePopupView:
            if let popupView = segue.destination as? KlinePopupViewController {
                popupView.modalPresentationStyle = .popover
                //箭头所指向的区域
                popupView.popoverPresentationController?.sourceView = setup
                popupView.popoverPresentationController?.sourceRect = setup.bounds
                //箭头方向
                popupView.popoverPresentationController?.permittedArrowDirections = .up
                //设置代理
                popupView.popoverPresentationController?.delegate = self
                //弹出框口大小
                popupView.preferredContentSize = CGSize(width: 110, height: 125)
            }
        default:
            return
        }
    }

    // MARK: actions
    @IBAction func saveToOptional(_ sender: UIBarButtonItem) {
        if dataManager.sInstrumentId.count != 0 {
            dataManager.saveOrRemoveIns(ins: dataManager.sInstrumentId)
        }
        //设置按钮背景
        let optional = FileUtils.getOptional()
        if optional.contains(dataManager.sInstrumentId){
            save.image = UIImage(named: "heart", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil)
        }else{
            save.image = UIImage(named: "heart_outline", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil)
        }
    }

    @IBAction func klineDuration(_ sender: UIButton) {
        if let klineDurationPopupView = UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: CommonConstants.PopupCollectionViewController) as? PopupCollectionViewController {
            klineDurationPopupView.modalPresentationStyle = .popover
            //箭头所指向的区域
            klineDurationPopupView.popoverPresentationController?.sourceView = sender
            klineDurationPopupView.popoverPresentationController?.sourceRect = sender.bounds
            //箭头方向
            klineDurationPopupView.popoverPresentationController?.permittedArrowDirections = .up
            //设置代理
            klineDurationPopupView.popoverPresentationController?.delegate = self
            klineDurationPopupView.insList = CommonConstants.klineTypeTitle
            let columnNum = ceilf(Float(klineDurationPopupView.insList.count) / 8.0)
            let collectionHeight = CGFloat(columnNum * 50 + 20 + (columnNum - 1) * 10)
            //弹出框口大小
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            klineDurationPopupView.preferredContentSize = CGSize(width: screenWidth, height: collectionHeight)
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width: screenWidth / 8, height: 50)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            klineDurationPopupView.collectionView!.collectionViewLayout = layout
            klineDurationPopupView.flag = "duration"
            self.present(klineDurationPopupView, animated: true, completion: nil)
        }
    }
    

    @IBAction func currentDay(_ sender: UIButton) {
        switchKlinePage(index: 0)
    }

    @IBAction func klineDay(_ sender: UIButton) {
        switchKlinePage(index: 1)
    }

    @IBAction func klineHour(_ sender: UIButton) {
        switchKlinePage(index: 2)
    }

    @IBAction func klineMinute(_ sender: UIButton) {
        switchKlinePage(index: 3)
    }

    @IBAction func klineSecond(_ sender: UIButton) {
        switchKlinePage(index: 4)
    }

    @IBAction func handicap(_ sender: UIButton) {
        switchTransactionPage(index: 0)
    }

    @IBAction func position(_ sender: UIButton) {
        if !DataManager.getInstance().sIsLogin {
            DataManager.getInstance().sToLoginTarget = "SwitchToPosition"
            performSegue(withIdentifier: CommonConstants.QuoteToLogin, sender: sender)
        } else {
            switchTransactionPage(index: 1)
        }
    }

    @IBAction func order(_ sender: UIButton) {
        if !DataManager.getInstance().sIsLogin {
            DataManager.getInstance().sToLoginTarget = "SwitchToOrder"
            performSegue(withIdentifier: CommonConstants.QuoteToLogin, sender: sender)
        } else {
            switchTransactionPage(index: 2)
        }
    }

    @IBAction func transaction(_ sender: UIButton) {
        if !DataManager.getInstance().sIsLogin {
            DataManager.getInstance().sToLoginTarget = "SwitchToTransaction"
            performSegue(withIdentifier: CommonConstants.QuoteToLogin, sender: sender)
        } else {
            switchTransactionPage(index: 3)
        }
    }

    // MARK: functions
    private func switchKlinePage(index: Int) {
        if klinePageViewController.currentIndex < index {
            klinePageViewController.setViewControllers([klinePageViewController.subViewControllers[index]], direction: .forward, animated: false, completion: nil)
        } else if klinePageViewController.currentIndex > index {
            klinePageViewController.setViewControllers([klinePageViewController.subViewControllers[index]], direction: .reverse, animated: false, completion: nil)
        }
        if klinePageViewController.currentIndex != index {
            controlKlineVisibility(index: index)
            klinePageViewController.currentIndex = index
        }
    }

    private func switchTransactionPage(index: Int) {
        if transactionPageViewController.currentIndex < index {
            transactionPageViewController.setViewControllers([transactionPageViewController.subViewControllers[index]], direction: .forward, animated: false, completion: nil)
        } else if transactionPageViewController.currentIndex > index {
            transactionPageViewController.setViewControllers([transactionPageViewController.subViewControllers[index]], direction: .reverse, animated: false, completion: nil)
        }
        if transactionPageViewController.currentIndex != index {
            controlTransactionVisibility(index: index)
            transactionPageViewController.currentIndex = index
        }
    }

    //初始化顶部导航按钮添加横线
    func initUpNavBottomLine(view: UIButton) {
        let lineView = UIView(frame: CGRect(x: 0, y: view.frame.size.height - 2, width: view.frame.size.width, height: 2))
        lineView.backgroundColor = CommonConstants.NAV_TEXT_UNHIGHLIGHTED
        lineView.tag = 100
        view.addSubview(lineView)
    }

    func highlightUpNavBottomLine(view: UIButton) {
        if let viewWithTag = view.viewWithTag(100) {
            viewWithTag.backgroundColor = CommonConstants.NAV_TEXT_HIGHLIGHTED
        }
    }

    func unhighlightUpNavBottomLine(view: UIButton) {
        if let viewWithTag = view.viewWithTag(100) {
            viewWithTag.backgroundColor = CommonConstants.NAV_TEXT_UNHIGHLIGHTED
        }
    }


    func controlKlineVisibility(index: Int) {
        switch index {
        case 0:
            currentDay.setTitleColor(CommonConstants.NAV_TEXT_HIGHLIGHTED, for: .normal)
            highlightUpNavBottomLine(view: currentDay)
            klineDay.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineDay)
            klineHour.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineHour)
            klineMinute.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineMinute)
            klineSecond.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineSecond)
        case 1:
            currentDay.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: currentDay)
            klineDay.setTitleColor(CommonConstants.NAV_TEXT_HIGHLIGHTED, for: .normal)
            highlightUpNavBottomLine(view: klineDay)
            klineHour.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineHour)
            klineMinute.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineMinute)
            klineSecond.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineSecond)
        case 2:
            currentDay.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: currentDay)
            klineDay.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineDay)
            klineHour.setTitleColor(CommonConstants.NAV_TEXT_HIGHLIGHTED, for: .normal)
            highlightUpNavBottomLine(view: klineHour)
            klineMinute.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineMinute)
            klineSecond.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineSecond)
        case 3:
            currentDay.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: currentDay)
            klineDay.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineDay)
            klineHour.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineHour)
            klineMinute.setTitleColor(CommonConstants.NAV_TEXT_HIGHLIGHTED, for: .normal)
            highlightUpNavBottomLine(view: klineMinute)
            klineSecond.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineSecond)
        case 4:
            currentDay.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: currentDay)
            klineDay.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineDay)
            klineHour.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineHour)
            klineMinute.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightUpNavBottomLine(view: klineMinute)
            klineSecond.setTitleColor(CommonConstants.NAV_TEXT_HIGHLIGHTED, for: .normal)
            highlightUpNavBottomLine(view: klineSecond)
        default:
            break

        }
    }

    //初始化底部导航按钮添加横线
    func highlightBottomNavBorderLine(view: UIButton) {
        if let viewWithTag = view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = view.viewWithTag(101) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = view.viewWithTag(102) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = view.viewWithTag(103) {
            viewWithTag.removeFromSuperview()
        }

        let width = UIScreen.main.bounds.width / 4

        let lineView0 = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: view.frame.size.height))
        lineView0.backgroundColor = CommonConstants.NAV_TEXT_HIGHLIGHTED
        lineView0.tag = 100

        let lineView1 = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 2))
        lineView1.backgroundColor = CommonConstants.NAV_TEXT_HIGHLIGHTED
        lineView1.tag = 101

        let lineView2 = UIView(frame: CGRect(x: width - 2, y: 0, width: 2, height: view.frame.size.height))
        lineView2.backgroundColor = CommonConstants.NAV_TEXT_HIGHLIGHTED
        lineView2.tag = 102

        view.addSubview(lineView0)
        view.addSubview(lineView1)
        view.addSubview(lineView2)
    }

    func unhighlightBottomNavBorderLine(view: UIButton) {
        if let viewWithTag = view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = view.viewWithTag(101) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = view.viewWithTag(102) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = view.viewWithTag(103) {
            viewWithTag.removeFromSuperview()
        }
        let lineView3 = UIView(frame: CGRect(x: 0, y: view.frame.size.height - 2, width: UIScreen.main.bounds.width / 4, height: 2))
        lineView3.backgroundColor = CommonConstants.NAV_TEXT_HIGHLIGHTED
        lineView3.tag = 103

        view.addSubview(lineView3)

    }

    func controlTransactionVisibility(index: Int) {
        switch index {
        case 0:
            handicap.setTitleColor(CommonConstants.NAV_TEXT_HIGHLIGHTED, for: .normal)
            highlightBottomNavBorderLine(view: handicap)
            position.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: position)
            order.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: order)
            transaction.setTitleColor(CommonConstants.WHITE_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: transaction)
        case 1:
            handicap.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: handicap)
            position.setTitleColor(CommonConstants.NAV_TEXT_HIGHLIGHTED, for: .normal)
            highlightBottomNavBorderLine(view: position)
            order.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: order)
            transaction.setTitleColor(CommonConstants.WHITE_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: transaction)
        case 2:
            handicap.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: handicap)
            position.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: position)
            order.setTitleColor(CommonConstants.NAV_TEXT_HIGHLIGHTED, for: .normal)
            highlightBottomNavBorderLine(view: order)
            transaction.setTitleColor(CommonConstants.WHITE_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: transaction)
        case 3:
            handicap.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: handicap)
            position.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: position)
            order.setTitleColor(CommonConstants.NAV_TEXT, for: .normal)
            unhighlightBottomNavBorderLine(view: order)
            transaction.setTitleColor(CommonConstants.NAV_TEXT_HIGHLIGHTED, for: .normal)
            highlightBottomNavBorderLine(view: transaction)
        default:
            break

        }
    }

    func getDurationTitle(duration: String) -> String {
        var i = 0;
        for value in CommonConstants.klineDuration {
            if value.elementsEqual(duration){
                return CommonConstants.klineTypeTitle[i]
            }
            i += 1
        }
        return ""
    }

    // MARK: objc methods
    @objc func optionalInsListPopup() {
        if FileUtils.getOptional().isEmpty{return}
        if let optionalPopupView = UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: CommonConstants.PopupCollectionViewController) as? PopupCollectionViewController {
            optionalPopupView.modalPresentationStyle = .popover
            //箭头所指向的区域
            optionalPopupView.popoverPresentationController?.sourceView = self.navigationItem.titleView
            optionalPopupView.popoverPresentationController?.sourceRect = (self.navigationItem.titleView?.bounds)!
            //箭头方向
            optionalPopupView.popoverPresentationController?.permittedArrowDirections = .up
            //设置代理
            optionalPopupView.popoverPresentationController?.delegate = self
            optionalPopupView.insList = FileUtils.getOptional()
            let columnNum = ceilf(Float(optionalPopupView.insList.count) / 4.0)
            let collectionHeight = CGFloat(columnNum * 50 + 20 + (columnNum - 1) * 10)
            //弹出框口大小
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            optionalPopupView.preferredContentSize = CGSize(width: screenWidth, height: collectionHeight)
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width: screenWidth/5, height: 50)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            optionalPopupView.collectionView!.collectionViewLayout = layout
            optionalPopupView.flag = "optional"
            self.present(optionalPopupView, animated: true, completion: nil)
        }

    }

    @objc func showUpView() {
        upView.isHidden = false
    }

    @objc func hideUpView() {
        upView.isHidden = true
    }

    @objc func switchToPosition() {
        switchTransactionPage(index: 1)
    }

    @objc func switchToOrder() {
        switchTransactionPage(index: 2)
    }

    @objc func switchToTransaction() {
        switchTransactionPage(index: 3)
        let title = dataManager.getButtonTitle()
        button.setTitle(title, for: .normal)
    }

    //订阅合约行情
    @objc func sendSuscribeQuote(){
        var instrumentId = dataManager.sInstrumentId
        if instrumentId.contains("&") && instrumentId.contains(" ") {
            if let search = dataManager.sSearchEntities[instrumentId]{
                if let leg1_symbol = search.leg1_symbol, let leg2_symbol = search.leg2_symbol{
                    instrumentId = instrumentId + "," + leg1_symbol + "," + leg2_symbol
                }
            }
        }
        MDWebSocketUtils.getInstance().sendSubscribeQuote(insList: instrumentId)
        //设置按钮背景
        let optional = FileUtils.getOptional()
        if optional.contains(instrumentId){
            save.image = UIImage(named: "heart", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil)
        }else{
            save.image = UIImage(named: "heart_outline", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil)
        }
    }

    //切换K线图标
    @objc func switchKlineTitle(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary? {
            if let index = dict["durationIndex"] as? Int, let fragmentType = dict["fragmentType"] as? String{
                let klineTitle = CommonConstants.klineTypeTitle[index]
                switch fragmentType {
                case CommonConstants.DAY_FRAGMENT:
                    klineDay.setTitle(klineTitle, for: .normal)
                    if klinePageViewController.currentIndex == 1{
                        NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchDurationNotification), object: nil, userInfo: notification.userInfo)
                    }else {
                        switchKlinePage(index: 1)
                    }
                case CommonConstants.HOUR_FRAGMENT:
                    klineHour.setTitle(klineTitle, for: .normal)
                    if klinePageViewController.currentIndex == 2{
                        NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchDurationNotification), object: nil, userInfo: notification.userInfo)
                    }else {
                        switchKlinePage(index: 2)
                    }
                case CommonConstants.MINUTE_FRAGMENT:
                    klineMinute.setTitle(klineTitle, for: .normal)
                    if klinePageViewController.currentIndex == 3{
                        NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchDurationNotification), object: nil, userInfo: notification.userInfo)
                    }else {
                        switchKlinePage(index: 3)
                    }
                case CommonConstants.SECOND_FRAGMENT:
                    klineSecond.setTitle(klineTitle, for: .normal)
                    if klinePageViewController.currentIndex == 4{
                        NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchDurationNotification), object: nil, userInfo: notification.userInfo)
                    }else {
                        switchKlinePage(index: 4)
                    }
                default:
                    break
                }
            }
        }
    }

}

@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

extension UIView {

    @IBInspectable
    var cornerRadiusCL: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var borderWidthCL: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var borderColorCL: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }

    @IBInspectable
    var shadowRadiusCL: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable
    var shadowOpacityCL: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    var shadowOffsetCL: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColorCL: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
