//
//  GruupCalculationTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class GroupCalculationTableViewCell: UITableViewCell {

    @IBOutlet weak var percentageCalculationLabel: UILabel!
    @IBOutlet weak var calculationLabel: UILabel!
    @IBOutlet weak var BGContentView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        BGContentView.layer.cornerRadius = 5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}