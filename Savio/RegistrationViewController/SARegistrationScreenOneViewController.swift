//
//  SARegistrationScreenOneViewController.swift
//  Savio
//
//  Created by Maheshwari on 10/08/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SARegistrationScreenOneViewController: UIViewController,UITextFieldDelegate,UIScrollViewDelegate,RegistrationViewErrorDelegate{
    
    @IBOutlet weak var registerOneScrollView: UIScrollView!
    @IBOutlet weak var titleOrNameErrorLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameErrorLabel: UILabel!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var dateOfBirthErrorLabel: UILabel!
    @IBOutlet weak var mobileNumberErrorLabel: UILabel!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var whyDoWeNeedInformationButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var topSpaceForSurnameTextField: NSLayoutConstraint!
    @IBOutlet weak var topSpaceForMobileNumberTextField: NSLayoutConstraint!
    @IBOutlet weak var titleOrNameLabelHt: NSLayoutConstraint!
    @IBOutlet weak var surnameErrorLabelHt: NSLayoutConstraint!
    @IBOutlet weak var dateOfBirthErrolLabelHt: NSLayoutConstraint!
    @IBOutlet weak var mobileNumberErrorLabelHt: NSLayoutConstraint!
    @IBOutlet weak var emailLabelErrorHt: NSLayoutConstraint!
    @IBOutlet weak var topspacefieldForEmailTextField: NSLayoutConstraint!
    @IBOutlet weak var topSpaceForDateOfBirthTextField: NSLayoutConstraint!
    @IBOutlet weak var nextButtonBgView: UIView!
    
    var errorFlag = true
    let dropDown = DropDown()
    let datePickerView = UIDatePicker()
    var activeTextField = UITextField()
    var fName = ""
    var lName = ""
    var dob = ""
    var lastOffset: CGPoint = CGPointZero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        errorFlag = false
        self.setUpView()
    }
    
    func setUpView()
    {
        //Customization of title text field
        titleTextField?.layer.cornerRadius = 2.0
        titleTextField?.layer.masksToBounds = true
        titleTextField?.layer.borderWidth=1.0
        let placeholder = NSAttributedString(string:"Title" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        titleTextField?.attributedPlaceholder = placeholder;
        titleTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //Setting drop down list for titleTextField
        dropDown.anchorView = titleTextField
        dropDown.backgroundColor = UIColor.whiteColor()
        self.dropDown.textColor = UIColor.blackColor()
        self.dropDown.selectionBackgroundColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        dropDown.dataSource = [
            "Mr",
            "Ms"]
        //added bottom offset for dropdown
        dropDown.bottomOffset = CGPoint(x: 0, y:titleTextField!.bounds.height)
        //Selection action of dropdown
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.titleTextField?.text = item
            self.titleTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
    
        }
        
         //Customization of name text field
        nameTextField?.layer.cornerRadius = 2.0
        nameTextField?.layer.masksToBounds = true
        nameTextField?.layer.borderWidth=1.0
        let placeholder1 = NSAttributedString(string:"Name" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        nameTextField?.attributedPlaceholder = placeholder1;
        nameTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
         //Customization of surname text field
        surnameTextField?.layer.cornerRadius = 2.0
        surnameTextField?.layer.masksToBounds = true
        surnameTextField?.layer.borderWidth=1.0
        let placeholder2 = NSAttributedString(string:"Surname" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        surnameTextField?.attributedPlaceholder = placeholder2;
        surnameTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
         //Customization of DOB text field
        dateOfBirthTextField?.layer.cornerRadius = 2.0
        dateOfBirthTextField?.layer.masksToBounds = true
        dateOfBirthTextField?.layer.borderWidth=1.0
        let placeholder3 = NSAttributedString(string:"Date of birth" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        dateOfBirthTextField?.attributedPlaceholder = placeholder3;
        dateOfBirthTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //add custom tool bar for UIDatePickerView
        let customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBarButtonPressed"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar.items = [cancelButton,flexibleSpace,acceptButton]
        
        //Set datepickerview as input view and customtoolbar as inputAccessoryViewto DOB textfield
        dateOfBirthTextField.inputView = datePickerView
        dateOfBirthTextField.inputAccessoryView = customToolBar
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        //get 18 years previous date
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        components.year = -18
        let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        datePickerView.maximumDate = minDate
        
        //Customization of mobile number text field
        mobileNumberTextField?.layer.cornerRadius = 2.0
        mobileNumberTextField?.layer.masksToBounds = true
        mobileNumberTextField?.layer.borderWidth=1.0
        let placeholder4 = NSAttributedString(string:"Mobile number" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        mobileNumberTextField?.attributedPlaceholder = placeholder4;
        mobileNumberTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        //Add custom tool bar as input accessory view to mobile number textfield
        let customToolBar2 = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar2.items = [flexibleSpace1,doneButton]
        mobileNumberTextField.inputAccessoryView = customToolBar2
        
         //Customization of email text field
        emailTextField?.layer.cornerRadius = 2.0
        emailTextField?.layer.masksToBounds = true
        emailTextField?.layer.borderWidth=1.0
        let placeholder5 = NSAttributedString(string:"Email" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        emailTextField?.attributedPlaceholder = placeholder5;
        emailTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //Customization of next button
        nextButton?.layer.cornerRadius = 2.0
        nextButtonBgView.layer.cornerRadius = 2.0
        
        topspacefieldForEmailTextField.constant = 5
        topSpaceForSurnameTextField.constant = 5
        topSpaceForDateOfBirthTextField.constant = 5
        topSpaceForMobileNumberTextField.constant = 5
        
        titleOrNameErrorLabel.text = ""
        mobileNumberErrorLabel.text = ""
        emailErrorLabel.text = ""
        surnameErrorLabel.text = ""
        dateOfBirthErrorLabel.text = ""
        
    }
    
    //Check all text fields validations
    func checkTextFieldValidation()->Bool{
        
        //Validations for title and name text field
        if(titleTextField.text?.characters.count == 0 && nameTextField.text?.characters.count == 0) {
            titleOrNameErrorLabel.text = "We need to know your title and name"
            titleTextField.layer.borderColor = UIColor.redColor().CGColor
            nameTextField.layer.borderColor = UIColor.redColor().CGColor
            nameTextField.textColor = UIColor.redColor()
            errorFlag = true
        }
        else if (self.checkTextFieldContentOnlyNumber(nameTextField.text!) == true) {
            titleOrNameErrorLabel.text = "Name should contain alphabets only"
            if titleTextField.text?.characters.count==0 {
                titleOrNameErrorLabel.text = "Please select a title and name should contain alphabets only"
                errorFlag = true
            }
            nameTextField.layer.borderColor = UIColor.redColor().CGColor
            nameTextField.textColor = UIColor.redColor()
        }
        else if (self.checkTextFieldContentSpecialChar(nameTextField.text!)) {
            titleOrNameErrorLabel.text = "Name should not contain special characters"
            if(titleTextField.text?.characters.count == 0)
            {
                titleOrNameErrorLabel.text = "Please select a title and name should not contain special characters"
            }
            registerOneScrollView.contentSize = CGSizeMake(0, registerOneScrollView.contentSize.height + 20)
            errorFlag = true
            nameTextField.layer.borderColor = UIColor.redColor().CGColor
            nameTextField.textColor = UIColor.redColor()
        }
        else if nameTextField.text?.characters.count > 50 {
            titleOrNameErrorLabel.text = "Wow, that’s such a long name we can’t save it"
            errorFlag = true
            if(titleTextField.text?.characters.count == 0)
            {
                titleOrNameErrorLabel.text = "Please select a title and such a long name we can’t save it"
            }
            nameTextField.layer.borderColor = UIColor.redColor().CGColor
            nameTextField.textColor = UIColor.redColor()
        }
        else if titleTextField.text == "" {
            titleOrNameErrorLabel.text = "Please select a title"
            errorFlag = true
            titleTextField.textColor = UIColor.redColor()
        }
        else if nameTextField.text == "" {
            titleOrNameErrorLabel.text = "We need to know what to call you"
            errorFlag = true
            nameTextField.layer.borderColor = UIColor.redColor().CGColor
            nameTextField.textColor = UIColor.redColor()
        }
        else {
            titleOrNameErrorLabel.text = ""
        }
        
        //Validations for surname text field
        if surnameTextField.text=="" {
            
            surnameErrorLabel.text = "We need to know your surname"
            topSpaceForSurnameTextField.constant = 21
            errorFlag = true
            surnameTextField.layer.borderColor = UIColor.redColor().CGColor
            surnameTextField.textColor = UIColor.redColor()
        }
        else if(surnameTextField.text?.characters.count>50) {
            surnameErrorLabel.text = "Wow, that’s such a long surname we can’t save it"
            topSpaceForSurnameTextField.constant = 21
            errorFlag = true
            surnameTextField.layer.borderColor = UIColor.redColor().CGColor
            surnameTextField.textColor = UIColor.redColor()
        }
        else if(self.checkTextFieldContentOnlyNumber(surnameTextField.text!) == true) {
            surnameErrorLabel.text = "Surname should contain alphabets only"
            topSpaceForSurnameTextField.constant = 21
            errorFlag = true
            surnameTextField.layer.borderColor = UIColor.redColor().CGColor
            surnameTextField.textColor = UIColor.redColor()
        }
        else if checkTextFieldContentSpecialChar(surnameTextField.text!) {
            surnameErrorLabel.text = "Surname should not contain special characters"
            if(UIScreen.mainScreen().bounds.width == 320)
            {
                topSpaceForSurnameTextField.constant = 40
                surnameErrorLabelHt.constant = 40
            }
            else {
                 topSpaceForSurnameTextField.constant = 21
                surnameErrorLabelHt.constant = 21
            }
           
            errorFlag = true
            surnameTextField.layer.borderColor = UIColor.redColor().CGColor
            surnameTextField.textColor = UIColor.redColor()
        }
        else {
            surnameErrorLabel.text = ""
            topSpaceForSurnameTextField.constant = 5
        }
        
        //Validations for date of birth text field
        if(dateOfBirthTextField.text == "")  {
            topSpaceForDateOfBirthTextField.constant = 21
            dateOfBirthErrorLabel.text = "We need to know your date of birth"
            errorFlag = true
            dateOfBirthTextField.layer.borderColor = UIColor.redColor().CGColor
            dateOfBirthTextField.textColor = UIColor.redColor()
        }
        else  {
            topSpaceForDateOfBirthTextField.constant = 5
            dateOfBirthErrorLabel.text = ""
        }
        
        //Validations for mobile text field
        if mobileNumberTextField.text == "" {
            mobileNumberErrorLabel.text = "Don't forget your mobile number"
            topSpaceForMobileNumberTextField.constant = 21
            errorFlag = true
            mobileNumberTextField.layer.borderColor = UIColor.redColor().CGColor
            mobileNumberTextField.textColor = UIColor.redColor()
        }
        else if(self.checkTextFieldContentCharacters(mobileNumberTextField.text!) == true || self.phoneNumberValidation(mobileNumberTextField.text!)==false) {
            mobileNumberErrorLabel.text = "That mobile number doesn’t look right"
            topSpaceForMobileNumberTextField.constant = 21
            errorFlag = true
            mobileNumberTextField.layer.borderColor = UIColor.redColor().CGColor
            mobileNumberTextField.textColor = UIColor.redColor()
        }
        else if(mobileNumberTextField.text?.characters.count < 10) {
            mobileNumberErrorLabel.text = "That mobile number should be greater than 10 digits"
            if(UIScreen.mainScreen().bounds.width == 320)
            {
            topSpaceForMobileNumberTextField.constant = 40
            mobileNumberErrorLabelHt.constant = 40
            }
            else
            {
                topSpaceForMobileNumberTextField.constant = 21
                   mobileNumberErrorLabelHt.constant = 21
            }
            errorFlag = true
            mobileNumberTextField.layer.borderColor = UIColor.redColor().CGColor
            mobileNumberTextField.textColor = UIColor.redColor()
            registerOneScrollView.contentSize = CGSizeMake(0, registerOneScrollView.contentSize.height + 20)
        }
        else if(mobileNumberTextField.text?.characters.count > 16) {
            mobileNumberErrorLabel.text = "That mobile number should be of 15 digits"
            topSpaceForMobileNumberTextField.constant = 21
            errorFlag = true
            mobileNumberTextField.layer.borderColor = UIColor.redColor().CGColor
            mobileNumberTextField.textColor = UIColor.redColor()
        }
        else {
            topSpaceForMobileNumberTextField.constant = 5
            mobileNumberErrorLabel.text = ""
        }
        
        //Validations for email text field
        
        if emailTextField.text=="" {
            
            topspacefieldForEmailTextField.constant = 21
            emailErrorLabel.text = "Don't forget your email address"
            errorFlag = true
            emailTextField.textColor = UIColor.redColor()
            emailTextField.layer.borderColor = UIColor.redColor().CGColor
        }
        else  if emailTextField.text?.characters.count>0 && (self.isValidEmail(emailTextField.text!)==false) {
            topspacefieldForEmailTextField.constant = 21
            emailErrorLabel.text = "That email address doesn’t look right"
            errorFlag = true
            emailTextField.layer.borderColor = UIColor.redColor().CGColor
            emailTextField.textColor = UIColor.redColor()
            
        }
        else {
            topspacefieldForEmailTextField.constant = 5
            emailErrorLabel.text = ""
        }
        
        return errorFlag
        
    }
    //Register keyboard notification
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
 
    //Keyboard notification function
    @objc func keyboardWasShown(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let visibleAreaHeight = UIScreen.mainScreen().bounds.height - 30 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        lastOffset = (registerOneScrollView?.contentOffset)!
        let yOfTextField = activeTextField.frame.origin.y
        if (yOfTextField - (lastOffset.y)) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            registerOneScrollView?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        registerOneScrollView?.setContentOffset(lastOffset, animated: true)
    }
    
    func validateForAlreadyRegisteredUser()-> Bool
    {
        var success = true
        var message = ""
        if(fName.characters.count == 0) {
            return true
        }
        if(fName.lowercaseString != nameTextField.text?.lowercaseString) {
            success = false
            message = message + "name"
        }
        if(lName.lowercaseString != surnameTextField.text?.lowercaseString) {
            success = false
            let fieldString = message.characters.count > 0 ? ",Surname" : "Surname"
             message = message + fieldString
        }
        if(dob != dateOfBirthTextField.text) {
            success = false
            let fieldString = message.characters.count > 0 ? ",date of birth" : "date of birth"
            message = message + fieldString
        }
        
        if(success == false)  {
            message = "Enter your " + message + " as earlier"
            let alert = UIAlertView(title: "Warning", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        return success
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        //check validation of textfield
        
        if(checkTextFieldValidation() == false)
        {
            if(validateForAlreadyRegisteredUser() == false)
            {
                return
            }
            errorFlag = true
            var userInfoDict : Dictionary<String,AnyObject> = [:]
            userInfoDict["title"] = titleTextField.text
            userInfoDict["first_name"] = nameTextField.text
            userInfoDict["second_name"] = surnameTextField.text
            userInfoDict["date_of_birth"] = dateOfBirthTextField.text
            userInfoDict["phone_number"] = String(format:"+44%@",mobileNumberTextField.text!)
            userInfoDict["email"] = emailTextField.text
            
            if(titleTextField.text == "Mr")
            {
                userInfoDict["party_gender"] = "male"
            }
            else
            {
                userInfoDict["party_gender"] = "female"
            }
            
            let registrationSecondView = SARegistrationScreenSecondViewController()
            registrationSecondView.registrationViewErrorDelegate = self
            registrationSecondView.userInfoDict = userInfoDict
            self.navigationController?.pushViewController(registrationSecondView, animated: true)
        
        }
        else {
            errorFlag = false
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        //Go back to previous view controller
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func whyDoWeThisInfoButtonPressed(sender: AnyObject) {
        let objimpInfo = NSBundle.mainBundle().loadNibNamed("ImportantInformationView", owner: self, options: nil)[0] as! ImportantInformationView
        objimpInfo.lblHeader.text = "Why do we need this information?"
        objimpInfo.frame = self.view.frame
        objimpInfo.isFromRegistration = false
        self.view.addSubview(objimpInfo)
    }
    
    //Textfield delegate methods
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        activeTextField = textField
        activeTextField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        activeTextField.textColor = UIColor.blackColor()
        self.registerForKeyboardNotifications()
        if(textField == titleTextField)
        {
            self.showOrDismiss()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField.resignFirstResponder()
        activeTextField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        self.removeKeyboardNotification()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.removeKeyboardNotification()
        return true
    }
    
    func checkTextFieldTextLength(txtField: UITextField,range: NSRange, replacementString string: String, len: Int) -> Bool {
        let currentCharacterCount = txtField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if (newLength > len) {
            return false;
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(activeTextField == mobileNumberTextField){
            return  self.checkTextFieldTextLength(textField, range: range, replacementString: string, len: 15)
        }
        return true;
    }

    //Dropdown methods
    func showOrDismiss(){
        if dropDown.hidden {
            dropDown.show()
        } else {
            dropDown.hide()
        }
    }
    
    
    //ToolBar button action methods
    func cancelBarButtonPressed()
    {
        dateOfBirthTextField.resignFirstResponder()
        self.removeKeyboardNotification()
    }
    
    func doneBarButtonPressed()
    {
        if(activeTextField == dateOfBirthTextField) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let pickrDate = dateFormatter.stringFromDate(datePickerView.date)
            dateOfBirthTextField.text = pickrDate
        }
        activeTextField.resignFirstResponder()
        self.removeKeyboardNotification()
    }
    
    @IBAction func clickeOnDropDownArrow(sender:UIButton){
        self.showOrDismiss()
    }
    
    @IBAction func showOrHideDropDownButtonPressed(sender: AnyObject) {
        self.showOrDismiss()
    }
    
    //Function checking textfield content only number or not
    func checkTextFieldContentOnlyNumber(str:String)->Bool{
        let set = NSCharacterSet.decimalDigitCharacterSet()
        if (str.rangeOfCharacterFromSet(set) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func checkTextFieldContentCharacters(str:String)->Bool{
        let set = NSCharacterSet.letterCharacterSet()
        if (str.rangeOfCharacterFromSet(set) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func phoneNumberValidation(value: String) -> Bool {
        let charcter  = NSCharacterSet(charactersInString: "0123456789").invertedSet
        var filtered:NSString!
        let inputString:NSArray = value.componentsSeparatedByCharactersInSet(charcter)
        filtered = inputString.componentsJoinedByString("")
        return  value == filtered
    }
    
    
    func checkTextFieldContentSpecialChar(str:String)->Bool{
        let characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "~!@#$%^&*()_-+={}|\\;:'\",.<>*/")
        if (str.rangeOfCharacterFromSet(characterSet) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    //Function invoke for validate the email
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        var result = emailTest.evaluateWithObject(testStr)
        if result {
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let matches = testStr.rangeOfString(regex, options: .RegularExpressionSearch)
            if let _ = matches {
                result = true
            }
            else {
                result = false
            }
        }
        return result
    }
    
    func getValues(firstName: String, lastName: String, dateOfBirth: String) {
        errorFlag = false
        fName = firstName
        lName = lastName
        dob = dateOfBirth
    }
    
}
