//
//  CommonConstants.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/20.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import Foundation

class CommonConstants {
    //MARK: Server URL
    public static var LATEST_FILE_URL = "http://openmd.shinnytech.com/t/md/symbols/latest.json"
    public static let MARKET_URL_1 = "ws://openmd.shinnytech.com/t/md/front/mobile"
    public static let MARKET_URL_2 = "ws://139.198.126.116/t/md/front/mobile"
    public static let MARKET_URL_3 = "ws://139.198.122.80/t/md/front/mobile"
    public static let MARKET_URL_4 = "ws://139.198.123.206/t/md/front/mobile"
    public static let MARKET_URL_5 = "ws://106.15.82.247/t/md/front/mobile"
    public static let MARKET_URL_6 = "ws://106.15.82.189/t/md/front/mobile"
    public static let MARKET_URL_7 = "ws://106.15.219.160/t/md/front/mobile"
    public static var TRANSACTION_URL = "ws://opentd.shinnytech.com/trade/user0"
    public static let REDMINE_URL = "http://ask.shinnytech.com/src/indexm.html"

    //MARK: Kline type
    public static let KLINE_MINUTE = "300000000000"
    public static let KLINE_HOUR = "3600000000000"
    public static let KLINE_DAY = "86400000000000"
    public static let CURRENT_DAY = "60000000000"
    public static let MAX_SUBSCRIBE_QUOTES = 24
    public static let VIEW_WIDTH = 200

    //MARK: Quote page title
    public static let titleArray = ["自选合约", "主力合约", "上海期货交易所", "上期能源", "大连商品交易所", "郑州商品交易所", "中国金融期货交易所", "大连组合", "郑州组合"]

    // MARK: Notification
    public static let RefreshOptionalInsListNotification = "RefreshOptionalInsListNotification"
    public static let RtnMDNotification = "RtnMDNotification"
    public static let BrokerInfoNotification = "BrokerInfoNotification"
    public static let BrokerInfoEmptyNotification = "BrokerInfoEmptyNotification"
    public static let LoginNotification = "LoginNotification"
    public static let RtnTDNotification = "RtnTDNotification"
    public static let SwitchQuoteNotification = "SwitchQuoteNotification"
    public static let ClearChartViewNotification = "ClearChartViewNotification"
    public static let SwitchToPositionNotification = "SwitchToPositionNotification"
    public static let SwitchToOrderNotification = "SwitchToOrderNotification"
    public static let SwitchToTransactionNotification = "SwitchToTransactionNotification"
    public static let ShowUpViewNotification = "ShowUpViewNotification"
    public static let HideUpViewNotification = "HideUpViewNotification"
    public static let ControlPositionLineNotification = "ControlPositionLineNotification"
    public static let ControlOrderLineNotification = "ControlOrderLineNotification"
    public static let ControlAverageLineNotification = "ControlAverageLineNotification"
    public static let LatestFileParsedNotification = "LatestFileParsedNotification"

    // MARK: Identifier
    public static let QuoteNavigationCollectionViewController = "QuoteNavigationCollectionViewController"
    public static let QuotePageViewController = "QuotePageViewController"
    public static let MainToQuote = "MainToQuote"
    public static let MainToLogin = "MainToLogin"
    public static let MainToAccount = "MainToAccount"
    public static let MainToTrade = "MainToTrade"
    public static let MainToBankTransfer = "MainToBankTransfer"
    public static let MainToFeedback = "MainToFeedback"
    public static let MainToAbout = "MainToAbout"
    public static let LoginToQuote = "LoginToQuote"
    public static let LoginToAccount = "LoginToAccount"
    public static let LoginToTrade = "LoginToTrade"
    public static let LoginToBankTransfer = "LoginToBankTransfer"
    public static let LoginToSettlement = "LoginToSettlement"
    public static let QuoteToLogin = "QuoteToLogin"
    public static let KlinePageViewController = "KlinePageViewController"
    public static let CurrentDayViewController = "CurrentDayViewController"
    public static let KlineViewController = "KlineViewController"
    public static let TransactionPageViewController = "TransactionPageViewController"
    public static let HandicapViewController = "HandicapViewController"
    public static let PositionTableViewController = "PositionTableViewController"
    public static let OrderTableViewController = "OrderTableViewController"
    public static let TransactionViewController = "TransactionViewController"
    public static let KlinePopupView = "KlinePopupView"
    public static let OptionalPopupViewController = "OptionalPopupViewController"
    public static let OptionalPopupCollectionViewController = "OptionalPopupCollectionViewController"
    public static let QuoteTableViewController = "QuoteTableViewController"
    public static let QuoteViewControllerUnwindSegue = "QuoteViewControllerUnwindSegue"
    public static let LoginViewControllerUnwindSegue = "LoginViewControllerUnwindSegue"
    public static let AccountViewControllerUnwindSegue = "AccountViewControllerUnwindSegue"
    public static let TradeTableViewControllerUnwindSegue = "TradeTableViewControllerUnwindSegue"

    //MARK: 下单板价格类型
    public static let LATEST_PRICE = "最新价"
    public static let COUNTERPARTY_PRICE = "对手价"
    public static let MARKET_PRICE = "市价"
    public static let QUEUED_PRICE = "排队价"
    public static let USER_PRICE = "用户设置价"
}
