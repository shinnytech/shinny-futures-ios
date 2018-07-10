//
//  FeedbackViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/3/28.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

class FeedbackViewController: UIViewController, WKUIDelegate {

    // MARK: Properties
    var webView: WKWebView!

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    // MARK: Action
    @IBAction func back(_ sender: UIBarButtonItem) {
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: CommonConstants.REDMINE_URL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    deinit {
        print("反馈页销毁")
    }

}
