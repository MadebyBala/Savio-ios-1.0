//
//  SavingCategoryTableViewCell.swift
//  Savio
//
//  Created by Prashant on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SavingCategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var lblHeader: UILabel?
    @IBOutlet weak var lblDetail: UILabel?
    @IBOutlet weak var imgView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
