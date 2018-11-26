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
    var sQuotes = [[(key: String, value: JSON)]]()
    var sInsListNames = [[(key: String, value: String)]]()

    //////////////////////////////////////////////////////////////
    var sRtnMD = JSON()
    var sRtnBrokers = JSON()
    var sRtnTD = JSON()
    var sPreInsList = ""
    var sInstrumentId = ""
    var isBackground = false
    var sIsLogin = false
    var sIsEmpty = false
    var sUser_id = ""
    var sAppVersion = ""
    var sAppBuild = ""
    var sPriceType = CommonConstants.COUNTERPARTY_PRICE
    //进入登陆页的来源
    var sToLoginTarget = ""

    func parseLatestFile() {
        NSLog("解析开始")
        var sOptionalQuotes = [String: JSON]()
        var sMainQuotes = [String: JSON]()
        var sMainInsListNameNav = [String: String]()
        var sShangqiQuotes = [String: JSON]()
        var sShangqiInsListNameNav = [String: String]()
        var sDalianQuotes = [String: JSON]()
        var sDalianInsListNameNav = [String: String]()
        var sZhengzhouQuotes = [String: JSON]()
        var sZhengzhouInsListNameNav = [String: String]()
        var sZhongjinQuotes = [String: JSON]()
        var sZhongjinInsListNameNav = [String: String]()
        var sNengyuanQuotes = [String: JSON]()
        var sNengyuanInsListNameNav = [String: String]()
        var sDalianzuheQuotes = [String: JSON]()
        var sDalianzuheInsListNameNav = [String: String]()
        var sZhengzhouzeheQuotes = [String: JSON]()
        var sZhengzhouzeheInsListNameNav = [String: String]()
        let latestString = FileUtils.readLatestFile()
        if let latestData = latestString?.data(using: .utf8) {
            do {
                guard let latestJson = try JSONSerialization.jsonObject(with: latestData, options: []) as? [String: Any] else { return }
                for (instrument_id, value) in latestJson {
                    let subJson = value as! [String: Any]
                    guard let classN = subJson["class"] as? String else {return}
                    if !"FUTURE_CONT".elementsEqual(classN) && !"FUTURE".elementsEqual(classN) && !"FUTURE_COMBINE".elementsEqual(classN){continue}
                    guard let ins_name = subJson["ins_name"] as? String else {return}
                    let expired = subJson["expired"] as? Bool
                    let exchange_id = subJson["exchange_id"] as! String
                    let price_tick = (subJson["price_tick"] as? NSNumber)?.stringValue
                    let price_decs = (subJson["price_decs"] as? NSNumber)?.intValue
                    let volume_multiple = (subJson["volume_multiple"] as? NSNumber)?.stringValue
                    let sort_key = (subJson["sort_key"] as? NSNumber)?.intValue

                    let searchEntity = Search(instrument_id: instrument_id, instrument_name: ins_name, exchange_name: "", exchange_id: exchange_id, py: "", p_tick: price_tick, p_decs: price_decs, vm: volume_multiple, sort_key: sort_key, margin: 0, underlying_symbol: "", pre_volume: 0)

                    if "FUTURE_CONT".elementsEqual(classN){
                        sMainQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                        sMainInsListNameNav[ins_name.replacingOccurrences(of: "主连", with: "")] = instrument_id

                        let py = subJson["py"] as? String
                        searchEntity.py = py
                        guard let underlying_symbol = subJson["underlying_symbol"] as? String else {return}
                        searchEntity.underlying_symbol = underlying_symbol
                        guard let subJsonFuture = latestJson[underlying_symbol] as? [String: Any] else {return}
                        let pre_volume = (subJsonFuture["pre_volume"] as? NSNumber)?.intValue
                        searchEntity.pre_volume = pre_volume
                    }

                    if "FUTURE".elementsEqual(classN){
                        guard let product_short_name = subJson["product_short_name"] as? String else {return}
                        guard let expired = expired else {return}
                        switch exchange_id {
                        case "SHFE":
                            if !expired{
                                sShangqiQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sShangqiInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "上海期货交易所"
                        case "CZCE":
                            if !expired{
                                sZhengzhouQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sZhengzhouInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "郑州商品交易所"
                        case "DCE":
                            if !expired {
                                sDalianQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sDalianInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "大连商品交易所"
                        case "CFFEX":
                            if !expired {
                                sZhongjinQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sZhongjinInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "中国金融期货交易所"
                        case "INE":
                            if !expired{
                                sNengyuanQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sNengyuanInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "上海国际能源交易中心"
                        default:
                            return
                        }
                        let py = subJson["py"] as? String
                        let margin = (subJson["margin"] as? NSNumber)?.intValue
                        let pre_volume = (subJson["pre_volume"] as? NSNumber)?.intValue
                        searchEntity.pre_volume = pre_volume
                        searchEntity.py = py
                        searchEntity.margin = margin
                    }

                    if "FUTURE_COMBINE".elementsEqual(classN){
                        guard let leg1_symbol = subJson["leg1_symbol"] as? String else {return}
                        guard let subJsonFuture = latestJson[leg1_symbol] as? [String: Any] else {return}
                        guard let product_short_name = subJsonFuture["product_short_name"] as? String else {return}
                        guard let expired = expired else {return}
                        switch exchange_id {
                        case "CZCE":
                            if !expired{
                                sZhengzhouzeheQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sZhengzhouzeheInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "郑州商品交易所"
                        case "DCE":
                            if !expired{
                                sDalianzuheQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sDalianzuheInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "大连商品交易所"
                        default:
                            return
                        }
                        let py = subJsonFuture["py"] as? String
                        let pre_volume = (subJson["pre_volume"] as? NSNumber)?.intValue
                        searchEntity.pre_volume = pre_volume
                        searchEntity.py = py
                    }
                    sSearchEntities[instrument_id] = searchEntity
                }

                //考虑到合约下架或合约列表中不存在，自选合约自建loop，反映到自选列表上让用户删除
                for ins in FileUtils.getOptional() {
                    if let ins_name = sSearchEntities[ins]?.instrument_name {
                        sOptionalQuotes[ins] = JSON(parseJSON: "{\"instrument_id\":\"\(ins)\", \"instrument_name\":\"\(ins_name)\"}")
                    }else{
                        sOptionalQuotes[ins] = JSON(parseJSON: "{\"instrument_id\":\"\(ins)\", \"instrument_name\":\"\(ins)\"}")
                    }
                }

                sQuotes.append(sortByUser(insList: sOptionalQuotes))
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

    func sortByUser(insList: [String: JSON]) -> [(key: String, value: JSON)] {
        return insList.sorted(by: {
            let optional = FileUtils.getOptional()
            if let index0 = optional.index(of: $0.key), let index1 = optional.index(of: $1.key){
                return index0 < index1
            }
            return $0.key < $1.key
        })
    }

    func sortByKey(insList: [String: JSON]) -> [(key: String, value: JSON)] {
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

    func resortOptional(fromIndex: Int, toIndex: Int) {
        var optional = FileUtils.getOptional()
        let ins = optional.remove(at: fromIndex)
        optional.insert(ins, at: toIndex)
        FileUtils.saveOptional(ins: optional)
        let quote = sQuotes[0].remove(at: fromIndex)
        sQuotes[0].insert(quote, at: toIndex)
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.RefreshOptionalInsListNotification), object: nil)
    }

    func saveOrRemoveIns(ins: String) {
        var optional = FileUtils.getOptional()
        if !optional.contains(ins) {
            optional.append(ins)
            FileUtils.saveOptional(ins: optional)
            var quote: JSON!
            if let ins_name = sSearchEntities[ins]?.instrument_name {
                quote = JSON(parseJSON: "{\"instrument_id\":\"\(ins)\", \"instrument_name\":\"\(ins_name)\"}")
            }else{
                quote = JSON(parseJSON: "{\"instrument_id\":\"\(ins)\", \"instrument_name\":\"\(ins)\"}")
            }
            sQuotes[0].append((key: ins, value: quote))
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
            guard let p_decs = search.p_decs else {return 0}
            return p_decs
        }
        return 0
    }

    //获取合约详情页的标题
    func getButtonTitle() -> String?{
        if sInstrumentId.contains("KQ") {
            if let underlying_symbol = sSearchEntities[sInstrumentId]?.underlying_symbol{
                return sSearchEntities[underlying_symbol]?.instrument_name
            }else {
                return sInstrumentId
            }
        }else {
            return sSearchEntities[sInstrumentId]?.instrument_name
        }
    }

    func parseRtnMD(rtnData: JSON) {
        do {
            let dataArray = rtnData[RtnMDConstants.data].arrayValue
            for dataJson in dataArray {
                try sRtnMD.merge(with: dataJson)
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    //清空账户
    func clearAccount() {
        sRtnBrokers = JSON.null
        sRtnTD = JSON.null
        sIsLogin = false
        sIsEmpty = false
        sUser_id = ""
        sRtnBrokers = JSON()
        sRtnTD = JSON()
    }

    func parseBrokers(brokers: JSON) {
        if !brokers.dictionaryValue.keys.contains(RtnTDConstants.brokers) {
            sIsLogin = false
            sIsEmpty = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.BrokerInfoEmptyNotification), object: nil)
            }
            return
        }
        sRtnBrokers = brokers
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.BrokerInfoNotification), object: nil)
        }

    }

    func parseRtnTD(transactionData: JSON) {
        do {
            let dataArray = transactionData[RtnTDConstants.data].arrayValue
            for dataJson in dataArray {
                let tradeJson = dataJson[RtnTDConstants.trade]
                if !tradeJson.isEmpty {
                    try sRtnTD.merge(with: tradeJson)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
                    }
                }

                if !sIsLogin{
                    let session = tradeJson[sUser_id][RtnTDConstants.session]
                    if !session.isEmpty {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name(CommonConstants.LoginNotification), object: nil)
                        }
                    }
                }

                let notifyArray = dataJson[RtnTDConstants.notify]
                if !notifyArray.isEmpty {
                    for (_, notifyJson) in notifyArray.dictionaryValue {
                        let content = notifyJson[NotifyConstants.content].stringValue
                        let type = notifyJson[NotifyConstants.type].stringValue
                        if "SETTLEMENT".elementsEqual(type){
                            DispatchQueue.main.async {
                                ConfirmSettlementView.getInstance().showConfirmSettlement(message: content)
                            }
                        }else{
                            DispatchQueue.main.async {
                                ToastUtils.showPositiveMessage(message: content)
                            }
                        }

                    }
                    
                }
            }

        } catch {
            print(error.localizedDescription)
        }
    }

}
