//
//  GroupProgressTableViewCell.swift
//  Savio
//
//  Created by Prashant on 07/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class GroupProgressTableViewCell: UITableViewCell {

    @IBOutlet weak var remainingAmountLabel: UILabel!
    @IBOutlet weak var savedAmountLabel: UILabel!
    @IBOutlet weak var cellTotalAmountLabel: UILabel!
    @IBOutlet weak var remainingProgress: KDCircularProgress!
    @IBOutlet weak var saveProgress: KDCircularProgress!
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var topVwHt: NSLayoutConstraint!
    @IBOutlet weak var makeImpulseSavingButton: UIButton!
    @IBOutlet weak var topShadowView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var payTypeLabel: UILabel!
    @IBOutlet weak var topSpaceProfilePic: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        saveProgress.startAngle = -90
        saveProgress.roundedCorners = true
        saveProgress.angle = 180
        
        remainingProgress.startAngle = -90
        remainingProgress.roundedCorners = true
        remainingProgress.angle = 180
        remainingProgress.clockwise = false
        
        userProfile.layer.borderWidth = 2.0
        userProfile.layer.borderColor = UIColor.blackColor().CGColor
        userProfile.layer.cornerRadius = userProfile.frame.size.height/2
        userProfile.layer.zPosition = 1
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
