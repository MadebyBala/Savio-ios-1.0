//
//  SwitchTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 27/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol UISwitchTableViewDelegate{
    func getStateOfSwitchClicked(state: String)
}
class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var otpSwitch: UISwitch!
    @IBOutlet weak var otpLabel: UILabel!
    var delegate: UISwitchTableViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func otpSwitchChanged(sender: UISwitch) {
        if( sender.on)
        {
            otpLabel.text = "OTP will be send"
            delegate?.getStateOfSwitchClicked("OTP will be send")
        }
        else {
            otpLabel.text = "OTP will not be send"
            delegate?.getStateOfSwitchClicked("OTP will not be send")
        }
    }
}
