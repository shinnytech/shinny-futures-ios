//
//  KlineDurationTableViewCell.swift
//  shinnyfutures
//
//  Created by chenli on 2019/2/12.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import UIKit

protocol KlineDurationTableViewCellDelegate {

    func didCutButton(_ tag: Int)

    func didTopButton(_ tag: Int)

}

class KlineDurationTableViewCell: UITableViewCell {
    @IBOutlet weak var cut: UIButton!
    @IBOutlet weak var top: UIButton!
    @IBOutlet weak var duration: UILabel!
    var delegate: KlineDurationTableViewCellDelegate?

    @IBAction func remove(_ sender: UIButton) {
        delegate?.didCutButton(self.tag)
    }

    @IBAction func top(_ sender: UIButton) {
        delegate?.didTopButton(self.tag)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if (editing) {

            for view in subviews as [UIView] {
                if type(of: view).description().contains("Reorder") {
                    for subview in view.subviews as! [UIImageView] {
                        if subview.isKind(of: UIImageView.classForCoder()){
                            subview.image = UIImage(named: "drag_white")
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
