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
    func connect() {
        self.socket = WebSocket(url: URL(string: CommonConstants.TRANSACTION_URL)!)
        self.socket.delegate = self
        self.socket.connect()
    }

    // MARK: 断开连接
    func disconnect() {
        socket.disconnect()
    }

    // MARK: 用户登录
    func sendReqLogin(bid: String, user_name: String, password: String) {
        let reqLogin = "{\"aid\":\"req_login\",\"bid\":\"\(bid)\",\"user_name\":\"\(user_name)\",\"password\":\"\(password)\"}"
        NSLog(reqLogin)
        socket.write(string: reqLogin)
    }

    // MARK: 确认结算单
    func sendReqConfirmSettlement(reqId: String, msg: String) {
        let confirmSettlement = "{\"aid\":\"MobileConfirmSettlement\",\"req_id\":\"\(reqId)\",\"msg\":\"\(msg)\"}"
        NSLog(confirmSettlement)
        socket.write(string: confirmSettlement)
    }

    // MARK: 挂单
    func sendReqInsertOrder(order_id: String, exchange_id: String, instrument_id: String, direction: String, offset: String, volume: Int, priceType: String, price: Double) {
        let reqInsertOrder = "{\"aid\":\"insert_order\",\"order_id\":\"\(order_id)\",\"exchange_id\":\"\(exchange_id)\",\"instrument_id\":\"\(instrument_id)\",\"direction\":\"\(direction)\",\"offset\":\"\(offset)\",\"volume\":\(volume),\"price_type\":\"\(priceType)\",\"limit_price\":\(price)}"
        NSLog(reqInsertOrder)
        socket.write(string: reqInsertOrder)
    }

    // MARK: 撤单
    func sendReqCancelOrder(orderId: String) {
        let reqCancelOrder = "{\"aid\":\"cancel_order\",\"order_id\":\"\(orderId)\"}"
        NSLog(reqCancelOrder)
        socket.write(string: reqCancelOrder)
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
