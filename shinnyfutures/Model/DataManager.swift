//
//  DataManager.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/19.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import Foundation
import SwiftyJSON

class DataManager {
    private static let instance: DataManager = {
        let dataManager = DataManager()
        return dataManager
    }()

    private init() {}

    class func getInstance() -> DataManager {
        return instance
    }
    private var sOptionalQuotes = [String: Quote]()
    private var sMainQuotes = [String: Quote]()
    private var sMainInsListNameNav = [String: String]()
    private var sShangqiQuotes = [String: Quote]()
    private var sShangqiInsListNameNav = [String: String]()
    private var sDalianQuotes = [String: Quote]()
    private var sDalianInsListNameNav = [String: String]()
    private var sZhengzhouQuotes = [String: Quote]()
    private var sZhengzhouInsListNameNav = [String: String]()
    private var sZhongjinQuotes = [String: Quote]()
    private var sZhongjinInsListNameNav = [String: String]()
    private var sNengyuanQuotes = [String: Quote]()
    private var sNengyuanInsListNameNav = [String: String]()
    private var sDalianzuheQuotes = [String: Quote]()
    private var sDalianzuheInsListNameNav = [String: String]()
    private var sZhengzhouzeheQuotes = [String: Quote]()
    private var sZhengzhouzeheInsListNameNav = [String: String]()

    var sSearchHistoryEntities = [String: Search]()
    var sSearchEntities = [String: Search]()
    var sQuotes = [[String: Quote]]()
    var sInsListNames = [[String: String]]()
    var sPreInsList = ""
    var sInstrumentId = ""
    var sIsLogin = false
    //进入登陆页的来源
    var sToLoginTarget = ""

    //////////////////////////////////////////////////////////////
    var sRtnMD = JSON()
    var sRtnBrokers = JSON()
    var sRtnLogin = JSON()
    var sRtnAcounts = [String: JSON]()
    var sRtnTrades = [String: JSON]()
    var sRtnPositions = [String: JSON]()
    var sRtnOrders = [String: JSON]()
    var sMobileConfirmSettlement = JSON()

