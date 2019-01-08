//
//  AppDelegate.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/26.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    fileprivate func createMenuView() {

        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftTableViewController") as! LeftTableViewController
        let rightViewController = storyboard.instantiateViewController(withIdentifier: "RightTableViewController") as! RightTableViewController

        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        leftViewController.mainViewController = mainViewController
        rightViewController.mainViewController = mainViewController

        let slideMenuController = ExSlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController, rightMenuViewController: rightViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = mainViewController
        self.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Siren.shared.checkVersion(checkType: .immediately)
        if let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
            statusBarView.backgroundColor = CommonConstants.QUOTE_PAGE_HEADER
        }

        self.createMenuView()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DataManager.getInstance().isBackground = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Siren.shared.checkVersion(checkType: .immediately)
        DataManager.getInstance().isBackground = false
        TDWebSocketUtils.getInstance().sendPeekMessage()
        MDWebSocketUtils.getInstance().sendPeekMessage()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Siren.shared.checkVersion(checkType: .daily)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

