//
//  DataManager.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/19.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import Foundation

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

    //////////////////////////////////////////////////////////////
    var sRtnMD = RtnMD()
    var sRtnTD = RtnTD()
    var sBrokers = [String]()
    var sPreInsList = ""
    var sInstrumentId = ""
    var sPositionDirection = ""
    var isBackground = false
    var sIsLogin = false
    var sIsEmpty = false
    var sUser_id = ""
    var sAppVersion = ""
    var sAppBuild = ""
    var sPriceType = CommonConstants.COUNTERPARTY_PRICE
    //进入登陆页的来源
    var sToLoginTarget = ""
    //进入合约详情页的来源
    var sToQuoteTarget = ""

    func parseLatestFile(latestData: Data) {
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
        do {
            guard let latestJson = try JSONSerialization.jsonObject(with: latestData, options: []) as? [String: Any] else { return }
            for (instrument_id, value) in latestJson {
                let subJson = value as! [String: Any]
                let classN = subJson["class"] as? String ?? ""
                if !"FUTURE_CONT".elementsEqual(classN) && !"FUTURE".elementsEqual(classN) && !"FUTURE_COMBINE".elementsEqual(classN) && !"FUTURE_OPTION".elementsEqual(classN){continue}
                let ins_name = subJson["ins_name"] as? String ?? ""
                let ins_id = subJson["ins_id"] as? String ?? ""
                let expired = subJson["expired"] as? Bool ?? false
                let exchange_id = subJson["exchange_id"] as? String ?? ""
                let price_tick = (subJson["price_tick"] as? NSNumber)?.stringValue ?? ""
                let price_decs = subJson["price_decs"] as? Int ?? 0
                let volume_multiple = (subJson["volume_multiple"] as? NSNumber)?.stringValue ?? ""
                let sort_key = subJson["sort_key"] as? Int ?? 0
                let py = subJson["py"] as? String ?? ""
                let pre_volume = subJson["pre_volume"] as? Int ?? 0
                let product_id = subJson["product_id"] as? String ?? ""

                let searchEntity = Search(ins_id: ins_id, product_id: product_id, instrument_id: instrument_id, instrument_name: ins_name, exchange_name: "", exchange_id: exchange_id, py: py, p_tick: price_tick, p_decs: price_decs, vm: volume_multiple, sort_key: sort_key, margin: 0, underlying_symbol: "", pre_volume: pre_volume, leg1_symbol: "", leg2_symbol: "")

                if "FUTURE_CONT".elementsEqual(classN){
                    let underlying_symbol = subJson["underlying_symbol"] as? String ?? ""
                    if "".elementsEqual(underlying_symbol){continue}
                    searchEntity.underlying_symbol = underlying_symbol
                    guard let subJsonFuture = latestJson[underlying_symbol] as? [String: Any] else {continue}
                    let pre_volume = subJsonFuture["pre_volume"] as? Int ?? 0
                    let ins_id = subJsonFuture["ins_id"] as? String ?? ""
                    let product_id = subJsonFuture["product_id"] as? String ?? ""
                    searchEntity.pre_volume = pre_volume
                    searchEntity.ins_id = ins_id
                    searchEntity.product_id = product_id
                    let quote = Quote()
                    quote.instrument_id = underlying_symbol
                    sMainQuotes[underlying_symbol] = quote
                    sMainInsListNameNav[ins_name.replacingOccurrences(of: "主连", with: "")] = underlying_symbol
                }

                if "FUTURE".elementsEqual(classN){
                    guard let product_short_name = subJson["product_short_name"] as? String else {continue}
                    let quote = Quote()
                    quote.instrument_id = instrument_id
                    switch exchange_id {
                    case "SHFE":
                        if !expired{
                            sShangqiQuotes[instrument_id] = quote
                            sShangqiInsListNameNav[product_short_name] = instrument_id
                        }
                        searchEntity.exchange_name = "上海期货交易所"
                    case "CZCE":
                        if !expired{
                            sZhengzhouQuotes[instrument_id] = quote
                            sZhengzhouInsListNameNav[product_short_name] = instrument_id
                        }
                        searchEntity.exchange_name = "郑州商品交易所"
                    case "DCE":
                        if !expired {
                            sDalianQuotes[instrument_id] = quote
                            sDalianInsListNameNav[product_short_name] = instrument_id
                        }
                        searchEntity.exchange_name = "大连商品交易所"
                    case "CFFEX":
                        if !expired {
                            sZhongjinQuotes[instrument_id] = quote
                            sZhongjinInsListNameNav[product_short_name] = instrument_id
                        }
                        searchEntity.exchange_name = "中国金融期货交易所"
                    case "INE":
                        if !expired{
                            sNengyuanQuotes[instrument_id] = quote
                            sNengyuanInsListNameNav[product_short_name] = instrument_id
                        }
                        searchEntity.exchange_name = "上海国际能源交易中心"
                    default:
                        continue
                    }

                }

                if "FUTURE_COMBINE".elementsEqual(classN){
                    guard let leg1_symbol = subJson["leg1_symbol"] as? String else {continue}
                    guard let leg2_symbol = subJson["leg2_symbol"] as? String else {continue}
                    guard let subJsonFuture = latestJson[leg1_symbol] as? [String: Any] else {continue}
                    guard let product_short_name = subJsonFuture["product_short_name"] as? String else {continue}
                    let py = subJsonFuture["py"] as? String ?? ""
                    searchEntity.py = py
                    searchEntity.leg1_symbol = leg1_symbol
                    searchEntity.leg2_symbol = leg2_symbol
                    let quote = Quote()
                    quote.instrument_id = instrument_id
                    switch exchange_id {
                    case "CZCE":
                        if !expired{
                            sZhengzhouzeheQuotes[instrument_id] = quote
                            sZhengzhouzeheInsListNameNav[product_short_name] = instrument_id
                        }
                        searchEntity.exchange_name = "郑州商品交易所"
                    case "DCE":
                        if !expired{
                            sDalianzuheQuotes[instrument_id] = quote
                            sDalianzuheInsListNameNav[product_short_name] = instrument_id
                        }
                        searchEntity.exchange_name = "大连商品交易所"
                    default:
                        continue
                    }
                }
                sSearchEntities[instrument_id] = searchEntity
            }

            //考虑到合约下架或合约列表中不存在，自选合约自建loop，反映到自选列表上让用户删除
            for ins in FileUtils.getOptional() {
                let quote = Quote()
                quote.instrument_id = ins
                sOptionalQuotes[ins] = quote
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
        NSLog("解析结束")
    }

    func sortByUser(insList: [String: Quote]) -> [(key: String, value: Quote)] {
        return insList.sorted(by: {
            let optional = FileUtils.getOptional()
            if let index0 = optional.index(of: $0.key), let index1 = optional.index(of: $1.key){
                return index0 < index1
            }
            return $0.key < $1.key
        })
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

    func resortOptional(fromIndex: Int, toIndex: Int) {
        var optional = FileUtils.getOptional()
        if fromIndex >= optional.count || toIndex >= optional.count{return}
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
            let quote = Quote()
            quote.instrument_id = ins
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

    //计算组合部分行情
    func calculateCombineQuotePart(quote: Quote) -> Quote {
        let instrument_id = "\(quote.instrument_id ?? "")"
        guard let search = sSearchEntities[instrument_id] else {return quote}
        guard let leg1_symbol = search.leg1_symbol else {return quote}
        guard let leg2_symbol = search.leg2_symbol else {return quote}
        guard let quote_leg1 = sRtnMD.quotes[leg1_symbol] else {return quote}
        guard let quote_leg2 = sRtnMD.quotes[leg2_symbol] else {return quote}
        let last_leg1 = "\(quote_leg1.last_price ?? "")"
        let last_leg2 = "\(quote_leg2.last_price ?? "")"
        if let last_leg1 = Float(last_leg1), let last_leg2 = Float(last_leg2){
            let last = last_leg1 - last_leg2
            quote.last_price = last
        }
        let ask_price1_leg1 = "\(quote_leg1.ask_price1 ?? "")"
        let bid_price1_leg2 = "\(quote_leg2.bid_price1 ?? "")"
        if let ask_price1_leg1 = Float(ask_price1_leg1), let bid_price1_leg2 = Float(bid_price1_leg2){
            let ask_price1 = ask_price1_leg1 - bid_price1_leg2
            quote.ask_price1 = ask_price1
        }
        let ask_volume1_leg1 = "\(quote_leg1.ask_volume1 ?? "")"
        let bid_volume1_leg2 = "\(quote_leg2.bid_volume1 ?? "")"
        if let ask_volume1_leg1 = Int(ask_volume1_leg1), let bid_volume1_leg2 = Int(bid_volume1_leg2){
            let ask_volume1 = min(ask_volume1_leg1, bid_volume1_leg2)
            quote.ask_volume1 = ask_volume1
        }
        let bid_price1_leg1 = "\(quote_leg1.bid_price1 ?? "")"
        let ask_price1_leg2 = "\(quote_leg2.ask_price1 ?? "")"
        if let bid_price1_leg1 = Float(bid_price1_leg1), let ask_price1_leg2 = Float(ask_price1_leg2){
            let bid_price1 = bid_price1_leg1 - ask_price1_leg2
            quote.bid_price1 = bid_price1
        }
        let bid_volume1_leg1 = "\(quote_leg1.bid_volume1 ?? "")"
        let ask_volume1_leg2 = "\(quote_leg2.ask_volume1 ?? "")"
        if let bid_volume1_leg1 = Int(bid_volume1_leg1), let ask_volume1_leg2 = Int(ask_volume1_leg2){
            let bid_volume1 = min(bid_volume1_leg1, ask_volume1_leg2)
            quote.bid_volume1 = bid_volume1
        }
        let pre_settlement_leg1 = "\(quote_leg1.pre_settlement ?? "")"
        let pre_settlement_leg2 = "\(quote_leg2.pre_settlement ?? "")"
        if let pre_settlement_leg1 = Float(pre_settlement_leg1), let pre_settlement_leg2 = Float(pre_settlement_leg2){
            let pre_settlement = pre_settlement_leg1 - pre_settlement_leg2
            quote.pre_settlement = pre_settlement
        }
        return quote
    }

    //计算组合完整行情
    func calculateCombineQuoteFull(quote: Quote) -> Quote {
        let instrument_id = "\(quote.instrument_id ?? "")"
        guard let search = sSearchEntities[instrument_id] else {return quote}
        guard let leg1_symbol = search.leg1_symbol else {return quote}
        guard let leg2_symbol = search.leg2_symbol else {return quote}
        guard let quote_leg1 = sRtnMD.quotes[leg1_symbol] else {return quote}
        guard let quote_leg2 = sRtnMD.quotes[leg2_symbol] else {return quote}
        let last_leg1 = "\(quote_leg1.last_price ?? "")"
        let last_leg2 = "\(quote_leg2.last_price ?? "")"
        if let last_leg1 = Float(last_leg1), let last_leg2 = Float(last_leg2){
            let last = last_leg1 - last_leg2
            quote.last_price = last
        }
        let ask_price1_leg1 = "\(quote_leg1.ask_price1 ?? "")"
        let bid_price1_leg2 = "\(quote_leg2.bid_price1 ?? "")"
        if let ask_price1_leg1 = Float(ask_price1_leg1), let bid_price1_leg2 = Float(bid_price1_leg2){
            let ask_price1 = ask_price1_leg1 - bid_price1_leg2
            quote.ask_price1 = ask_price1
        }
        let ask_volume1_leg1 = "\(quote_leg1.ask_volume1 ?? "")"
        let bid_volume1_leg2 = "\(quote_leg2.bid_volume1 ?? "")"
        if let ask_volume1_leg1 = Int(ask_volume1_leg1), let bid_volume1_leg2 = Int(bid_volume1_leg2){
            let ask_volume1 = min(ask_volume1_leg1, bid_volume1_leg2)
            quote.ask_volume1 = ask_volume1
        }
        let bid_price1_leg1 = "\(quote_leg1.bid_price1 ?? "")"
        let ask_price1_leg2 = "\(quote_leg2.ask_price1 ?? "")"
        if let bid_price1_leg1 = Float(bid_price1_leg1), let ask_price1_leg2 = Float(ask_price1_leg2){
            let bid_price1 = bid_price1_leg1 - ask_price1_leg2
            quote.bid_price1 = bid_price1
        }
        let bid_volume1_leg1 = "\(quote_leg1.bid_volume1 ?? "")"
        let ask_volume1_leg2 = "\(quote_leg2.ask_volume1 ?? "")"
        if let bid_volume1_leg1 = Int(bid_volume1_leg1), let ask_volume1_leg2 = Int(ask_volume1_leg2){
            let bid_volume1 = min(bid_volume1_leg1, ask_volume1_leg2)
            quote.bid_volume1 = bid_volume1
        }
        let open_leg1 = "\(quote_leg1.open ?? "")"
        let open_leg2 = "\(quote_leg2.open ?? "")"
        if let open_leg1 = Float(open_leg1), let open_leg2 = Float(open_leg2){
            let open = open_leg1 - open_leg2
            quote.open = open
        }
        let highest_leg1 = "\(quote_leg1.highest ?? "")"
        let highest_leg2 = "\(quote_leg2.highest ?? "")"
        if let highest_leg1 = Float(highest_leg1), let highest_leg2 = Float(highest_leg2){
            let highest = highest_leg1 - highest_leg2
            quote.highest = highest
        }
        let lowest_leg1 = "\(quote_leg1.lowest ?? "")"
        let lowest_leg2 = "\(quote_leg2.lowest ?? "")"
        if let lowest_leg1 = Float(lowest_leg1), let lowest_leg2 = Float(lowest_leg2){
            let lowest = lowest_leg1 - lowest_leg2
            quote.lowest = lowest
        }
        let average_leg1 = "\(quote_leg1.average ?? "")"
        let average_leg2 = "\(quote_leg2.average ?? "")"
        if let average_leg1 = Float(average_leg1), let average_leg2 = Float(average_leg2){
            let average = average_leg1 - average_leg2
            quote.average = average
        }
        let pre_close_leg1 = "\(quote_leg1.pre_close ?? "")"
        let pre_close_leg2 = "\(quote_leg2.pre_close ?? "")"
        if let pre_close_leg1 = Float(pre_close_leg1), let pre_close_leg2 = Float(pre_close_leg2){
            let pre_close = pre_close_leg1 - pre_close_leg2
            quote.pre_close = pre_close
        }
        let pre_settlement_leg1 = "\(quote_leg1.pre_settlement ?? "")"
        let pre_settlement_leg2 = "\(quote_leg2.pre_settlement ?? "")"
        if let pre_settlement_leg1 = Float(pre_settlement_leg1), let pre_settlement_leg2 = Float(pre_settlement_leg2){
            let pre_settlement = pre_settlement_leg1 - pre_settlement_leg2
            quote.pre_settlement = pre_settlement
        }
        let settlement_leg1 = "\(quote_leg1.settlement ?? "")"
        let settlement_leg2 = "\(quote_leg2.settlement ?? "")"
        if let settlement_leg1 = Float(settlement_leg1), let settlement_leg2 = Float(settlement_leg2){
            let settlement = settlement_leg1 - settlement_leg2
            quote.settlement = settlement
        }
        return quote
    }

    func parseRtnMD(rtnData: [String: Any]) {
        guard let dataArray = rtnData[RtnMDConstants.data] as? [Any] else {return}
        for dataJson in dataArray {
            guard let data = dataJson as? [String: Any] else {continue}
            for (key, value) in data{
                switch key{
                case RtnMDConstants.quotes:
                    let quotes = value as? [String: Any]
                    parseQuotes(quotes: quotes)
                case RtnMDConstants.charts:
                    let charts = value as? [String: Any]
                    parseCharts(charts: charts)
                case RtnMDConstants.klines:
                    let klines = value as? [String: Any]
                    parseKlines(klines: klines)
                case RtnMDConstants.ins_list:
                    let ins_list = value as? String
                    sRtnMD.ins_list = ins_list ?? ""
                case RtnMDConstants.mdhis_more_data:
                    sRtnMD.mdhis_more_data = value as? Bool ?? false
                default:
                    break
                }
            }
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
        }

    }

    fileprivate func parseKlines(klines: [String: Any]?){
        guard let klines = klines else {return}
        for (instrument_id, kline) in klines {
            var kline_local = sRtnMD.klines[instrument_id]
            if kline_local == nil{
                kline_local = [String: Kline]()
            }
            guard let kline = kline as? [String: Any] else {continue}
            for (duration, kline_data) in kline{
                var kline_data_local = kline_local?[duration]
                if kline_data_local == nil{
                    kline_data_local = Kline()
                }
                guard let kline_data = kline_data as? [String: Any] else {continue}
                for (key, value) in kline_data{
                    SwiftTryCatch.try({
                        switch key {
                        case KlineConstants.data:
                            if let datas = value as? [String: Any] {
                                for (key, data) in datas {
                                    guard let data = data as? [String: Any] else {continue}
                                    var data_local = kline_data_local?.datas[key]
                                    if data_local == nil{
                                        data_local = Kline.Data()
                                    }
                                    for (key, value) in data {
                                        data_local?.setValue(value, forKey: key)
                                    }
                                    kline_data_local?.datas[key] = data_local

                                }
                            }
                        case KlineConstants.binding:
                            print(value)
                        default:
                            kline_data_local?.setValue(value, forKey: key)
                        }
                    }, catch: { (error) in
                    }, finally: {
                    })
                }
                kline_local?[duration] = kline_data_local
            }
            sRtnMD.klines[instrument_id] = kline_local
        }
    }

    fileprivate func parseCharts(charts: [String: Any]?){
        guard let charts = charts else {return}
        for (instrument_id, chart) in charts {
            var chart_local = sRtnMD.charts[instrument_id]
            if chart_local == nil{
                chart_local = Chart()
            }
            guard let chart = chart as? [String: Any] else {continue}
            for (key, value) in chart{
                SwiftTryCatch.try({
                    if ChartConstants.state.elementsEqual(key){
                        if chart_local?.state == nil{
                            chart_local?.state = Chart.State()
                        }
                        if let state = value as? [String: Any] {
                            for (key, value) in state{
                                chart_local?.state?.setValue(value, forKey: key)
                            }
                        }
                    }else{
                        chart_local?.setValue(value, forKey: key)
                    }
                }, catch: { (error) in
                }, finally: {
                })

            }
            sRtnMD.charts[instrument_id] = chart_local
        }
    }

    fileprivate func parseQuotes(quotes: [String: Any]?){
        guard let quotes = quotes else {return}
        for (instrument_id, quote) in quotes {
            var quote_local = sRtnMD.quotes[instrument_id]
            if quote_local == nil{
                quote_local = Quote()
            }
            guard let quote = quote as? [String: Any] else {continue}
            for (key, value) in quote{
                SwiftTryCatch.try({
                    quote_local?.setValue(value, forKey: key)
                }, catch: { (error) in
                }, finally: {
                })
            }
            sRtnMD.quotes[instrument_id] = quote_local
        }
    }

    //清空账户
    func clearAccount() {
        sIsLogin = false
        sIsEmpty = false
        sUser_id = ""
    }

    func parseBrokers(rtnData: [String: Any]) {
        if !rtnData.keys.contains(RtnTDConstants.brokers) {
            sIsLogin = false
            sIsEmpty = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.BrokerInfoEmptyNotification), object: nil)
            }
            return
        }
        sBrokers = rtnData[RtnTDConstants.brokers] as? [String] ?? [""]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.BrokerInfoNotification), object: nil)
        }

    }

    func parseRtnTD(rtnData: [String: Any]) {
        guard let dataArray = rtnData[RtnTDConstants.data] as? [Any] else {return}
        for data in dataArray {
            guard let data = data as? [String: Any] else {continue}
            for (key, value) in data {
                guard let data = value as? [String: Any] else {continue}
                switch key {
                case RtnTDConstants.trade:
                    parseTrade(trade: data)
                    break
                case RtnTDConstants.notify:
                    parseNotify(notify: data)
                    break
                default:
                    break
                }
            }
        }
    }

    fileprivate func parseNotify(notify: [String: Any]?){
        guard let notify = notify else {return}
        for (_, value) in notify{
            guard let value = value as? [String: Any] else {continue}
            let content = "\(value[NotifyConstants.content] ?? "")"
            let type = "\(value[NotifyConstants.type] ?? "")"
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

    fileprivate func parseTrade(trade: [String: Any]?){
        guard let trade = trade else {return}
        for (key_user, user) in trade{
            guard let user = user as? [String: Any] else {continue}
            var user_local = sRtnTD.users[key_user]
            if user_local == nil{
                user_local = User()
            }
            for (key_value, value) in user {
                switch key_value {
                case RtnTDConstants.accounts:
                    let accounts = value as? [String: Any]
                    parseAccounts(accounts: accounts, user_local: user_local)
                    break
                case RtnTDConstants.positions:
                    let positions = value as? [String: Any]
                    parsePositions(positions: positions, user_local: user_local)
                    break
                case RtnTDConstants.orders:
                    let orders = value as? [String: Any]
                    parseOrders(orders: orders, user_local: user_local)
                    break
                case RtnTDConstants.trades:
                    let trades = value as? [String: Any]
                    parseTrades(trades: trades, user_local: user_local)
                    break
                case RtnTDConstants.transfers:
                    let transfers = value as? [String: Any]
                    parseTransfers(transfers: transfers, user_local: user_local)
                    break
                case RtnTDConstants.banks:
                    let banks = value as? [String: Any]
                    parseBanks(banks: banks, user_local: user_local)
                    break
                case RtnTDConstants.session:
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(CommonConstants.LoginNotification), object: nil)
                    }
                    guard let session = value as? [String: Any] else {break}
                    guard let user_id = session["user_id"] as? String else {break}
                    sUser_id = user_id
                    break
                default:
                    break
                }
            }
            sRtnTD.users[key_user] = user_local
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
        }

    }

    fileprivate func parseAccounts(accounts: [String: Any]?, user_local: User?){
        guard let accounts = accounts else {return}
        for (key, value) in accounts {
            guard let account = value as? [String: Any] else {continue}
            var account_local = user_local?.accounts[key]
            if account_local == nil{
                account_local = Account()
            }
            for (key, value) in account{
                SwiftTryCatch.try({
                    account_local?.setValue(value, forKey: key)
                }, catch: { (error) in
                }, finally: {
                })
            }
            user_local?.accounts[key] = account_local
        }
    }

    fileprivate func parsePositions(positions: [String: Any]?, user_local: User?){
        guard let positions = positions else {return}
        for (key, value) in positions {
            guard let position = value as? [String: Any] else {continue}
            var position_local = user_local?.positions[key]
            if position_local == nil{
                position_local = Position()
            }
            for (key, value) in position{
                SwiftTryCatch.try({
                    position_local?.setValue(value, forKey: key)
                }, catch: { (error) in
                }, finally: {
                })
            }
            user_local?.positions[key] = position_local
        }
    }

    fileprivate func parseOrders(orders: [String: Any]?, user_local: User?){
        guard let orders = orders else {return}
        for (key, value) in orders {
            guard let order = value as? [String: Any] else {continue}
            var order_local = user_local?.orders[key]
            if order_local == nil{
                order_local = Order()
            }
            for (key, value) in order{
                SwiftTryCatch.try({
                    order_local?.setValue(value, forKey: key)
                }, catch: { (error) in
                }, finally: {
                })
            }
            user_local?.orders[key] = order_local
        }
    }

    fileprivate func parseTransfers(transfers: [String: Any]?, user_local: User?){
        guard let transfers = transfers else {return}
        for (key, value) in transfers {
            guard let transfer = value as? [String: Any] else {continue}
            var transfer_local = user_local?.transfers[key]
            if transfer_local == nil{
                transfer_local = Transfer()
            }
            for (key, value) in transfer{
                SwiftTryCatch.try({
                    transfer_local?.setValue(value, forKey: key)
                }, catch: { (error) in
                }, finally: {
                })
            }
            user_local?.transfers[key] = transfer_local
        }
    }

    fileprivate func parseBanks(banks: [String: Any]?, user_local: User?){
        guard let banks = banks else {return}
        for (key, value) in banks {
            guard let bank = value as? [String: Any] else {continue}
            var bank_local = user_local?.banks[key]
            if bank_local == nil{
                bank_local = Bank()
            }
            for (key, value) in bank{
                SwiftTryCatch.try({
                    bank_local?.setValue(value, forKey: key)
                }, catch: { (error) in
                }, finally: {
                })
            }
            user_local?.banks[key] = bank_local
        }
    }

    fileprivate func parseTrades(trades: [String: Any]?, user_local: User?){
        guard let trades = trades else {return}
        for (key, value) in trades {
            guard let trade = value as? [String: Any] else {continue}
            var trade_local = user_local?.trades[key]
            if trade_local == nil{
                trade_local = Trade()
            }
            for (key, value) in trade{
                SwiftTryCatch.try({
                    trade_local?.setValue(value, forKey: key)
                }, catch: { (error) in
                }, finally: {
                })
            }
            user_local?.trades[key] = trade_local
        }
    }
}
