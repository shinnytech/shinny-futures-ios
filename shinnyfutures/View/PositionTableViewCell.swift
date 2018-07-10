//
//  PositionTableViewCell.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/4.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class PositionTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var direction: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var available: UILabel!
    @IBOutlet weak var openPrice: UILabel!
    @IBOutlet weak var profit: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
