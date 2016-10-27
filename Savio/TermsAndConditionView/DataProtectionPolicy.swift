//
//  DataProtectionPolicy.swift
//  Savio
//
//  Created by Maheshwari on 19/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

//protocol DataProtectionPolicyDelegate {
//    
//}

class DataProtectionPolicy: UIView {
    
//    var delegate: DataProtectionPolicyDelegate?

    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var dataPolicyAndTermsTextView: UITextView!
    
    @IBOutlet weak var lblHeading: UILabel!
    
    @IBOutlet weak var btnVeBg: UIView!
    override func drawRect(rect: CGRect) {
         //set the shadow color for back button
//        backButton.layer.shadowColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        btnVeBg.layer.cornerRadius = 5.0
        //set the content offset for textview so it,will begin at point(0,0)
        dataPolicyAndTermsTextView.contentOffset = CGPointMake(0, 0)
    }
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.removeFromSuperview()
    }
}
