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

    var sSearchHistoryEntities = [String: Search]()
    var sSearchEntities = [String: Search]()
    var sQuotes = [[(key: String, value: Quote)]]()
    var sInsListNames = [[(key: String, value: String)]]()
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
        var sOptionalQuotes = [String: Quote]()
        var sMainQuotes = [String: Quote]()
        var sMainInsListNameNav = [String: String]()
        var sShangqiQuotes = [String: Quote]()
        var sShangqiInsListNameNav = [String: String]()
        var sDalianQuotes = [String: Quote]()
        var sDalianInsListNameNav = [String: String]()
        var sZhengzhouQuotes = [String: Quote]()
        var sZhengzhouInsListNameNav = [String: String]()
        var sZhongjinQuotes = [String: Quote]()
        var sZhongjinInsListNameNav = [String: String]()
        var sNengyuanQuotes = [String: Quote]()
        var sNengyuanInsListNameNav = [String: String]()
        var sDalianzuheQuotes = [String: Quote]()
        var sDalianzuheInsListNameNav = [String: String]()
        var sZhengzhouzeheQuotes = [String: Quote]()
        var sZhengzhouzeheInsListNameNav = [String: String]()
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
                    let searchEntity = Search(instrument_id: instrument_id, instrument_name: ins_name, exchange_name: "", exchange_id: exchange_id, py: "", p_tick: price_tick, vm: volume_multiple, sort_key: sort_key, margin: 0, underlying_symbol: "")

                    if "FUTURE_CONT".elementsEqual(classN){
                        let py = subJson["py"] as! String
                        searchEntity.py = py
                        let underlying_symbol = subJson["underlying_symbol"] as! String
                        if "".elementsEqual(underlying_symbol){continue}
                        searchEntity.underlying_symbol = underlying_symbol
                        sMainQuotes[instrument_id] = quote
                        sMainInsListNameNav[ins_name.replacingOccurrences(of: "主连", with: "")] = instrument_id
                    }

                    if "FUTURE".elementsEqual(classN){
                        let product_short_name = subJson["product_short_name"] as! String
                        let py = subJson["py"] as! String
                        let margin = (subJson["margin"] as! NSNumber).intValue
                        searchEntity.py = py
                        searchEntity.margin = margin
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
                    }

                    if "FUTURE_COMBINE".elementsEqual(classN){
                        let leg1_symbol = subJson["leg1_symbol"] as! String
                        let subJsonFuture = latestJson[leg1_symbol] as! [String: Any]
                        let product_short_name = subJsonFuture["product_short_name"] as! String
                        let py = subJsonFuture["py"] as! String
                        searchEntity.py = py
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

                sQuotes.append(sortByKey(insList: sOptionalQuotes))
                sQuotes.append(sortByKey(insList: sMainQuotes))
                sQuotes.append(sortByKey(insList: sShangqiQuotes))
                sQuotes.append(sortByKey(insList: sNengyuanQuotes))
                sQuotes.append(sortByKey(insList: sDalianQuotes))
                sQuotes.append(sortByKey(insList: sZhengzhouQuotes))
                sQuotes.append(sortByKey(insList: sZhongjinQuotes))
                sQuotes.append(sortByKey(insList: sDalianzuheQuotes))
                sQuotes.append(sortByKey(insList: sZhengzhouzeheQuotes))

                sInsListNames.append([(key: String, value: String)]())
                sInsListNames.append(sortByValue(insList: sMainInsListNameNav))
                sInsListNames.append(sortByValue(insList: sShangqiInsListNameNav))
                sInsListNames.append(sortByValue(insList: sNengyuanInsListNameNav))
                sInsListNames.append(sortByValue(insList: sDalianInsListNameNav))
                sInsListNames.append(sortByValue(insList: sZhengzhouInsListNameNav))
                sInsListNames.append(sortByValue(insList: sZhongjinInsListNameNav))
                sInsListNames.append(sortByValue(insList: sDalianzuheInsListNameNav))
                sInsListNames.append(sortByValue(insList: sZhengzhouzeheInsListNameNav))

                
            } catch {
                print(error.localizedDescription)
            }
        }
        NSLog("解析结束")
    }

    func sortByKey(insList: [String: Quote]) -> [(key: String, value: Quote)] {
        return insList.sorted(by: {
            if let sortKey0 = (sSearchEntities[$0.key]?.sort_key), let sortKey1 = (sSearchEntities[$1.key]?.sort_key){
                if sortKey0 != sortKey1{
                    return sortKey0 < sortKey1
                }else{
                    return $0.key < $1.key
                }
            }
            return $0.key < $1.key
        })
    }

    func sortByValue(insList: [String: String]) -> [(key: String, value: String)] {
        return insList.sorted(by: {
            if let sortKey0 = (sSearchEntities[$0.value]?.sort_key), let sortKey1 = (sSearchEntities[$1.value]?.sort_key){
                if sortKey0 != sortKey1{
                    return sortKey0 < sortKey1
                }else{
                    return $0.value < $1.value
                }
            }
            return $0.value < $1.value
        })
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
            sQuotes[0].append((key: ins, value: quote!))
            ToastUtils.showPositiveMessage(message: "合约\(ins)已添加到自选～")
        } else if let index = optional.index(of: ins), let index1 = sQuotes[0].index(where: {$0.key.elementsEqual(ins)}){
            optional.remove(at: index)
            FileUtils.saveOptional(ins: optional)
            //如果三个数据集之间不同步,删除会有崩溃的危险
            sQuotes[0].remove(at: index1)
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
