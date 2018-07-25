//
//  AppDelegate.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/26.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import SwiftyJSON
import Siren
import Bugly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MDWebSocketUtilsDelegate, TDWebSocketUtilsDelegate {

    var window: UIWindow?
    let mdWebSocketUtils = MDWebSocketUtils.getInstance()
    let transactionWebSocketUtils = TDWebSocketUtils.getInstance()
    var isMDClose = false
    var isTDClose = false

    func websocketDidConnect(socket: TDWebSocketUtils) {
        NSLog("交易服务器连接成功～")
        if isTDClose {
            ToastUtils.showPositiveMessage(message: "交易服务器连接成功～")
            isTDClose = false
        }
    }

    func websocketDidDisconnect(socket: TDWebSocketUtils, error: Error?) {
        NSLog("交易服务器连接断开，正在重连～")
        isTDClose = true
        ToastUtils.showNegativeMessage(message: "交易服务器连接断开，正在重连～")
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 10, execute: {
            self.transactionWebSocketUtils.connect()
        })
    }

    func websocketDidReceiveMessage(socket: TDWebSocketUtils, text: String) {
        DispatchQueue.global().async {
            let json = JSON(parseJSON: text)
            let aid = json["aid"].stringValue
            switch aid {
            case "rtn_brokers":
                DataManager.getInstance().parseBrokers(brokers: json)
            case "rtn_data":
                DataManager.getInstance().parseRtnTD(transactionData: json)
            default:
                return
            }
        }
    }

    func websocketDidReceiveData(socket: TDWebSocketUtils, data: Data) {
        NSLog("交易服务器接收二进制数据")
    }

    ////////////////////////////////////////////////////////////////////////////////

    func websocketDidConnect(socket: MDWebSocketUtils) {
        NSLog("行情服务器连接成功～")
        if isMDClose {
            ToastUtils.showPositiveMessage(message: "行情服务器连接成功～")
            isMDClose = false
        }
    }

    func websocketDidDisconnect(socket: MDWebSocketUtils, error: Error?) {
        NSLog("行情服务器连接断开，正在重连～")
        isMDClose = true
        ToastUtils.showNegativeMessage(message: "行情服务器连接断开，正在重连～")
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 10, execute: {
            self.mdWebSocketUtils.connect()
        })
    }

    func websocketDidReceiveData(socket: MDWebSocketUtils, data: Data) {
        NSLog("行情服务器接受二进制数据")
    }

    func websocketDidReceiveMessage(socket: MDWebSocketUtils, text: String) {
        DispatchQueue.global().async {
            let json = JSON(parseJSON: text)
            let aid = json["aid"].stringValue
            switch aid {
            case "rsp_login":
                socket.sendSubscribeQuote(insList: DataManager.getInstance().sQuotes[1].sorted(by: {$0.key < $1.key}).map {$0.key}[0..<CommonConstants.MAX_SUBSCRIBE_QUOTES].joined(separator: ","))
            case "rtn_data":
                DataManager.getInstance().parseRtnMD(rtnData: json)
            default:
                return
            }
            socket.sendPeekMessage()
        }
    }

    ////////////////////////////////////////////////////////////////////////////////

    func sessionSimpleDownload(urlString: String, fileName: String) {
        //下载地址
        let url = URL(string: urlString)
        //请求
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        let handler = { (location: URL?, _: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error.debugDescription)
                return
            }
            do {
                let documentsURL = try
                    FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let savedURL = documentsURL.appendingPathComponent(fileName)
                if FileManager.default.fileExists(atPath: savedURL.path) {
                    try FileManager.default.removeItem(at: savedURL)
                }
                try FileManager.default.copyItem(at: location!, to: savedURL)
                DataManager.getInstance().parseLatestFile()
                NSLog("合约列表解析完毕")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(CommonConstants.LatestFileParsedNotification), object: nil)
                }
                self.mdWebSocketUtils.connect()
                self.transactionWebSocketUtils.connect()
            } catch {
                print ("file error: \(error)")
            }
        }
        //下载任务
        let downloadTask = session.downloadTask(with: request, completionHandler: handler)
        //使用resume方法启动任务
        downloadTask.resume()
    }

    ////////////////////////////////////////////////////////////////////////////////

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().tintColor = UIColor.white
        UIApplication.shared.statusBarStyle = .lightContent
        self.mdWebSocketUtils.mdWebSocketUtilsDelegate = self
        self.transactionWebSocketUtils.tdWebSocketUtilsDelegate = self
        sessionSimpleDownload(urlString: CommonConstants.LATEST_FILE_URL, fileName: "latest.json")
        Bugly.start(withAppId: "0027757d18")
        Siren.shared.checkVersion(checkType: .immediately)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Siren.shared.checkVersion(checkType: .immediately)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Siren.shared.checkVersion(checkType: .daily)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
