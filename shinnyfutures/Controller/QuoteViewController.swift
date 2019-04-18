//
//  QuoteViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/26.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class QuoteViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {

    // MARK: Properties
    let button = UIButton(type: .custom)
    let dataManager = DataManager.getInstance()
    var transactionPageViewController: TransactionPageViewController!
    var klinePageViewController: KlinePageViewController!
    @IBOutlet weak var setup: UIButton!
    @IBOutlet weak var duration: UIButton!
    @IBOutlet weak var save: UIBarButtonItem!
    @IBOutlet weak var upView: UIStackView!
    @IBOutlet weak var handicap: UIButton!
    @IBOutlet weak var position: UIButton!
    @IBOutlet weak var order: UIButton!
    @IBOutlet weak var transaction: UIButton!
    @IBOutlet weak var downStackView: UIStackView!
    @IBOutlet weak var durationCollectionView: UICollectionView!
    @IBOutlet weak var downStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var md5View: DesignableView!
    var durations = [String]()
    var klineIndex = 0
    var transactionIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(self.optionalInsListPopup), for: .touchUpInside)
        self.navigationItem.titleView = button
        //设置按钮背景
        setOptionalBackground()

        durations.append(CommonConstants.klineDurationDay)
        let data = UserDefaults.standard.stringArray(forKey: CommonConstants.CONFIG_SETTING_KLINE_DURATION_DEFAULT) ?? [String]()
        durations.append(contentsOf: data)

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

            //从主页导航栏而来，默认展开持仓页
            if dataManager.sToQuoteTarget.elementsEqual("Position") {
                switchToPosition()
                downStackViewHeight.constant = 250
                dataManager.isShowDownStack = true
                handicap.setTitle(CommonConstants.HANDICAP_DOWN, for: .normal)
                position.setTitle(CommonConstants.POSITION_DOWN, for: .normal)
                order.setTitle(CommonConstants.ORDER_DOWN, for: .normal)
                transaction.setTitle(CommonConstants.TRANSACTION_DOWN, for: .normal)
            }
        }

        //控制五档行情显示
        initMD5ViewVisibility()

        //控制图表显示
        if dataManager.isShowDownStack {
            downStackViewHeight.constant = 250
            handicap.setTitle(CommonConstants.HANDICAP_DOWN, for: .normal)
            position.setTitle(CommonConstants.POSITION_DOWN, for: .normal)
            order.setTitle(CommonConstants.ORDER_DOWN, for: .normal)
            transaction.setTitle(CommonConstants.TRANSACTION_DOWN, for: .normal)
        }else {
            downStackViewHeight.constant = 40
            handicap.setTitle(CommonConstants.HANDICAP_UP, for: .normal)
            position.setTitle(CommonConstants.POSITION_UP, for: .normal)
            order.setTitle(CommonConstants.ORDER_UP, for: .normal)
            transaction.setTitle(CommonConstants.TRANSACTION_UP, for: .normal)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(updateMD5ViewVisibility), name: Notification.Name(CommonConstants.ControlMD5Notification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUpView), name: Notification.Name(CommonConstants.ShowUpViewNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideUpView), name: Notification.Name(CommonConstants.HideUpViewNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToPosition), name: Notification.Name(CommonConstants.SwitchToPositionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToOrder), name: Notification.Name(CommonConstants.SwitchToOrderNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToTransaction), name: Notification.Name(CommonConstants.SwitchToTransactionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendSuscribeQuote), name: Notification.Name(CommonConstants.SwitchQuoteNotification), object: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 45, height: 30)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return durations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DurationCollectionViewCell", for: indexPath) as! DurationCollectionViewCell

        let duration = durations[indexPath.row]
        cell.duration.text = duration
        if self.klineIndex == indexPath.row {
            cell.duration.textColor = CommonConstants.NAV_TEXT_HIGHLIGHTED
            cell.underline.backgroundColor = CommonConstants.NAV_TEXT_HIGHLIGHTED
        }else{
            cell.duration.textColor = CommonConstants.NAV_TEXT
            cell.underline.backgroundColor = CommonConstants.NAV_TEXT_UNHIGHLIGHTED
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let cell = durationCollectionView.cellForItem(at: indexPath) as? DurationCollectionViewCell{
            let durationTitle = cell.duration.text ?? ""
            switchDuration(durationTitle: durationTitle)
        }
        self.klineIndex = indexPath.row
        durationCollectionView.reloadData()
    }

    func switchDuration(durationTitle: String) {

        if CommonConstants.klineDurationDay.elementsEqual(durationTitle){
            switchKlinePage(index: 0, klineType: CommonConstants.CURRENT_DAY)
        }else {
            let duration = getDuration(durationTitle: durationTitle)
            if durationTitle.contains("秒"){
                switchKlinePage(index: 4, klineType: duration)
            }else if durationTitle.contains("分"){
                switchKlinePage(index: 3, klineType: duration)
            }else if durationTitle.contains("时"){
                switchKlinePage(index: 2, klineType: duration)
            }else{
                switchKlinePage(index: 1, klineType: duration)
            }
        }
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
        case CommonConstants.QuoteToSearch:
            if let searchViewController = segue.destination as? SearchTableViewController{
                searchViewController.segueIdentify = CommonConstants.QuoteToSearch
            }
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
                popupView.preferredContentSize = CGSize(width: 110, height: 160)
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
        setOptionalBackground()

    }

    @IBAction func klineDuration(_ sender: UIButton) {
        self.klineIndex = self.klineIndex + 1
        if self.klineIndex == durations.count {self.klineIndex = 0}
        let durationTitle = durations[self.klineIndex]
        switchDuration(durationTitle: durationTitle)
        self.durationCollectionView.reloadData()
        durationCollectionView.scrollToItem(at: IndexPath(row: self.klineIndex, section: 0), at: .right, animated: false)
    }

    @IBAction func handicap(_ sender: UIButton) {
        controlDownStackViewHeight(index: 0)
        switchTransactionPage(index: 0)
    }

    @IBAction func position(_ sender: UIButton) {
        if !DataManager.getInstance().sIsLogin {
            DataManager.getInstance().sToLoginTarget = "SwitchToPosition"
            performSegue(withIdentifier: CommonConstants.QuoteToLogin, sender: sender)
        } else {
            controlDownStackViewHeight(index: 1)
            switchTransactionPage(index: 1)
        }
    }

    @IBAction func order(_ sender: UIButton) {
        if !DataManager.getInstance().sIsLogin {
            DataManager.getInstance().sToLoginTarget = "SwitchToOrder"
            performSegue(withIdentifier: CommonConstants.QuoteToLogin, sender: sender)
        } else {
            controlDownStackViewHeight(index: 2)
            switchTransactionPage(index: 2)
        }
    }

    @IBAction func transaction(_ sender: UIButton) {
        if !DataManager.getInstance().sIsLogin {
            DataManager.getInstance().sToLoginTarget = "SwitchToTransaction"
            performSegue(withIdentifier: CommonConstants.QuoteToLogin, sender: sender)
        } else {
            controlDownStackViewHeight(index: 3)
            switchTransactionPage(index: 3)
        }
    }

    // MARK: functions
    private func controlDownStackViewHeight(index: Int){
        if transactionIndex == index {
            if downStackViewHeight.constant == 40{
                downStackViewHeight.constant = 250
                dataManager.isShowDownStack = true
                handicap.setTitle(CommonConstants.HANDICAP_DOWN, for: .normal)
                position.setTitle(CommonConstants.POSITION_DOWN, for: .normal)
                order.setTitle(CommonConstants.ORDER_DOWN, for: .normal)
                transaction.setTitle(CommonConstants.TRANSACTION_DOWN, for: .normal)
            }else {
                downStackViewHeight.constant = 40
                dataManager.isShowDownStack = false
                handicap.setTitle(CommonConstants.HANDICAP_UP, for: .normal)
                position.setTitle(CommonConstants.POSITION_UP, for: .normal)
                order.setTitle(CommonConstants.ORDER_UP, for: .normal)
                transaction.setTitle(CommonConstants.TRANSACTION_UP, for: .normal)
            }
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.ControlMiddleBottomChartViewNotification), object: nil)
        }else{
            if downStackViewHeight.constant == 40{
                downStackViewHeight.constant = 250
                dataManager.isShowDownStack = true
                handicap.setTitle(CommonConstants.HANDICAP_DOWN, for: .normal)
                position.setTitle(CommonConstants.POSITION_DOWN, for: .normal)
                order.setTitle(CommonConstants.ORDER_DOWN, for: .normal)
                transaction.setTitle(CommonConstants.TRANSACTION_DOWN, for: .normal)
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.ControlMiddleBottomChartViewNotification), object: nil)
            }
            transactionIndex = index
        }
    }

    private func switchKlinePage(index: Int, klineType: String) {
        if index >= klinePageViewController.subViewControllers.count || index < 0{
            return
        }
        let subView = klinePageViewController.subViewControllers[index]
        subView.klineType = klineType
        if klinePageViewController.currentIndex != index {
            klinePageViewController.setViewControllers([subView], direction: .forward, animated: false, completion: nil)
            klinePageViewController.currentIndex = index
        }else {
            var fragmengType = ""
            if index == 4{
                fragmengType = CommonConstants.SECOND_FRAGMENT
            }else if index == 3{
                fragmengType = CommonConstants.MINUTE_FRAGMENT
            }else if index == 2 {
                fragmengType = CommonConstants.HOUR_FRAGMENT
            }else if index == 1{
                fragmengType = CommonConstants.DAY_FRAGMENT
            }
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.SwitchDurationNotification), object: nil, userInfo: ["fragmentType": fragmengType])
        }
    }

    func switchTransactionPage(index: Int) {
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

        //控制交易部分视图上下移动的标志，涵盖点击切换和滑动切换产生的效果
        transactionIndex = index
    }

    func getDurationTitle(duration: String) -> String {
        var i = 0;
        for value in CommonConstants.klineDuration {
            if value.elementsEqual(duration){
                return CommonConstants.klineDurationAll[i]
            }
            i += 1
        }
        return ""
    }

    func getDuration(durationTitle: String) -> String {
        var i = 0;
        for value in CommonConstants.klineDurationAll {
            if value.elementsEqual(durationTitle){
                return CommonConstants.klineDuration[i]
            }
            i += 1
        }
        return ""
    }

    //刷新页面标题
    func updateTitle() {
        var title = dataManager.getButtonTitle() ?? ""
        title = title + " ▼"
        let size = title.size(withAttributes:[.font: UIFont.systemFont(ofSize:15.0)])
        button.frame = CGRect(x: 0, y: 0, width: size.width + 40, height: 40)
        button.setTitle(title, for: .normal)
        button.layoutIfNeeded()
    }

    //设置添加自选按钮背景
    func setOptionalBackground() {
        let optional = FileUtils.getOptional()
        if optional.contains(dataManager.sInstrumentId){
            save.image = UIImage(named: "heart", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil)
        }else{
            save.image = UIImage(named: "heart_outline", in: Bundle(identifier: "com.shinnytech.futures"), compatibleWith: nil)
        }
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
        //更新一下合约代码标题
        updateTitle()

        switchTransactionPage(index: 3)
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
        setOptionalBackground()

        //刷新五档行情
        updateMD5ViewVisibility()
    }

    //进入页面初始化五档行情
    func initMD5ViewVisibility() {
        if !dataManager.sInstrumentId.contains("SHFE") && !dataManager.sInstrumentId.contains("INE"){
            md5View.isHidden = true
        }else {
            //判断有无五档行情
            if let quote = dataManager.sRtnMD.quotes[dataManager.sInstrumentId], let ask_price5 = quote.ask_price5{
                if ask_price5 is NSNull{
                    UserDefaults.standard.set(false, forKey: CommonConstants.CONFIG_MD5)
                }
            }
            let isShowMD5 = UserDefaults.standard.bool(forKey: CommonConstants.CONFIG_MD5)
            if isShowMD5 {
                md5View.isHidden = false
            }else{
                md5View.isHidden = true
            }
        }
    }

    //切换合约刷新五档行情
    @objc func updateMD5ViewVisibility() {
        if !dataManager.sInstrumentId.contains("SHFE") && !dataManager.sInstrumentId.contains("INE"){
            md5View.isHidden = true
        }else {
            let isShowMD5 = UserDefaults.standard.bool(forKey: CommonConstants.CONFIG_MD5)
            if isShowMD5 {
                md5View.isHidden = false
            }else{
                md5View.isHidden = true
            }
        }
    }

    @IBAction func searchViewToQuoteControllerUnwindSegue(segue: UIStoryboardSegue) {
        print("我从搜索页来～")
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
