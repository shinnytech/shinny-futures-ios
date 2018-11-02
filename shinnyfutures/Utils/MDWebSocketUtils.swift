//
//  MDWebSocketUtils.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/25.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Starscream

protocol MDWebSocketUtilsDelegate: NSObjectProtocol {
    //websocket接受文字信息
    func websocketDidReceiveMessage(socket: MDWebSocketUtils, text: String)

    //websocket接受Pong信息
    func websocketDidReceivePong(socket: MDWebSocketUtils, data: Data?)
}

class MDWebSocketUtils: NSObject, WebSocketDelegate, WebSocketPongDelegate {

    var socket: WebSocket!
    weak var mdWebSocketUtilsDelegate: MDWebSocketUtilsDelegate?

    //单例
    class func getInstance() -> MDWebSocketUtils {
        return manager
    }

    static let manager: MDWebSocketUtils = {
        return MDWebSocketUtils()
    }()

    // MARK: 连接服务器
    func connect(url: String, index: Int) -> Int{
        socket = WebSocket(url: URL(string: url)!)
        socket.delegate = self
        socket.pongDelegate = self
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String, let appBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as? String{
            socket.request.addValue("shinnyfutures-iOS \(appVersion)(\(appBuild))", forHTTPHeaderField: "User-Agent")
        }else{
            socket.request.addValue("shinnyfutures-iOS", forHTTPHeaderField: "User-Agent")
        }
        socket.connect()
        var indexNext = index + 1
        if indexNext == 7 {
            indexNext = 0
        }
        return indexNext
    }

    // MARK: 发送ping
    func ping() {
        socket.write(ping: Data())
    }

    // MARK: 断开连接
    func disconnect() {
        socket.disconnect()
    }

    // MARK: 行情订阅
    func sendSubscribeQuote(insList: String) {
        let subscribeQuote = "{\"aid\":\"subscribe_quote\",\"ins_list\":\"\(insList)\"}"
//        NSLog(subscribeQuote)
        socket.write(string: subscribeQuote)
    }

    // MARK: 获取合约信息
    func sendPeekMessage() {
        let peekMessage = "{\"aid\":\"peek_message\"}"
//        print(peekMessage)
        socket.write(string: peekMessage)
    }

    // MARK: 分时图
    func sendSetChart(insList: String) {
        let setChart = "{\"aid\":\"set_chart\",\"chart_id\":\"\(CommonConstants.CURRENT_DAY)\",\"ins_list\":\"\(insList)\",\"duration\":\"60000000000\",\"trading_day_start\":\"0\",\"trading_day_count\":\"86400000000000\"}"
//        NSLog(setChart)
        socket.write(string: setChart)
    }

    // MARK: 日线
    func sendSetChartDay(insList: String, viewWidth: Int) {
        let setChart = "{\"aid\":\"set_chart\",\"chart_id\":\"\(CommonConstants.KLINE_DAY)\",\"ins_list\":\"\(insList)\",\"duration\":\"86400000000000\",\"view_width\":\"\(viewWidth)\"}"
//        NSLog(setChart)
        socket.write(string: setChart)
    }

    // MARK: 小时线
    func sendSetChartHour(insList: String, viewWidth: Int) {
        let setChart = "{\"aid\":\"set_chart\",\"chart_id\":\"\(CommonConstants.KLINE_HOUR)\",\"ins_list\":\"\(insList)\",\"duration\":\"3600000000000\",\"view_width\":\"\(viewWidth)\"}"
//        NSLog(setChart)
        socket.write(string: setChart)
    }

    // MARK: 分钟线
    func sendSetChartMinute(insList: String, viewWidth: Int) {
        let setChart = "{\"aid\":\"set_chart\",\"chart_id\":\"\(CommonConstants.KLINE_MINUTE)\",\"ins_list\":\"\(insList)\",\"duration\":\"300000000000\",\"view_width\":\"\(viewWidth)\"}"
//        NSLog(setChart)
        socket.write(string: setChart)
    }

    // MARK: WebSocketDelegate
    func websocketDidConnect(socket: WebSocketClient) {
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        mdWebSocketUtilsDelegate?.websocketDidReceiveMessage(socket: self, text: text)
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    }

     // MARK: WebSocketPongDelegate
    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        mdWebSocketUtilsDelegate?.websocketDidReceivePong(socket: self, data: data)
    }

}
