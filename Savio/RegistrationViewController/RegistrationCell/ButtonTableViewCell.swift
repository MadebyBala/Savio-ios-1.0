//
//  ButtonTableViewCell.swift
//  Savio
//
//  Created by Prashant on 19/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
protocol ButtonCellDelegate {
    func buttonOnCellClicked(sender:UIButton)
}
class ButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btn: UIButton?
    weak var tblView: UITableView?
    var delegate: ButtonCellDelegate?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btn?.layer.cornerRadius = 3.0
        btn?.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  @IBAction func btnClicked(sender:UIButton){
        delegate?.buttonOnCellClicked(sender)
    }
    
}
