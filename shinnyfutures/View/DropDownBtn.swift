//
//  DropDownBtn.swift
//  shinnyfutures
//
//  Created by chenli on 2018/8/31.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import UIKit

protocol DropDownProtocol: class {
    func dropDownPressed(string: String)
}

class DropDownBtn: UIButton, DropDownProtocol {

    func dropDownPressed(string: String) {
        self.setTitle(string, for: .normal)
        self.dismissDropDown()
    }

    var dropView: DropDownView!

    var height = NSLayoutConstraint()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.darkGray

        dropView = DropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func didMoveToSuperview() {
        if let superview = self.superview {
            superview.addSubview(dropView)
            superview.bringSubview(toFront: dropView)
            dropView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            height = dropView.heightAnchor.constraint(equalToConstant: 0)
        }
    }

    deinit {
        dropView.removeFromSuperview()
        print("DropDownBtn销毁")
    }

    var isOpen = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {

            isOpen = true

            NSLayoutConstraint.deactivate([self.height])

            if (self.dropView.tableView?.contentSize.height)! > UIScreen.main.bounds.height / 4 * 3 {
                self.height.constant = UIScreen.main.bounds.height / 4 * 3
            } else {
                self.height.constant = (self.dropView.tableView?.contentSize.height)!
            }

            NSLayoutConstraint.activate([self.height])

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.layoutIfNeeded()
                self.dropView.center.y += self.dropView.frame.height / 2
            }, completion: nil)

        } else {
            isOpen = false

            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.center.y -= self.dropView.frame.height / 2
                self.dropView.layoutIfNeeded()
            }, completion: nil)

        }
    }

    func dismissDropDown() {
        isOpen = false
        NSLayoutConstraint.deactivate([self.height])
        self.height.constant = 0
        NSLayoutConstraint.activate([self.height])
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.dropView.center.y -= self.dropView.frame.height / 2
            self.dropView.layoutIfNeeded()
        }, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


class DropDownView: UIView, UITableViewDelegate, UITableViewDataSource {

    //期货公司
    var selected_index = ""

    var dropDownOptions = [String]()

    weak var tableView: UITableView?

    weak var delegate: DropDownProtocol?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let tableView = UITableView()
        tableView.backgroundColor = UIColor.darkGray
        self.backgroundColor = UIColor.darkGray

        tableView.delegate = self
        tableView.dataSource = self

        tableView.translatesAutoresizingMaskIntoConstraints = false

        // make tableview look better in ipad
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()

        self.addSubview(tableView)
        self.tableView = tableView

        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    }

    deinit {
        self.tableView?.removeFromSuperview()
        print("DropDownView销毁")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //全屏分割线
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        cell.backgroundColor = UIColor.darkGray
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.dropDownPressed(string: dropDownOptions[indexPath.row])
        self.tableView?.deselectRow(at: indexPath, animated: true)
        self.selected_index = dropDownOptions[indexPath.row]
    }

}
