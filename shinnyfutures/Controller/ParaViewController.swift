//
//  ParaViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/15.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import UIKit

class ParaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var nav: UITableView!
    @IBOutlet weak var content: UITableView!
    var datas_nav = ["MA"]
    var datas_content = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tap)

        nav.cellLayoutMarginsFollowReadableWidth = true
        content.cellLayoutMarginsFollowReadableWidth = true
        // Do any additional setup after loading the view.

        nav.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableViewScrollPosition(rawValue: 0)!)
        datas_content = UserDefaults.standard.array(forKey: CommonConstants.CONFIG_SETTING_PARA_MA) as! [Int]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == nav {
            return datas_nav.count
        }
        return datas_content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == nav{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParaNavTableViewCell", for: indexPath) as! ParaNavTableViewCell
            let data = datas_nav[indexPath.row]
            cell.nav.text = data
            let bgColorView = UIView()
            bgColorView.backgroundColor = CommonConstants.PARA_NAV_SELECTED
            cell.selectedBackgroundView = bgColorView
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParaContentTableViewCell", for: indexPath) as! ParaContentTableViewCell

            let data = datas_content[indexPath.row]
            cell.key.text = "参数N\(indexPath.row + 1)"
            cell.value.text = "\(data)"
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == nav {
            return 44
        }
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == content{
            tableView.deselectRow(at: indexPath, animated: false)
        }
        if tableView == nav{
            switch indexPath.row{
            case 0:
                datas_content = UserDefaults.standard.array(forKey: CommonConstants.CONFIG_SETTING_PARA_MA) as! [Int]
                break
            case 1:
                break
            case 2:
                break
            default:
                break
            }
            content.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == content {
            return 100
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        if tableView == content {
            let stackView = UIStackView()
            stackView.distribution = .fillEqually
            stackView.axis = .vertical
            stackView.spacing = 10

            let save = UILabel()
            save.textColor = UIColor.white
            save.text = "保存修改"
            save.textAlignment = .center
            save.backgroundColor = CommonConstants.PARA_CONTENT_FOOTER
            let tapSave = UITapGestureRecognizer(target: self, action: #selector(tapSaveAction))
            save.isUserInteractionEnabled = true
            save.addGestureRecognizer(tapSave)
            let reset = UILabel()
            reset.textColor = UIColor.white
            reset.text = "恢复默认"
            reset.textAlignment = .center
            reset.backgroundColor = CommonConstants.PARA_CONTENT_FOOTER
            let tapReset = UITapGestureRecognizer(target: self, action: #selector(tapResetAction))
            reset.isUserInteractionEnabled = true
            reset.addGestureRecognizer(tapReset)

            stackView.addArrangedSubview(save)
            stackView.addArrangedSubview(reset)
            footerView.addSubview(stackView)

            stackView.translatesAutoresizingMaskIntoConstraints = false
            let leadingConstraint = NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: footerView, attribute: .leading, multiplier: 1, constant: 5)
            let trailingConstraint = NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: footerView, attribute: .trailing, multiplier: 1, constant: -5)
            let topConstraint = NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: footerView, attribute: .top, multiplier: 1, constant: 5)
            let bottomConstraint = NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: footerView, attribute: .bottom, multiplier: 1, constant: -5)
            footerView.addConstraints([leadingConstraint, topConstraint, trailingConstraint, bottomConstraint])
            return footerView
        }
        return footerView
    }

    @objc func tapSaveAction(){

        var datas = [Int]()
        for index in Array(0..<datas_content.count) {
            if let cell = content.cellForRow(at: IndexPath(row: index, section: 0)) as? ParaContentTableViewCell{
                if let data = Int(cell.value.text ?? "") {
                    datas.append(data)
                }else {
                    ToastUtils.showNegativeMessage(message: "输入参数错误")
                    return
                }
            }
        }

        if nav.indexPathForSelectedRow?.row == 0{
            UserDefaults.standard.set(datas, forKey: CommonConstants.CONFIG_SETTING_PARA_MA)
        }

        datas_content = datas
        content.reloadData()
        ToastUtils.showPositiveMessage(message: "参数已保存")
    }

    @objc func tapResetAction(){
        if nav.indexPathForSelectedRow?.row == 0{
            datas_content = CommonConstants.PARA_MA
            UserDefaults.standard.set(datas_content, forKey: CommonConstants.CONFIG_SETTING_PARA_MA)
        }
        content.reloadData()
        ToastUtils.showPositiveMessage(message: "恢复默认")
    }

    //Calls this function when the tap is recognized.
//    @objc func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }

}