    func parseLatestFile() {
        NSLog("解析开始")
        let latestString = FileUtils.readLatestFile()
        if let latestData = latestString?.data(using: .utf8) {
            do {
                guard let latestJson = try JSONSerialization.jsonObject(with: latestData, options: []) as? [String: Any] else { return }
                for (instrument_id, value) in latestJson {
                    let subJson = value as! [String: Any]
                    let classN = subJson["class"] as! String
                    if !"FUTURE_CONT".elementsEqual(classN) && !"FUTURE".elementsEqual(classN) && !"FUTURE_COMBINE".elementsEqual(classN){continue}
                    let ins_name = subJson["ins_name"] as! String
                    let exchange_id = subJson["exchange_id"] as! String
                    let price_tick = (subJson["price_tick"] as! NSNumber).stringValue
                    let volume_multiple = (subJson["volume_multiple"] as! NSNumber).stringValue
                    let sort_key = (subJson["sort_key"] as! NSNumber).intValue
                    let quote = Quote()
                    quote?.instrument_id = instrument_id
                    quote?.instrument_name = ins_name
                    let searchEntity = Search(instrument_id: instrument_id, instrument_name: ins_name, exchange_name: "", exchange_id: exchange_id, py: "", p_tick: price_tick, vm: volume_multiple, sort_key: sort_key)

                    if "FUTURE_CONT".elementsEqual(classN){
                        sMainQuotes[instrument_id] = quote
                        sMainInsListNameNav[ins_name.replacingOccurrences(of: "主连", with: "")] = instrument_id
                    }

                    if "FUTURE".elementsEqual(classN){
                        let product_short_name = subJson["product_short_name"] as! String
                        let py = subJson["py"] as! String
                        switch exchange_id {
                        case "SHFE":
                            sShangqiQuotes[instrument_id] = quote
                            sShangqiInsListNameNav[product_short_name] = instrument_id
                            searchEntity.exchange_name = "上海期货交易所"
                        case "CZCE":
                            sZhengzhouQuotes[instrument_id] = quote
                            sZhengzhouInsListNameNav[product_short_name] = instrument_id
                            searchEntity.exchange_name = "郑州商品交易所"
                        case "DCE":
                            sDalianQuotes[instrument_id] = quote
                            sDalianInsListNameNav[product_short_name] = instrument_id
                            searchEntity.exchange_name = "大连商品交易所"
                        case "CFFEX":
                            sZhongjinQuotes[instrument_id] = quote
                            sZhongjinInsListNameNav[product_short_name] = instrument_id
                            searchEntity.exchange_name = "中国金融期货交易所"
                        case "INE":
                            sNengyuanQuotes[instrument_id] = quote
                            sNengyuanInsListNameNav[product_short_name] = instrument_id
                            searchEntity.exchange_name = "上海国际能源交易中心"
                        default:
                            return
                        }
                        searchEntity.py = py
                    }

                    if "FUTURE_COMBINE".elementsEqual(classN){
                        let leg1_symbol = subJson["leg1_symbol"] as! String
                        let subJsonFuture = latestJson[leg1_symbol] as! [String: Any]
                        let product_short_name = subJsonFuture["product_short_name"] as! String
                        let py = subJsonFuture["py"] as! String
                        switch exchange_id {
                        case "CZCE":
                            sZhengzhouzeheQuotes[instrument_id] = quote
                            sZhengzhouzeheInsListNameNav[product_short_name] = instrument_id
                            searchEntity.exchange_name = "郑州商品交易所"
                        case "DCE":
                            sDalianzuheQuotes[instrument_id] = quote
                            sDalianzuheInsListNameNav[product_short_name] = instrument_id
                            searchEntity.exchange_name = "大连商品交易所"
                        default:
                            return
                        }
                        searchEntity.py = py
                    }
                    sSearchEntities[instrument_id] = searchEntity
                }

                //考虑到合约下架或合约列表中不存在，自选合约自建loop，反映到自选列表上让用户删除
                for ins in FileUtils.getOptional() {
                    let quote = Quote()
                    quote?.instrument_id = ins
                    if let instrumentName = sSearchEntities[ins]?.instrument_name {
                        quote?.instrument_name = instrumentName
                    } else {
                        quote?.instrument_name = ins
                    }
                    sOptionalQuotes[ins] = quote
                }

                sQuotes.append(sOptionalQuotes)
                sQuotes.append(sMainQuotes)
                sQuotes.append(sShangqiQuotes)
                sQuotes.append(sNengyuanQuotes)
                sQuotes.append(sDalianQuotes)
                sQuotes.append(sZhengzhouQuotes)
                sQuotes.append(sZhongjinQuotes)
                sQuotes.append(sDalianzuheQuotes)
                sQuotes.append(sZhengzhouzeheQuotes)

                sInsListNames.append([String: String]())
                sInsListNames.append(sMainInsListNameNav)
                sInsListNames.append(sShangqiInsListNameNav)
                sInsListNames.append(sNengyuanInsListNameNav)
                sInsListNames.append(sDalianInsListNameNav)
                sInsListNames.append(sZhengzhouInsListNameNav)
                sInsListNames.append(sZhongjinInsListNameNav)
                sInsListNames.append(sDalianzuheInsListNameNav)
                sInsListNames.append(sZhengzhouzeheInsListNameNav)

                
            } catch {
                print(error.localizedDescription)
            }
        }
        NSLog("解析结束")
    }

