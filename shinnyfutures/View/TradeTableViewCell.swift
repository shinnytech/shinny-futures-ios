//
//  TradeTableViewCell.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/3.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class TradeTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var offset: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var time: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
