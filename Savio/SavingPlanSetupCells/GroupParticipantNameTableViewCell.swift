//
//  GroupParticipantNameTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class GroupParticipantNameTableViewCell: UITableViewCell {

    @IBOutlet weak var deleteContactButton: UIButton!
    @IBOutlet weak var phoneOrEmailLabel: UILabel!
    @IBOutlet weak var ParticipantsNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