    func saveOrRemoveIns(ins: String) {
        var optional = FileUtils.getOptional()
        if !optional.contains(ins) {
            optional.append(ins)
            FileUtils.saveOptional(ins: optional)
            let quote = Quote()
            quote?.instrument_id = ins
            if let instrumentName = sSearchEntities[ins]?.instrument_name {
                quote?.instrument_name = instrumentName
            } else {
                quote?.instrument_name = ins
            }
            sQuotes[0][ins] = quote
            ToastUtils.showPositiveMessage(message: "合约\(ins)已添加到自选～")
        } else if let index = optional.index(of: ins) {
            optional.remove(at: index)
            FileUtils.saveOptional(ins: optional)
            //如果三个数据集之间不同步,删除会有崩溃的危险
            sQuotes[0].removeValue(forKey: ins)
            ToastUtils.showNegativeMessage(message: "合约\(ins)被踢出自选～")
        }
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.RefreshOptionalInsListNotification), object: nil)
    }

    func saveDecimalByPtick(decimal: Int, data: String) -> String {
        guard let num = Double(data) else {return data}
        return String(format: "%.\(decimal)f", num)
    }

    func getDecimalByPtick(instrumentId: String) -> Int {
        if let search = sSearchEntities[instrumentId] {
            let ptick = search.p_tick
            if ptick.contains("."), let index = ptick.index(of: ".")?.encodedOffset {
                let decimal = ptick.count - index - 1
                return decimal
            } else {
                return 0
            }
        }
        return 0
    }

    func getPrice(open_cost: Float, open_price: Float, vm: Int, volume: Int) -> Float {
        if open_price != 0 {
            return open_price
        } else if open_cost != 0 {
            return open_cost / Float(volume * vm)
        } else {
            return 0.0
        }
    }

    func parseRtnMD(rtnData: JSON) {
        do {
//            NSLog("解析开始")
            let dataArray = rtnData[RtnMDConstants.data].arrayValue
            for dataJson in dataArray {
                try sRtnMD.merge(with: dataJson)
            }
//            NSLog("解析完毕")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func parseBrokers(brokers: JSON) {
        do {
            try sRtnBrokers.merge(with: brokers)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.BrokerInfoNotification), object: nil)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func parseRtnTD(transactionData: JSON) {
        do {
            let dataArray = transactionData[RtnTDConstants.data].arrayValue
            for dataJson in dataArray {
                let tradeJson = dataJson[RtnTDConstants.trade]
                if !tradeJson.isEmpty {
                    for (_, accountJson) in tradeJson.dictionaryValue {
                        for (key, value) in accountJson.dictionaryValue {
                            switch key {
                            case RtnTDConstants.accounts:
                                for (accountKey, account) in value.dictionaryValue {
                                    sRtnAcounts[accountKey] = account
                                }
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: Notification.Name(CommonConstants.AccountNotification), object: nil)
                                }
                            case RtnTDConstants.trades:
                                for (tradeKey, trade) in value.dictionaryValue {
                                    sRtnTrades[tradeKey] = trade
                                }
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: Notification.Name(CommonConstants.TradeNotification), object: nil)
                                }
                            case RtnTDConstants.positions:
                                print(value.dictionaryValue)
                                for (positionKey, position) in value.dictionaryValue {
                                    sRtnPositions[positionKey] = position
                                }
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: Notification.Name(CommonConstants.PositionNotification), object: nil)
                                }
                            case RtnTDConstants.orders:
                                for (orderKey, order) in value.dictionaryValue {
                                    sRtnOrders[orderKey] = order
                                }
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: Notification.Name(CommonConstants.OrderNotification), object: nil)
                                }
                            default:
                                break
                            }
                        }
                    }
                }

                let notifyArray = dataJson[RtnTDConstants.notify]
                if !notifyArray.isEmpty {
                    for (_, notifyJson) in notifyArray.dictionaryValue {
                        DispatchQueue.main.async {
                            ToastUtils.showPositiveMessage(message: notifyJson[NotifyConstants.content].stringValue)
                        }
                        try sRtnLogin.merge(with: notifyJson)
                    }
                    if !DataManager.getInstance().sIsLogin && sRtnLogin[NotifyConstants.content].stringValue.elementsEqual("登录成功") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name(CommonConstants.LoginNotification), object: nil)
                        }
                    }
                }
            }

        } catch {
            print(error.localizedDescription)
        }
    }

}
