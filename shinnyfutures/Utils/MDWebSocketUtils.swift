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

    var socket: WebSocket?
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
        guard let socket_ = self.socket else {return 0}
        socket_.delegate = self
        socket_.pongDelegate = self
        let appVersion = DataManager.getInstance().sAppVersion
        let appBuild = DataManager.getInstance().sAppBuild
        socket_.request.addValue("shinnyfutures-iOS \(appVersion)(\(appBuild))", forHTTPHeaderField: "User-Agent")
        socket_.connect()
        var indexNext = index + 1
        if indexNext == 7 {
            indexNext = 0
        }
        return indexNext
    }

    // MARK: 发送ping
    func ping() {
        guard let socket_ = self.socket else{return}
        socket_.write(ping: Data())
    }

    //MARK: 断线重连
    func reconnectMD(url: String, index: Int) -> Int {
        disconnect()
        return connect(url:url, index: index)
    }

    // MARK: 断开连接
    func disconnect() {
        guard let socket_ = self.socket else {return}
        socket_.disconnect()
    }

    // MARK: 行情订阅
    func sendSubscribeQuote(insList: String) {
        guard let socket_ = self.socket else {return}
        let subscribeQuote = ReqSubscribeQuote(aid: "subscribe_quote", ins_list: insList)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(subscribeQuote)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
            socket_.write(string: json)
            DataManager.getInstance().sQuotesText = json
        } catch {
            print(error)
        }
    }

    // MARK: 获取合约信息
    func sendPeekMessage() {
        guard let socket_ = self.socket else {return}
        let peekMessage = ReqPeekMessage(aid: "peek_message")
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(peekMessage)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
            socket_.write(string: json)
        } catch {
            print(error)
        }
    }

    // MARK: 分时图
    func sendSetChart(insList: String) {
        guard let socket_ = self.socket else {return}
        let duration = 60000000000 as Int64
        let trading_day_start = 0
        let trading_day_count = 86400000000000 as Int64
        let setChart = ReqSetChart(aid: "set_chart", chart_id: CommonConstants.CHART_ID, ins_list: insList, duration: duration, trading_day_start: trading_day_start, trading_day_count: trading_day_count)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(setChart)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
            socket_.write(string: json)
            DataManager.getInstance().sChartsText = json
        } catch {
            print(error)
        }
    }

    // MARK: k线
    func sendSetChartKline(insList: String, klineType: String, viewWidth: Int) {
        guard let socket_ = self.socket else {return}
        guard let duration = Int64(klineType)else {return}
        let setChart = ReqSetChartKline(aid: "set_chart", chart_id: CommonConstants.CHART_ID, ins_list: insList, duration: duration, view_width: viewWidth)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(setChart)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
            socket_.write(string: json)
            DataManager.getInstance().sChartsText = json
        } catch {
            print(error)
        }
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
