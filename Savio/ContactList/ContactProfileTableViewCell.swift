//
//  ContactProfileTableViewCell.swift
//  Savio
//
//  Created by Prashant on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class ContactProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var personImage: UIImageView?
    @IBOutlet weak var name: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        personImage?.layer.cornerRadius = (personImage?.frame.size.width)!/2.0
        personImage?.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
