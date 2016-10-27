//
//  ErrorTableViewCell.swift
//  Savio
//
//  Created by Prashant on 20/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class ErrorTableViewCell: UITableViewCell {

    @IBOutlet weak var lblError: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblError?.textColor = UIColor.redColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
