//
//  QuotePageViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/26.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class QuotePageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: Properties
    var currentIndex = 1
    var mainViewController: MainViewController!
    let manager = DataManager.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        if FileUtils.getOptional().isEmpty {
            currentIndex = 1
        }else{
            currentIndex = 0
        }
        if let startingViewController = contentViewController(at: currentIndex) {
            setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)
        }
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPage), name: Notification.Name(CommonConstants.LatestFileParsedNotification), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        mainViewController = self.parent as? MainViewController
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: UIPageViewControllerDataSource
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return manager.sQuotes.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let view = viewController as? QuoteTableViewController {
            let index = view.index - 1
            return contentViewController(at: index)
        }
        return contentViewController(at: 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as? QuoteTableViewController)?.index else {return contentViewController(at: 1)}
        index += 1
        return contentViewController(at: index)
    }

    //滑动切换合约
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? QuoteTableViewController {
                let index = contentViewController.index
                currentIndex = index
                mainViewController.button.setTitle(CommonConstants.titleArray[index], for: .normal)
                mainViewController.loadQuoteNavigation(index: index)
                contentViewController.sendSubscribeQuotes()
            }
        }
    }

    //导航栏切换合约
    func forwardPage(index: Int) {
        currentIndex = index
        if let nextViewController = contentViewController(at: currentIndex) {
            nextViewController.sendSubscribeQuotes()
            setViewControllers([nextViewController], direction: .forward, animated: false, completion: nil)
        }
    }

    func backwardPage(index: Int) {
        currentIndex = index
        if let nextViewController = contentViewController(at: currentIndex) {
            nextViewController.sendSubscribeQuotes()
            setViewControllers([nextViewController], direction: .reverse, animated: false, completion: nil)
        }
    }

    //页面产生
    func contentViewController(at index: Int) -> QuoteTableViewController? {
        if index < 0 || index >= manager.sQuotes.count {
            return nil
        }
        // create a new view comtroller and pass suitable data
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.shinnytech.futures"))
        if let contentViewController = storyboard.instantiateViewController(withIdentifier: CommonConstants.QuoteTableViewController) as? QuoteTableViewController {
            contentViewController.index = index
            return contentViewController
        }
        return nil
    }

    @objc private func refreshPage() {
        if manager.sQuotes[0].isEmpty {
            currentIndex = 1
        }else{
            currentIndex = 0
        }
        if let startingViewController = contentViewController(at: currentIndex) {
            setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)
        }
    }
}
