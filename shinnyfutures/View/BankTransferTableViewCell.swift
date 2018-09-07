//
//  BankTransferTableViewCell.swift
//  shinnyfutures
//
//  Created by chenli on 2018/8/30.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import UIKit

class BankTransferTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var datetime: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var result: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
