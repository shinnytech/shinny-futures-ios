//
//  BrokerTableViewCell.swift
//  shinnyfutures
//
//  Created by chenli on 2019/1/3.
//  Copyright © 2019 shinnytech. All rights reserved.
//

import UIKit

class BrokerTableViewCell: UITableViewCell {

    @IBOutlet weak var broker: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
