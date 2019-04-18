//
//  TDWebSocketUtils.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/25.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Starscream

protocol TDWebSocketUtilsDelegate: NSObjectProtocol {

    //websocket接受文字信息
    func websocketDidReceiveMessage(socket: TDWebSocketUtils, text: String)

    //websocket接受Pong信息
    func websocketDidReceivePong(socket: TDWebSocketUtils, data: Data?)
}

class TDWebSocketUtils: NSObject, WebSocketDelegate, WebSocketPongDelegate {
    var socket: WebSocket?
    weak var tdWebSocketUtilsDelegate: TDWebSocketUtilsDelegate?

    //单例
    class func getInstance() -> TDWebSocketUtils {
        return manager
    }

    static let manager: TDWebSocketUtils = {
        return TDWebSocketUtils()
    }()

    // MARK: 连接服务器
    func connect(url: String) {
        self.socket = WebSocket(url: URL(string: url)!)
        guard let socket_ = self.socket else {return}
        socket_.delegate = self
        socket_.pongDelegate = self
        let appVersion = DataManager.getInstance().sAppVersion
        let appBuild = DataManager.getInstance().sAppBuild
        socket_.request.addValue("shinnyfutures-iOS \(appVersion)(\(appBuild))", forHTTPHeaderField: "User-Agent")
        socket_.connect()
    }

    // MARK: 发送ping
    func ping() {
        guard let socket_ = self.socket else {return}
        socket_.write(ping: Data())
    }

    //MARK: 断线重连
    func reconnectTD(url: String) {
        disconnect()
        connect(url: url)
    }

    // MARK: 断开连接
    func disconnect() {
        guard let socket_ = self.socket else {return}
        socket_.disconnect()
    }

    // MARK: 获取信息
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

    // MARK: 用户登录
    func sendReqLogin(bid: String, user_name: String, password: String) {
        guard let socket_ = self.socket else {return}
        let reqLogin = ReqLogin(aid: "req_login", bid: bid, user_name: user_name, password: password)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(reqLogin)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
            socket_.write(string: json)
            DataManager.getInstance().insertRecordsToDB(log: json)
        } catch {
            print(error)
        }
    }

    // MARK: 确认结算单
    func sendReqConfirmSettlement() {
        guard let socket_ = self.socket else {return}
        let confirmSettlement = ReqPeekMessage(aid: "confirm_settlement")
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(confirmSettlement)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
            socket_.write(string: json)
            DataManager.getInstance().insertRecordsToDB(log: json)
        } catch {
            print(error)
        }
    }

    // MARK: 挂单
    func sendReqInsertOrder(exchange_id: String, instrument_id: String, direction: String, offset: String, volume: Int, price_type: String, limit_price: Double) {
        guard let socket_ = self.socket else {return}
        let user_id = DataManager.getInstance().sUser_id
        let reqInsertOrder = ReqInsertOrder(aid: "insert_order", user_id: user_id, order_id: "", exchange_id: exchange_id, instrument_id: instrument_id, direction: direction, offset: offset, volume: volume, price_type: price_type, limit_price: limit_price, volume_condition: "ANY", time_condition: "GFD")
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(reqInsertOrder)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
            socket_.write(string: json)
            DataManager.getInstance().insertRecordsToDB(log: json)
        } catch {
            print(error)
        }
    }

    // MARK: 撤单
    func sendReqCancelOrder(order_id: String) {
        guard let socket_ = self.socket else {return}
        let user_id = DataManager.getInstance().sUser_id
        let reqCancelOrder = ReqCancelOrder(aid: "cancel_order", user_id: user_id, order_id: order_id)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(reqCancelOrder)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
            socket_.write(string: json)
            DataManager.getInstance().insertRecordsToDB(log: json)
        } catch {
            print(error)
        }
    }

    // MARK: 银期转帐
    func sendReqBankTransfer(future_account: String, future_password: String, bank_id: String, bank_password: String, currency: String, amount: Float) {
        guard let socket_ = self.socket else {return}
        let sendReqBankTransfer = ReqBankTransfer(aid: "req_transfer", future_account: future_account, future_password: future_password, bank_id: bank_id, bank_password: bank_password, currency: currency, amount: amount)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(sendReqBankTransfer)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
            socket_.write(string: json)
            DataManager.getInstance().insertRecordsToDB(log: json)
        } catch {
            print(error)
        }
    }

    //MARK: 修改密码
    func sendReqPassword(new_password: String, old_password: String) {
        guard let socket_ = self.socket else {return}
        let reqPassword = ReqPassword(aid: "change_password", new_password: new_password, old_password: old_password)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(reqPassword)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
            socket_.write(string: json)
            DataManager.getInstance().insertRecordsToDB(log: json)
        } catch {
            print(error)
        }
    }

    // MARK: WebSocketDelegate
    public func websocketDidConnect(socket: WebSocketClient) {
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        tdWebSocketUtilsDelegate?.websocketDidReceiveMessage(socket: self, text: text)
    }

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    }

    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        tdWebSocketUtilsDelegate?.websocketDidReceivePong(socket: self, data: data)
    }

}
