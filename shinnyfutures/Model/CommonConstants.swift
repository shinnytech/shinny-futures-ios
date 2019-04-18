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
    public static let REDMINE_URL = "https://ask.shinnytech.com/src/indexm.html"

    //MARK: default config
    public static let CONFIG_SETTING_KLINE_DURATION_DEFAULT = "klineDurationDefault"
    public static let CONFIG_SETTING_PARA_MA = "maOrder"
    public static let CONFIG_SETTING_TRANSACTION_SHOW_ORDER = "orderSetting"
    public static let CONFIG_POSITION_LINE = "positionLine"
    public static let CONFIG_ORDER_LINE = "orderLine"
    public static let CONFIG_AVERAGE_LINE = "averageLine"
    public static let CONFIG_MD5 = "md5"
    public static let CONFIG_LOCK_USER_NAME = "isLocked"
    public static let CONFIG_LOCK_PASSWORD = "isLocked"
    public static let CONFIG_PASSWORD = "userPassword"
    public static let CONFIG_USER_NAME = "userName"
    public static let CONFIG_BROKER = "brokerInfo"
    public static let CONFIG_LOGIN_DATE = "loginDate"
    public static let CONFIG_KLINE_DAY_TYPE = "klineDay"
    public static let CONFIG_KLINE_HOUR_TYPE = "klineHour"
    public static let CONFIG_KLINE_MINUTE_TYPE = "klineMinute"
    public static let CONFIG_KLINE_SECOND_TYPE = "klineSecond"

    //MARK: Kline type
    public static let CHART_ID = "CHART_ID"
    public static let CURRENT_DAY_FRAGMENT = "CURRENT_DAY_FRAGMENT"
    public static let DAY_FRAGMENT = "DAY_FRAGMENT"
    public static let HOUR_FRAGMENT = "HOUR_FRAGMENT"
    public static let MINUTE_FRAGMENT = "MINUTE_FRAGMENT"
    public static let SECOND_FRAGMENT = "SECOND_FRAGMENT"
    public static let CURRENT_DAY = "60000000000"
    public static let KLINE_3_SECOND = "3000000000"
    public static let KLINE_5_SECOND = "5000000000"
    public static let KLINE_10_SECOND = "10000000000"
    public static let KLINE_15_SECOND = "15000000000"
    public static let KLINE_20_SECOND = "20000000000"
    public static let KLINE_30_SECOND = "30000000000"
    public static let KLINE_1_MINUTE = "60000000000"
    public static let KLINE_2_MINUTE = "120000000000"
    public static let KLINE_3_MINUTE = "180000000000"
    public static let KLINE_5_MINUTE = "300000000000"
    public static let KLINE_10_MINUTE = "600000000000"
    public static let KLINE_15_MINUTE = "900000000000"
    public static let KLINE_30_MINUTE = "1800000000000"
    public static let KLINE_1_HOUR = "3600000000000"
    public static let KLINE_2_HOUR = "7200000000000"
    public static let KLINE_4_HOUR = "14400000000000"
    public static let KLINE_1_DAY = "86400000000000"
    public static let KLINE_7_DAY = "604800000000000"
    public static let KLINE_28_DAY = "2419200000000000"
    public static let MAX_SUBSCRIBE_QUOTES = 24
    public static let VIEW_WIDTH = 200
    public static let SCALE_X = "scaleX"
    public static let klineDurationDefault = ["3秒", "5秒", "10秒", "15秒", "1分", "3分",
                                              "5分", "10分", "15分", "30分", "1时", "4时", "1日", "1周", "4周"]
    public static let klineDurationAll = ["3秒", "5秒", "10秒", "15秒", "20秒", "30秒", "1分", "2分", "3分",
                          "5分", "10分", "15分", "30分", "1时", "2时", "4时", "1日", "1周", "4周"]
    public static let klineDurationDay = "分时"
    public static let klineDuration = [CommonConstants.KLINE_3_SECOND, CommonConstants.KLINE_5_SECOND, CommonConstants.KLINE_10_SECOND,
                         CommonConstants.KLINE_15_SECOND, CommonConstants.KLINE_20_SECOND, CommonConstants.KLINE_30_SECOND, CommonConstants.KLINE_1_MINUTE, CommonConstants.KLINE_2_MINUTE, CommonConstants.KLINE_3_MINUTE,
                         CommonConstants.KLINE_5_MINUTE, CommonConstants.KLINE_10_MINUTE, CommonConstants.KLINE_15_MINUTE, CommonConstants.KLINE_30_MINUTE, CommonConstants.KLINE_1_HOUR, CommonConstants.KLINE_2_HOUR,
                         CommonConstants.KLINE_4_HOUR, CommonConstants.KLINE_1_DAY, CommonConstants.KLINE_7_DAY, CommonConstants.KLINE_28_DAY]
    

    //MARK: Quote page title
    public static let titleArray = ["自选合约", "主力合约", "上海期货交易所", "上海能源交易中心", "大连商品交易所", "郑州商品交易所", "中国金融期货交易所", "大连组合", "郑州组合"]

    public static let rightTitleArrayLogged = [[["login","退出交易"]], [["setting", "选项设置"]], [["account","资金详情"], ["password","修改密码"], ["position","持仓汇总"], ["trade","成交记录"], ["bank","银期转帐"], ["open_account", "在线开户"], ["feedback","问题反馈"], ["about","关于"]]]

     public static let rightTitleArray = [[["login","登录交易"]], [["setting", "选项设置"]], [["account","资金详情"], ["position","持仓汇总"], ["trade","成交记录"], ["bank","银期转帐"], ["open_account", "在线开户"], ["feedback","问题反馈"], ["about","关于"]]]

    public static let rightArray = [[["feedback","问题反馈"], ["about","关于"]]]

    // MARK: Notification
    public static let RefreshOptionalInsListNotification = "RefreshOptionalInsListNotification"
    public static let PopupOptionalInsListNotification = "PopupOptionalInsListNotification"
    public static let RtnMDNotification = "RtnMDNotification"
    public static let BrokerInfoNotification = "BrokerInfoNotification"
    public static let BrokerInfoEmptyNotification = "BrokerInfoEmptyNotification"
    public static let LoginNotification = "LoginNotification"
    public static let ChangeSuccessNotification = "ChangeSuccessNotification"
    public static let WeakPasswordNotification = "WeakPasswordNotification"
    public static let RtnTDNotification = "RtnTDNotification"
    public static let ControlMiddleBottomChartViewNotification = "ControlMiddleBottomChartViewNotification"
    public static let SwitchQuoteNotification = "SwitchQuoteNotification"
    public static let SwitchDurationNotification = "SwitchDurationNotification"
    public static let ClearChartViewNotification = "ClearChartViewNotification"
    public static let SwitchToPositionNotification = "SwitchToPositionNotification"
    public static let SwitchToOrderNotification = "SwitchToOrderNotification"
    public static let SwitchToTransactionNotification = "SwitchToTransactionNotification"
    public static let ShowUpViewNotification = "ShowUpViewNotification"
    public static let HideUpViewNotification = "HideUpViewNotification"
    public static let ControlPositionLineNotification = "ControlPositionLineNotification"
    public static let ControlOrderLineNotification = "ControlOrderLineNotification"
    public static let ControlAverageLineNotification = "ControlAverageLineNotification"
    public static let ControlMD5Notification = "ControlMD5Notification"
    public static let LatestFileParsedNotification = "LatestFileParsedNotification"

    // MARK: Identifier
    public static let QuoteNavigationCollectionViewController = "QuoteNavigationCollectionViewController"
    public static let QuotePageViewController = "QuotePageViewController"
    public static let MainToQuote = "MainToQuote"
    public static let MainToLogin = "MainToLogin"
    public static let MainToSearch = "MainToSearch"
    public static let MainToSetting = "MainToSetting"
    public static let MainToChangePassword = "MainToChangePassword"
    public static let MainToAccount = "MainToAccount"
    public static let MainToTrade = "MainToTrade"
    public static let MainToBankTransfer = "MainToBankTransfer"
    public static let MainToFeedback = "MainToFeedback"
    public static let MainToAbout = "MainToAbout"
    public static let SearchToMain = "SearchToMain"
    public static let SearchToQuote = "SearchToQuote"
    public static let LoginToMain = "LoginToMain"
    public static let LoginToQuote = "LoginToQuote"
    public static let LoginToBroker = "LoginToBroker"
    public static let LoginToChangePassword = "LoginToChangePassword"
    public static let LoginToAccount = "LoginToAccount"
    public static let LoginToTrade = "LoginToTrade"
    public static let LoginToBankTransfer = "LoginToBankTransfer"
    public static let LoginToSettlement = "LoginToSettlement"
    public static let QuoteToLogin = "QuoteToLogin"
    public static let QuoteToSearch = "QuoteToSearch"
    public static let BrokerToLogin = "BrokerToLogin"
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
    public static let OptionalPopupTableViewController = "OptionalPopupTableViewController"
    public static let PopupCollectionViewController = "PopupCollectionViewController"
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
    public static let HANDICAP_UP = "盘口▴"
    public static let POSITION_UP = "持仓▴"
    public static let ORDER_UP = "委托▴"
    public static let TRANSACTION_UP = "交易▴"
    public static let HANDICAP_DOWN = "盘口▾"
    public static let POSITION_DOWN = "持仓▾"
    public static let ORDER_DOWN = "委托▾"
    public static let TRANSACTION_DOWN = "交易▾"

    //MARK: 合约页配色
    public static let STATUS_BAR = UIColor(red: 29/255.0, green: 29/255.0, blue: 29/255.0, alpha: 1)
    public static let QUOTE_PAGE_HEADER = UIColor(red: 29/255.0, green: 29/255.0, blue: 29/255.0, alpha: 1)
    public static let QUOTE_TABLE_HEADER_1 = UIColor(red: 68/255.0, green: 68/255.0, blue: 68/255.0, alpha: 1)
    public static let QUOTE_TABLE_HEADER_2 = UIColor(red: 99/255.0, green: 99/255.0, blue: 99/255.0, alpha: 1)
    public static let RED_TEXT = UIColor(red: 160/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1)
    public static let GREEN_TEXT = UIColor(red: 26/255.0, green: 197/255.0, blue: 26/255.0, alpha: 1)
    public static let WHITE_TEXT = UIColor(red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha:1)
    public static let MARK_RED = UIColor(red: 255/255.0, green: 60/255.0, blue: 60/255.0, alpha:1)
    public static let MARK_GREEN = UIColor(red: 0/255.0, green: 220/255.0, blue: 0/255.0, alpha:1)
    public static let MARK_YELLOW = UIColor(red: 220/255.0, green: 220/255.0, blue: 10/255.0, alpha:1)

    //MARK: 合约详情页
    public static let NAV_TEXT = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
    public static let NAV_TEXT_HIGHLIGHTED = UIColor(red: 255/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1)
    public static let NAV_TEXT_UNHIGHLIGHTED = UIColor(red: 68/255.0, green: 68/255.0, blue: 68/255.0, alpha: 1)
    public static let KLINE_GRID = UIColor(red: 180/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
    public static let KLINE_MD1 = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    public static let KLINE_MD2 = UIColor(red: 255/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1)
    public static let KLINE_MD3 = UIColor(red: 255/255.0, green: 0/255.0, blue: 255/255.0, alpha: 1)
    public static let KLINE_MD4 = UIColor(red: 0/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1)
    public static let KLINE_MD5 = UIColor(red: 178/255.0, green: 178/255.0, blue: 178/255.0, alpha: 1)
    public static let KLINE_MD6 = UIColor(red: 255/255.0, green: 60/255.0, blue: 60/255.0, alpha: 1)
    public static let KLINE_MDs = [KLINE_MD1, KLINE_MD2, KLINE_MD3, KLINE_MD4, KLINE_MD5, KLINE_MD6]
    public static let KLINE_PO_LINE_SELL = UIColor(red: 26/255.0, green: 197/255.0, blue: 26/255.0, alpha: 1)
    public static let KLINE_PO_LINE_BUY = UIColor(red: 160/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1)

    //MARK: 登录页
    public static let LOGIN_COLOR = UIColor(red: 190/255, green: 0, blue: 15/255, alpha: 1).cgColor

    //MARK: 交易页
    public static let BID_BUTTON = UIColor(red: 179/255, green: 69/255, blue: 69/255, alpha: 1)
    public static let ASK_BUTTON = UIColor(red: 54/255, green: 142/255, blue: 95/255, alpha: 1)

    //MARK: 设置页
    public static let BOLD_DEVIDER = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
    public static let PARA_NAV_SELECTED = UIColor(red: 190/255, green: 0, blue: 15/255, alpha: 1)
    public static let PARA_CONTENT_FOOTER = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1)
    public static let PARA_MA = [5, 10, 20, 60, 0, 0]
    public static let ADD_DURATION_SELECTED = UIColor(red: 190/255, green: 0, blue: 15/255, alpha: 0.8)

}
