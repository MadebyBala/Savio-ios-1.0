//
//  linkButtonTableViewCell.swift
//  Savio
//
//  Created by Prashant on 19/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol linkButtonTableViewCellDelegate {
    
    func linkButtonClicked(sender:UIButton)
}

class linkButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btnLink: UIButton?
    weak var tblView: UITableView?
    var delegate: linkButtonTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickedOnLinkButton(sender:UIButton){
        delegate?.linkButtonClicked(sender);
    }
    
}
