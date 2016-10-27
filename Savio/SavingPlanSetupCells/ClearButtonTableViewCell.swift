//
//  ClearButtonTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 02/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class ClearButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var clearButton: UIButton!
       weak var tblView : UITableView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
