//
//  OfferTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 06/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class OfferTableViewCell: UITableViewCell {
    
    @IBOutlet weak var offerDetailsButton: UIButton!
    
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var detailOfferLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var detailOfferLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var offerDetailLabel: UILabel!
    @IBOutlet weak var offerTitleLabel: UILabel!
    @IBOutlet weak var offerImageView: UIImageView!
    weak var tblView : UITableView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        offerView.layer.cornerRadius = 5
        offerView.layer.masksToBounds = true
        offerView.clipsToBounds = true
        offerDetailsButton.setImage(UIImage(named:"detail-arrow-down.png"), forState: .Normal)
        offerDetailsButton.imageEdgeInsets = UIEdgeInsetsMake(0, (offerDetailsButton.titleLabel?.frame.size.width)!, 0, -(((offerDetailsButton.titleLabel?.frame.size.width)!+30)))
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
