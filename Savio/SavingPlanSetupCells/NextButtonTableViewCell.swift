//
//  NextButtonTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 02/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class NextButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var btnVwBg: UIView!
    
    weak var tblView : UITableView?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    
   override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        nextButton.layer.cornerRadius = 5
        nextButton.backgroundColor = self.setUpColor()
        btnVwBg.backgroundColor = self.setUpShadowColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setUpColor()-> UIColor
    {
       return ColorCodes.colorForCode(colorDataDict["savPlanID"] as! Int)
    }

    func setUpShadowColor()-> UIColor
    {
      return ColorCodes.colorForShadow(colorDataDict["savPlanID"] as! Int)
    }

}
