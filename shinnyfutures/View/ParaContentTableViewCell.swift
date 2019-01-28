//
//  ParaContentTableViewCell.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/15.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import UIKit

class ParaContentTableViewCell: UITableViewCell {

    @IBOutlet weak var key: UILabel!
    
    @IBOutlet weak var value: UITextField!{
        didSet {
            value?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        }
    }

    @IBAction func beginEdit(_ sender: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.value.selectAll(nil)
        }
    }

    @objc func doneButtonTappedForMyNumericTextField() {
        value.resignFirstResponder()
    }

}

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
