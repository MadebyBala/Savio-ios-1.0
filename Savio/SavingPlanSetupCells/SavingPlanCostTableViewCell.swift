//
//  SavingPlanCostTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
protocol SavingPlanCostTableViewCellDelegate {
    func txtFieldCellText(txtFldCell:SavingPlanCostTableViewCell)
}
class SavingPlanCostTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var BGContentView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    weak var tblView : UITableView?
    weak var view : UIScrollView?
    var delegate: SavingPlanCostTableViewCellDelegate?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    var lastOffset: CGPoint = CGPointZero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        costTextField.delegate = self
        //Get the dictionary of selected theme from NSUserdefaults
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        // corner Radius of costTextField
        costTextField.layer.cornerRadius = 4
        //set the color and corner radius for minus and plus button
        minusButton.layer.cornerRadius = minusButton.frame.size.height / 2
        minusButton.setTitleColor(self.setUpColor(), forState: UIControlState.Normal)
        minusButton.layer.masksToBounds = true
        
        plusButton.layer.cornerRadius = plusButton.frame.size.height / 2
        plusButton.layer.masksToBounds = true
        plusButton.setTitleColor(self.setUpColor(), forState: UIControlState.Normal)
        
        slider.thumbTintColor = self.setUpColor()
        slider.setThumbImage(self.setUpImage(), forState: UIControlState.Normal)
        slider.setThumbImage(self.setUpImage(), forState: UIControlState.Highlighted)
        
        var customToolBar : UIToolbar?
        customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        customToolBar!.items = [acceptButton]
        costTextField.inputAccessoryView = customToolBar
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func doneBarButtonPressed() {
        if(costTextField.text?.characters.count > 1)
        {
            costTextField.resignFirstResponder()
            var textFieldValue: String  = (costTextField?.text)!
            textFieldValue = textFieldValue.chopPrefix(1)
            slider.value = Float(textFieldValue)!
            delegate?.txtFieldCellText(self)
            if(Float(textFieldValue)! > 3000) {
                let alert = UIAlertView(title: "Warning", message: "Please enter cost less than £ 3000", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }else{
            let alert = UIAlertView(title: "Warning", message: "Please enter cost", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //get the Image for selected theme
    func setUpImage()-> UIImage
    {
        var imageName = ""
        if(colorDataDict["savPlanID"] as! Int == 85) {
            imageName = "group-save-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 86)
        {
            imageName = "wedding-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 87) {
            imageName = "baby-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 88) {
            imageName = "holiday-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 89) {
            imageName = "ride-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 90) {
            imageName = "home-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 91) {
            imageName = "gadget-circle.png"
        }
        else {
            imageName = "generic-circle.png"
        }
        return UIImage(named:imageName)!
    }
    
    //get the color for selected theme
    func setUpColor()-> UIColor
    {
        return ColorCodes.colorForCode(colorDataDict["savPlanID"] as! Int)
    }
    
    //UISegmentcontrol value changed method
    @IBAction func sliderValueChanged(sender: UISlider) {
        if(sender.value >= 2000) {
            sender.value = sender.value + 30;
        }
        else {
            sender.value = sender.value + 10;
        }
        
        //set the slider value
        self.costTextField.attributedText = self.createAttributedString("£" + String(format: "%d",Int(sender.value)))
        delegate?.txtFieldCellText(self)
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func plusButtonPressed(sender: AnyObject) {
        if(slider.value >= 2000) {
            slider.value = slider.value + 30;
        }
        else {
            slider.value = slider.value + 10;
        }
        self.costTextField.attributedText = self.createAttributedString("£" + String(format: "%d",Int(slider.value)))
        delegate?.txtFieldCellText(self)
    }
    
    @IBAction func minusButtonPressed(sender: AnyObject) {
        if(slider.value >= 2000) {
            slider.value = slider.value - 30;
        }
        else {
            slider.value = slider.value - 10;
        }
        costTextField.text = String(format: " %d",Int(slider.value))
        self.costTextField.attributedText = self.createAttributedString("£" + String(format: "%d",Int(slider.value)))
        delegate?.txtFieldCellText(self)
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
        let yOfTextField = costTextField.frame.origin.y + (cellFrame?.origin.y)! + (tblView!.frame.origin.y) + self.frame.size.height
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
    
    //UITextfieldDelegate method
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.characters.count > 1  && string == "" {
            return true
        }
        let combinedString = textField.text! + string
        let valueString = combinedString.chopPrefix(1)
        if valueString.characters.count == 0 {
            return false
        }
        if(Float(valueString)! > 3000)
        {
            self.costTextField.attributedText = self.createAttributedString("£3000")
            slider.value = 3000
            let alert = UIAlertView(title: "Warning", message: "Please enter cost less than £ 3000", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            return false
        }
        if combinedString.characters.count < 6 {
            self.costTextField.attributedText = self.createAttributedString(combinedString)
            slider.value = Float(valueString)!
        }
        return false
    }
    
    func createAttributedString(string: String) -> NSAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(15)], range: NSRange(location: 0, length: 1))
        attributedString.addAttributes([NSForegroundColorAttributeName : self.setUpColor()], range: NSRange(location: 0, length: 1))
        return attributedString
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        self.registerForKeyboardNotifications()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        var textFieldValue: String  = (costTextField?.text)!
        textFieldValue = textFieldValue.chopPrefix(1)
        slider.value = Float(textFieldValue)!
        delegate?.txtFieldCellText(self)
        if(Float(textFieldValue) > 3000) {
            let alert = UIAlertView(title: "Warning", message: "Please enter cost less than £ 3000", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        return true
    }
    
}
