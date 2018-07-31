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
    weak var quoteViewController: QuoteViewController?
    lazy var subViewControllers: [UIViewController] = {
        return [
            UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: CommonConstants.HandicapViewController) as! HandicapViewController,
            UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: CommonConstants.PositionTableViewController) as! PositionTableViewController,
            UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: CommonConstants.OrderTableViewController) as! OrderTableViewController,
            UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures")).instantiateViewController(withIdentifier: CommonConstants.TransactionViewController) as! TransactionViewController]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        setViewControllers([subViewControllers[currentIndex]], direction: .forward, animated: false, completion: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        quoteViewController = self.parent as? QuoteViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UIPageViewControllerDataSource
    //滑动切换合约
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            quoteViewController?.controlTransactionVisibility(index: currentIndex)
        }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index: Int = subViewControllers.index(of: viewController) ?? 0
        if index <= 0 {
            return nil
        }
        currentIndex = index - 1
        return subViewControllers[currentIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index: Int = subViewControllers.index(of: viewController) ?? 0
        if index >= subViewControllers.count - 1 {
            return nil
        }
        currentIndex = index + 1
        return subViewControllers[currentIndex]
    }

}
