
//
//  SetDayTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SegmentBarChangeDelegate {
    func segmentBarChanged(str:String)
    func getDateTextField(str:String)
}



class SetDayTableViewCell: UITableViewCell,UIPopoverPresentationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate {
    @IBOutlet weak var setDayDateButton: UIButton!
    @IBOutlet weak var BGContentView: UIView!
    @IBOutlet weak var dayDateTextField: UITextField!
    @IBOutlet weak var dayDateLabel: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dropDownImageView: UIImageView!
    @IBOutlet weak var segmentBar: CustomSegmentBar!

    var dayPickerView = UIPickerView()
    let dayArray : Array<String> = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    let dateArray : Array<String> = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28"]
    
    var segmentDelegate : SegmentBarChangeDelegate?
    var customToolBar : UIToolbar?
    weak var view : UIScrollView?
    var dateStr : String = ""
    var dayDateStr : String = "date"
    weak var tblView : UITableView?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    var lastOffset: CGPoint = CGPointZero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        BGContentView.layer.cornerRadius = 5
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        let leftView = UIView()
        leftView.frame = CGRectMake(0, 0, 5, 26)
        leftView.backgroundColor = UIColor.clearColor()
        dayDateTextField.leftView = leftView
        dayDateTextField.leftViewMode = UITextFieldViewMode.Always
        print(colorDataDict["savPlanID"])
        if(colorDataDict["savPlanID"] as! Int == 92) {
            titleLbl.text = "Adding funds every"
        }
        //add corner radius to textfield
        let maskPath1: UIBezierPath = UIBezierPath(roundedRect: dayDateTextField!.bounds, byRoundingCorners: ([.TopLeft, .BottomLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer1: CAShapeLayer = CAShapeLayer()
        maskLayer1.frame = dayDateTextField!.bounds
        maskLayer1.path = maskPath1.CGPath
        dayDateTextField?.layer.mask = maskLayer1
        //Create custon tool bar for dayDateTextField
        customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBarButtonPressed"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar!.items = [cancelButton,flexibleSpace,acceptButton]

        dayDateTextField.delegate = self
        dayDateTextField.inputView = dayPickerView
        dayDateTextField.inputAccessoryView = customToolBar
        
        //add corner radius to dropdownimageview
        let maskPath2: UIBezierPath = UIBezierPath(roundedRect: dropDownImageView!.bounds, byRoundingCorners: ([.TopRight, .BottomRight]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer2: CAShapeLayer = CAShapeLayer()
        maskLayer2.frame = dropDownImageView!.bounds
        maskLayer2.path = maskPath2.CGPath
        dropDownImageView?.layer.mask = maskLayer2
        dropDownImageView.image = self.setDownWordImage()
        segmentBar.segmentSelected =  { (idx: Int)  in
            if(idx == 1) {
                self.dayDateLabel.text = "day"
                self.segmentDelegate!.segmentBarChanged("date")
                self.dayDateTextField.text = ""
                self.dayDateStr = "date"
            }
            else {
                self.dayDateLabel.text = "day"
                self.segmentDelegate!.segmentBarChanged("day")
                self.dayDateTextField.text = ""
                self.dayDateStr = "day"
            }
            self.dayPickerView.reloadAllComponents()
        }
    }
    
    private func createXLabelText (index: Int,text:String) -> NSMutableAttributedString {
        let fontNormal:UIFont? = UIFont(name: kMediumFont, size:10)
        let normalscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:fontNormal!,NSBaselineOffsetAttributeName:0])
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:5)
        switch index {
        case 1:
            let superscript = NSMutableAttributedString(string: "st", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        case 2:
            let superscript = NSMutableAttributedString(string: "nd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        case 3:
            let superscript = NSMutableAttributedString(string: "rd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        case 21:
            let superscript = NSMutableAttributedString(string: "st", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        case 22:
            let superscript = NSMutableAttributedString(string: "nd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        case 23:
            let superscript = NSMutableAttributedString(string: "rd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        default:
            let superscript = NSMutableAttributedString(string: "th", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        }
        
        return normalscript
    }
    
    func doneBarButtonPressed(){
        dayDateTextField.resignFirstResponder()
        dropDownImageView.image = self.setUpWordImage()
        if(dayPickerView.selectedRowInComponent(0) == 0) {
            if(dayDateStr == "date") {
                
                dayDateTextField.attributedText = self.createXLabelText(1, text: "1")
                 segmentDelegate!.getDateTextField("1")
            }
            else {
                dayDateTextField.text = "Mon"
                dayDateTextField.font = UIFont(name: kMediumFont, size:10)
                 segmentDelegate!.getDateTextField("Mon")
            }
        }
        else {
            if(dayDateStr == "date") {
                let date : Int? = Int(dateStr)
                if(date != 0 && dateStr != "")
                {
                dayDateTextField.attributedText = self.createXLabelText(date!, text: String(format: "%@",dateStr))
                }
            }
            else {
                dayDateTextField.font = UIFont(name: kMediumFont, size:10)
                dayDateTextField.text = dateStr
            }
             segmentDelegate!.getDateTextField(dateStr)
        }
        dayPickerView.reloadAllComponents()
       
    }
    
    func cancelBarButtonPressed(){
        dayDateTextField.resignFirstResponder()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        if(dayDateStr == "day") {
            return dayArray.count
        }
        else {
            return dateArray.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(dayDateStr == "day") {
            return dayArray[row]
        }
        else {
            return dateArray[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(dayDateStr == "day") {
            dateStr =  dayArray[row]
        }
        else {
            dateStr =  dateArray[row]
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUpWordImage()->UIImage
    {
        var imageName = ""
        if(colorDataDict["savPlanID"] as! Int == 85) {
            imageName = "group-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 86) {
            imageName = "wedding-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 87) {
            imageName = "baby-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 88) {
            imageName = "holiday-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 89) {
            imageName = "ride-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 90) {
            imageName = "home-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 91) {
            imageName = "gadget-updown.png"
        }
        else {
            imageName = "generic-updown.png"
        }
        return UIImage(named:imageName)!
    }
    
    func setDownWordImage()->UIImage
    {
        var imageName = ""
        if(colorDataDict["savPlanID"] as! Int == 85) {
            imageName = "group-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 86) {
            imageName = "wedding-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 87) {
            imageName = "baby-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 88) {
            imageName = "holiday-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 89) {
            imageName = "ride-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 90) {
            imageName = "home-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 91) {
            imageName = "gadget-dropdown.png"
        }
        else {
            imageName = "generic-dropdown.png"
        }
        return UIImage(named:imageName)!
        
    }
    
    func setUpColor()-> UIColor
    {
        return ColorCodes.colorForCode(colorDataDict["savPlanID"] as! Int)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
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
        //        let visibleRect = CGRect(x: 0, y: 0, width:  UIScreen.mainScreen().bounds.width, height: height)
        lastOffset = (view?.contentOffset)!
        let cellFrame = tblView?.rectForRowAtIndexPath((tblView?.indexPathForCell(self))!)
        
        let yOfTextField = dayDateTextField.frame.origin.y + (cellFrame?.origin.y)! + (tblView!.frame.origin.y) + self.frame.size.height
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
