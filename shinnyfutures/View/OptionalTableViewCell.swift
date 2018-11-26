//
//  DragOptionalTableViewCell.swift
//  shinnyfutures
//
//  Created by chenli on 2018/11/23.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import UIKit

protocol OptionalTableViewCellDelegate {

    func didCutButton(_ tag: Int)

    func didTopButton(_ tag: Int)

}

class OptionalTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var cut: UIButton!
    @IBOutlet weak var instrumentId: UILabel!
    @IBOutlet weak var top: UIButton!
    var delegate: OptionalTableViewCellDelegate?

    //MARK: Actions
    @IBAction func remove(_ sender: UIButton) {
        delegate?.didCutButton(self.tag)
    }

    @IBAction func top(_ sender: UIButton) {
        delegate?.didTopButton(self.tag)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if (editing) {

            for view in subviews as [UIView] {
                if type(of: view).description().contains("Reorder") {
                    for subview in view.subviews as! [UIImageView] {
                        if subview.isKind(of: UIImageView.classForCoder()){
                            subview.image = UIImage(named: "drag")
                            var Rect: CGRect = subview.frame
                            Rect.size.height = 18
                            Rect.size.width = 18
                            subview.frame = Rect
                            subview.layoutIfNeeded()
                        }
                    }
                }
            }
        }
    }
}
