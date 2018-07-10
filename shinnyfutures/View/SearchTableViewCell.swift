//
//  SearchTableViewCell.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/2.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var instrumentName: UILabel!
    @IBOutlet weak var instrumentId: UILabel!
    @IBOutlet weak var exchangeName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
