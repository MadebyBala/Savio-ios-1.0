//
//  ContactTableViewCell.swift
//  Savio
//
//  Created by Prashant on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var headerLbl : UILabel?
    @IBOutlet weak var detailLable : UILabel?
    @IBOutlet weak var inviteBtn : UIButton?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
