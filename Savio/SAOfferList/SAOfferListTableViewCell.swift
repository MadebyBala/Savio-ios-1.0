//
//  SAOfferListTableViewCell.swift
//  Savio
//
//  Created by Prashant on 06/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit



class SAOfferListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var suggestedHt: NSLayoutConstraint!
     var colorDataDict : Dictionary<String,AnyObject> = [:]
    
     @IBOutlet weak var lblOfferSummary: UILabel?
     @IBOutlet weak var lblOfferTitle: UILabel?
    @IBOutlet weak var lblOfferDiscount: UILabel?
    @IBOutlet weak var lblProductOffer: UILabel?
    @IBOutlet weak var offerImage: UIImageView?

    @IBOutlet weak var btnAddOffer: UIButton?
    @IBOutlet weak var btnOfferDetail: UIButton?
   

    @IBOutlet weak var lblHT: NSLayoutConstraint!

    @IBOutlet weak var vwBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
         colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        lblOfferDiscount?.textColor = self.setUpColor()
        btnAddOffer?.backgroundColor = self.setUpColor()
        btnOfferDetail?.setTitleColor(self.setUpColor(), forState: UIControlState.Normal)
        btnAddOffer!.layer.cornerRadius = 5
        btnOfferDetail?.tintColor = self.setUpColor()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func setUpShadowColor()-> UIColor
    {
       return ColorCodes.colorForShadow(colorDataDict["savPlanID"] as! Int)
    }
    
    func setUpColor()-> UIColor
    {
       return ColorCodes.colorForCode(colorDataDict["savPlanID"] as! Int)    }

}
