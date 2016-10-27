//
//  FindAddressTableViewCell.swift
//  Savio
//
//  Created by Prashant on 19/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
protocol FindAddressCellDelegate {
    func getAddressButtonClicked(findAddrCell: FindAddressTableViewCell)
    func getTextFOrPostCode(findAddrCell: FindAddressTableViewCell)
}
class FindAddressTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var tfPostCode: UITextField?
    @IBOutlet weak var btnPostCode: UIButton?
    
    weak var tblView: UITableView?
    var delegate: FindAddressCellDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tfPostCode?.layer.cornerRadius = 2.0
        tfPostCode?.layer.masksToBounds = true
        tfPostCode?.layer.borderWidth=1.0
        tfPostCode?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue:120/256.0, alpha: 1.0).CGColor;
        tfPostCode?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center

        btnPostCode?.layer.cornerRadius = 2.0
        btnPostCode?.layer.masksToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    
    @objc func keyboardWasShown(notification: NSNotification){
        //do stuff
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize?.height)!, 0.0)
        tblView?.contentInset = contentInsets
        tblView?.scrollIndicatorInsets = contentInsets
        
        var aRect = tfPostCode?.frame
        aRect?.size.height = (aRect?.size.height)! - (kbSize?.height)!
        if !CGRectContainsPoint(aRect!, self.frame.origin) {
            tblView?.scrollRectToVisible(self.frame, animated: true)
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //do stuff
        
        let contentInsets: UIEdgeInsets =  UIEdgeInsetsZero;
        tblView?.contentInset = contentInsets;
        tblView?.scrollIndicatorInsets = contentInsets;
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        textField.textColor = UIColor.blackColor()
        self.registerForKeyboardNotifications()
        return true
    }
    func textFieldDidEndEditing(textField: UITextField){
        self.removeKeyboardNotification()
    }
    //    func textFieldShouldEndEditing(textField: UITextField) -> Bool{
    //        self.removeKeyboardNotification()
    //        textField.resignFirstResponder()
    //        return true
    //    }
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        delegate?.getTextFOrPostCode(self)
        return true
    }
    @IBAction func clickOnAddressButton(sender:UIButton){
        tfPostCode?.resignFirstResponder()
        delegate?.getAddressButtonClicked(self)
    }

    
}
