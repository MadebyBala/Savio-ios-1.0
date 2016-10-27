//
//  SavingPlanDatePickerTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SavingPlanDatePickerCellDelegate {
    func datePickerText(date:Int,dateStr:String)
    
}
class SavingPlanDatePickerTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var BGContentView: UIView!
    @IBOutlet weak var calenderImageView: UIImageView!
    @IBOutlet weak var datePickerTextField: UITextField!
    
    weak var tblView : UITableView?
    weak var view : UIScrollView?
    var customToolBar : UIToolbar?
    var datePickerView:UIDatePicker = UIDatePicker()
    var savingPlanDatePickerDelegate : SavingPlanDatePickerCellDelegate?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    var lastOffset: CGPoint = CGPointZero
    var dateString = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE dd/MM/yyyy"
        datePickerTextField.text = dateFormatter.stringFromDate(NSDate())
        
        let dateComponents = NSDateComponents()
        let calender = NSCalendar.currentCalendar()
        dateComponents.day = 7
        let newDate = calender.dateByAddingComponents(dateComponents, toDate: NSDate(), options:NSCalendarOptions(rawValue: 0))
        self.datePickerView.minimumDate = newDate
        
        // cornerRadius changes
        datePickerTextField.layer.cornerRadius = 5
        BGContentView.layer.cornerRadius = 5
        customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBarButtonPressed"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar!.items = [cancelButton,flexibleSpace,acceptButton]
        datePickerTextField.delegate = self
        datePickerTextField.inputView = datePickerView
        datePickerTextField.inputAccessoryView = customToolBar
        calenderImageView.image = self.setUpImage()
        
    }
    
    func setUpImage()-> UIImage
    {
        var imageName = ""
        if(colorDataDict["savPlanID"] as! Int == 85) {
            imageName = "group-save-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 86) {
            imageName = "wedding-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 87) {
            imageName = "baby-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 88) {
            imageName = "holiday-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 89) {
            imageName = "ride-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 90) {
            imageName = "home-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 91) {
            imageName = "gadget-calendar.png"
        }
        else {
            imageName = "generic-calendar.png"
        }
        return UIImage(named:imageName)!
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func doneBarButtonPressed(){
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE dd/MM/yyyy"
        let pickrDate = dateFormatter.stringFromDate(datePickerView.date)
        datePickerTextField.text = pickrDate
        datePickerTextField.textColor = UIColor.whiteColor()
        
        let timeDifference : NSTimeInterval = datePickerView.date.timeIntervalSinceDate(datePickerView.minimumDate!)
        savingPlanDatePickerDelegate?.datePickerText(Int(timeDifference/3600),dateStr: datePickerTextField.text!)
        
        datePickerTextField.resignFirstResponder()
    }
    
    func cancelBarButtonPressed(){
        datePickerTextField.resignFirstResponder()
        
    }
    func changeDatePickerViewDate()
    {
        let dateComponents = NSDateComponents()
        let calender = NSCalendar.currentCalendar()
        if(dateString == "date"){
            dateComponents.month = 1
        }else {
            dateComponents.day = 7
        }
        let newDate = calender.dateByAddingComponents(dateComponents, toDate: NSDate(), options:NSCalendarOptions(rawValue: 0))
        self.datePickerView.minimumDate = newDate
    }
    
    
    @objc func datePickerWasShown(notification: NSNotification){
        //do stuff
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize?.height)!, 0.0)
        tblView?.contentInset = contentInsets
        tblView?.scrollIndicatorInsets = contentInsets
        var aRect = datePickerTextField?.frame
        aRect?.size.height = (aRect?.size.height)! - (kbSize?.height)!
        if !CGRectContainsPoint(aRect!, self.frame.origin) {
            tblView?.scrollRectToVisible(self.frame, animated: true)
        }
    }
    
    @objc func datePickerWillBeHidden(notification: NSNotification){
        //do stuff
        let contentInsets: UIEdgeInsets =  UIEdgeInsetsZero;
        tblView?.contentInset = contentInsets;
        tblView?.scrollIndicatorInsets = contentInsets;
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        //self.changeDatePickerViewDate()
        self.registerForKeyboardNotifications()
        return true
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Keyboard notification function
    @objc func keyboardWasShown(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let visibleAreaHeight = UIScreen.mainScreen().bounds.height - 104 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        lastOffset = (view?.contentOffset)!
        let cellFrame = tblView?.rectForRowAtIndexPath((tblView?.indexPathForCell(self))!)
        
        let yOfTextField = datePickerTextField.frame.origin.y + (cellFrame?.origin.y)! + (tblView!.frame.origin.y) + self.frame.size.height
        if (yOfTextField - (lastOffset.y)) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            view?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        view?.setContentOffset(lastOffset, animated: true)
    }
    
}
