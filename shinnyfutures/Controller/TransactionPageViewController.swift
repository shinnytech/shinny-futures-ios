//
//  TransactionPageViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/10.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class TransactionPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: Properties
    var currentIndex = 0
    var identifiers = [CommonConstants.HandicapViewController, CommonConstants.PositionTableViewController, CommonConstants.OrderTableViewController, CommonConstants.TransactionViewController]
    weak var quoteViewController: QuoteViewController?
    lazy var subViewControllers: [UIViewController] = {
        if DataManager.getInstance().sIsEmpty{
            return [
                UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: identifiers[0]) as! HandicapViewController]
        }else{
            return [
                UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: identifiers[0]) as! HandicapViewController,
                UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: identifiers[1]) as! PositionTableViewController,
                UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: identifiers[2]) as! OrderTableViewController,
                UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: identifiers[3]) as! TransactionViewController]
            
        }

    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        //删除点击页面左右边缘切换页面效果
        self.view.removeGestureRecognizer(self.gestureRecognizers[1])
        setViewControllers([subViewControllers[currentIndex]], direction: .forward, animated: false, completion: nil)

        //滑动到持仓页进行判断h是否需要登录
        NotificationCenter.default.addObserver(self, selector: #selector(switchToPosition), name: Notification.Name(CommonConstants.SwitchToPositionNotification), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        quoteViewController = self.parent as? QuoteViewController
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: UIPageViewControllerDataSource
    //滑动切换合约
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first {
                let index = identifiers.index(of: contentViewController.restorationIdentifier!) ?? 0
                quoteViewController?.controlTransactionVisibility(index: index)
            }
        }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index: Int = subViewControllers.index(of: viewController) ?? 0
        if index <= 0 {return nil}
        if index > subViewControllers.count {return nil}
        index = index - 1
        //滑动到持仓页进行判断h是否需要登录
        if !DataManager.getInstance().sIsLogin {
            switch index {
            case 1:
                quoteViewController?.position(UIButton())
                return nil
            default:
                break
            }
        }
        currentIndex = index
        return subViewControllers[currentIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index: Int = subViewControllers.index(of: viewController) ?? 0
        if index >= subViewControllers.count - 1 {return nil}
        index = index + 1
        //滑动到持仓页进行判断h是否需要登录
        if !DataManager.getInstance().sIsLogin {
            switch index {
            case 1:
                quoteViewController?.position(UIButton())
                return nil
            default:
                break
            }
        }
        currentIndex = index
        return subViewControllers[currentIndex]
    }


    //滑动到持仓页进行判断h是否需要登录
    @objc func switchToPosition() {
        quoteViewController?.switchTransactionPage(index: 1)
    }


}
