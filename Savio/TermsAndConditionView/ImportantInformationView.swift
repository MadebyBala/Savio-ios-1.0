//
//  TermsAndConditionView.swift
//  PostalCodeVerification-Demo
//
//  Created by Maheshwari on 19/05/16.
//  Copyright © 2016 Maheshwari. All rights reserved.
//

import UIKit

extension NSObject {
    var theClassName: String {
        return NSStringFromClass(self.dynamicType)
    }
}

protocol ImportantInformationViewDelegate {
    func acceptPolicy(obj:ImportantInformationView)
}


class ImportantInformationView: UIView {
 
    @IBOutlet weak var btnVeBg: UIView!
    @IBOutlet weak var termsAndConditionTextView: UITextView!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    
    var isFromRegistration = false
    var delegate: ImportantInformationViewDelegate?
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        btnVeBg.layer.cornerRadius = 5.0
        //set the content offset for textview so it,will begin at point(0,0)
        termsAndConditionTextView.contentOffset = CGPointMake(0, 0)
      }
    
    //Go to the previous ViewController
    @IBAction func gotItButtonPressed(sender: AnyObject) {
  
        if(isFromRegistration == false)
        {
         self.removeFromSuperview()
        }
        delegate?.acceptPolicy(self)
    }

}
