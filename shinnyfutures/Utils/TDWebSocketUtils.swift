//
//  TDWebSocketUtils.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/25.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Starscream
import SwiftyJSON

protocol TDWebSocketUtilsDelegate: NSObjectProtocol {
    //websocet连接成功
    func websocketDidConnect(socket: TDWebSocketUtils)

    //websocket连接失败
    func websocketDidDisconnect(socket: TDWebSocketUtils, error: Error?)

    //websocket接受文字信息
    func websocketDidReceiveMessage(socket: TDWebSocketUtils, text: String)

    //websocket接受二进制信息
    func websocketDidReceiveData(socket: TDWebSocketUtils, data: Data)
}

class TDWebSocketUtils: NSObject, WebSocketDelegate {
    var socket: WebSocket!
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
        self.socket.delegate = self
        socket.request.addValue("shinnyfutures-iOS", forHTTPHeaderField: "User-Agent")
        self.socket.connect()
    }

    // MARK: 断开连接
    func disconnect() {
        socket.disconnect()
    }

    // MARK: 获取信息
    func sendPeekMessage() {
        let peekMessage = "{\"aid\":\"peek_message\"}"
//        NSLog(peekMessage)
        socket.write(string: peekMessage)
    }

    // MARK: 用户登录
    func sendReqLogin(bid: String, user_name: String, password: String) {
        let reqLogin = "{\"aid\":\"req_login\",\"bid\":\"\(bid)\",\"user_name\":\"\(user_name)\",\"password\":\"\(password)\"}"
//        NSLog(reqLogin)
        socket.write(string: reqLogin)
    }

    // MARK: 确认结算单
    func sendReqConfirmSettlement() {
        let confirmSettlement = "{\"aid\":\"confirm_settlement\"}"
//        NSLog(confirmSettlement)
        socket.write(string: confirmSettlement)
    }

    // MARK: 挂单
    func sendReqInsertOrder(exchange_id: String, instrument_id: String, direction: String, offset: String, volume: Int, priceType: String, price: Double) {
        let user_id = DataManager.getInstance().sUser_id
        let reqInsertOrder = "{\"aid\":\"insert_order\",\"user_id\":\"\(user_id)\",\"order_id\":\"\",\"exchange_id\":\"\(exchange_id)\",\"instrument_id\":\"\(instrument_id)\",\"direction\":\"\(direction)\",\"offset\":\"\(offset)\",\"volume\":\(volume),\"price_type\":\"\(priceType)\",\"limit_price\":\(price),\"volume_condition\":\"ANY\", \"time_condition\":\"GFD\"}"
        NSLog(reqInsertOrder)
        socket.write(string: reqInsertOrder)
    }

    // MARK: 撤单
    func sendReqCancelOrder(orderId: String) {
        let user_id = DataManager.getInstance().sUser_id
        let reqCancelOrder = "{\"aid\":\"cancel_order\",\"user_id\":\"\(user_id)\",\"order_id\":\"\(orderId)\"}"
//        NSLog(reqCancelOrder)
        socket.write(string: reqCancelOrder)
    }

    // MARK: 银期转帐
    func sendReqBankTransfer(future_account: String, future_password: String, bank_id: String, bank_password: String, currency: String, amount: Float) {
        let sendReqBankTransfer = "{\"aid\":\"req_transfer\",\"future_account\":\"\(future_account)\",\"future_password\":\"\(future_password)\",\"bank_id\":\"\(bank_id)\",\"bank_password\":\"\(bank_password)\",\"currency\":\"\(currency)\",\"amount\":\(amount)}"
//        NSLog(sendReqBankTransfer)
        socket.write(string: sendReqBankTransfer)
    }

    // MARK: WebSocketDelegate
    public func websocketDidConnect(socket: WebSocketClient) {
        tdWebSocketUtilsDelegate?.websocketDidConnect(socket: self)
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        tdWebSocketUtilsDelegate?.websocketDidDisconnect(socket: self, error: error)
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        tdWebSocketUtilsDelegate?.websocketDidReceiveMessage(socket: self, text: text)
    }

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        tdWebSocketUtilsDelegate?.websocketDidReceiveData(socket: self, data: data)
    }

}
