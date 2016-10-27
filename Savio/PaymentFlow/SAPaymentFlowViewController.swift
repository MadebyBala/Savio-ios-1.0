//
//  SAPaymentFlowViewController.swift
//  Savio
//
//  Created by Maheshwari on 13/09/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
import PassKit

class SAPaymentFlowViewController: UIViewController,AddSavingCardDelegate,AddNewSavingCardDelegate,ImpulseSavingDelegate{
    
    @IBOutlet weak var cardHoldersNameTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var expiryMonthYearTextField: UITextField!
    @IBOutlet weak var saveButtonBgView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var cardNumberErrorLabel: UILabel!
    @IBOutlet weak var cardErrorLabelHt: NSLayoutConstraint!
    @IBOutlet weak var cardNumberTextFieldTopSpace: NSLayoutConstraint!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var objAnimView = ImageViewAnimation()
    var picker = MonthYearPickerView()
    var lastOffset: CGPoint = CGPointZero
    var activeTextField = UITextField()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var errorFlag = false
    var request = PKPaymentRequest()
    var stripeCard = STPCard()
    var isFromGroupMemberPlan = false
    var isFromImpulseSaving = false
    var isFromEditUserInfo = false
    var doNotShowBackButton = true
    var addNewCard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    
    func setUpView(){
        let objAPI = API()
        if let _ = objAPI.getValueFromKeychainOfKey("savingPlanDict") as? Dictionary<String,AnyObject>
        {
            if let _ =  objAPI.getValueFromKeychainOfKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
            {
                
                // self.navigationItem.setHidesBackButton(true, animated: false)
                let leftBtnName = UIButton()
                leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
                leftBtnName.frame = CGRectMake(0, 0, 30, 30)
                leftBtnName.addTarget(self, action: Selector("backButtonPressd"), forControlEvents: .TouchUpInside)
                let leftBarButton = UIBarButtonItem()
                leftBarButton.customView = leftBtnName
                self.navigationItem.leftBarButtonItem = leftBarButton
                
                self.cancelButton.hidden = false
                
            }else {
                self.navigationItem.setHidesBackButton(true, animated: false)
            }
        }
        else {
            // self.navigationItem.setHidesBackButton(true, animated: false)
            let leftBtnName = UIButton()
            leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
            leftBtnName.frame = CGRectMake(0, 0, 30, 30)
            leftBtnName.addTarget(self, action: Selector("backButtonPressd"), forControlEvents: .TouchUpInside)
            let leftBarButton = UIBarButtonItem()
            leftBarButton.customView = leftBtnName
            self.navigationItem.leftBarButtonItem = leftBarButton
            
            self.cancelButton.hidden = false
        }
        
        cardNumberTextFieldTopSpace.constant = 5
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.title = "Payment setup"
        
        //Customization of card holders name text field
        cardHoldersNameTextField?.layer.cornerRadius = 2.0
        cardHoldersNameTextField?.layer.masksToBounds = true
        cardHoldersNameTextField?.layer.borderWidth=1.0
        let placeholder = NSAttributedString(string:"Name on Card" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        cardHoldersNameTextField?.attributedPlaceholder = placeholder;
        cardHoldersNameTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //Customization of card number text field
        cardNumberTextField?.layer.cornerRadius = 2.0
        cardNumberTextField?.layer.masksToBounds = true
        cardNumberTextField?.layer.borderWidth=1.0
        let placeholder1 = NSAttributedString(string:"Card Number" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        cardNumberTextField?.attributedPlaceholder = placeholder1;
        cardNumberTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        
        //Customization of expiry month year text field
        expiryMonthYearTextField?.layer.cornerRadius = 2.0
        expiryMonthYearTextField?.layer.masksToBounds = true
        expiryMonthYearTextField?.layer.borderWidth=1.0
        let placeholder2 = NSAttributedString(string:"MM/YY" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        expiryMonthYearTextField?.attributedPlaceholder = placeholder2;
        expiryMonthYearTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //add custom tool bar for UIDatePickerView
        let customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBarButtonPressed"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar.items = [cancelButton,flexibleSpace,acceptButton]
        
        //Set datepickerview as input view and customtoolbar as inputAccessoryView to expiry date textfield
        expiryMonthYearTextField.inputView = picker
        expiryMonthYearTextField.inputAccessoryView = customToolBar
        
        
        //Customization of cvv text field
        cvvTextField?.layer.cornerRadius = 2.0
        cvvTextField?.layer.masksToBounds = true
        cvvTextField?.layer.borderWidth=1.0
        let placeholder3 = NSAttributedString(string:"CVV" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        cvvTextField?.attributedPlaceholder = placeholder3;
        cvvTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //Add custom tool bar as input accessory view to card number textfield and cvv textfield
        let customToolBar2 = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar2.items = [flexibleSpace1,doneButton]
        cardNumberTextField.inputAccessoryView = customToolBar2
        cvvTextField.inputAccessoryView = customToolBar2
        
        //Customization of save button background view and save button
        saveButtonBgView.layer.cornerRadius = 2.0
        saveButton.layer.cornerRadius = 2.0
        
    }
    
    
    func backButtonPressd()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func doneBarButtonPressed()
    {
        if(activeTextField == expiryMonthYearTextField)
        {
            if(String(format: "%02d/%d", picker.month, picker.year) == "00/0")
            {
                let date = NSDate()
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components([.Day , .Month , .Year], fromDate: date)
                self.expiryMonthYearTextField.text = String(format: "%02d/%d", components.month, components.year%100)
                
            }
            else {
                self.expiryMonthYearTextField.text = String(format: "%02d/%d", picker.month, picker.year%100)
            }
        }
        activeTextField.resignFirstResponder()
    }
    
    func cancelBarButtonPressed()
    {
        expiryMonthYearTextField.resignFirstResponder()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.navigationController?.view.addSubview(self.objAnimView)
        //Check validations of Textfields
        if(checkTextFieldValidation() == false)
        {
            //Customize Stripe card
            stripeCard.cvc = cvvTextField.text
            stripeCard.number = cardNumberTextField.text
            stripeCard.expYear = UInt(picker.year)
            stripeCard.expMonth = UInt(picker.month)
            
            //Stripe create token closure
            STPAPIClient.sharedClient().createTokenWithCard(stripeCard, completion: { (token: STPToken?, error: NSError?) -> Void in
                print(token?.tokenId)
                self.errorFlag = false
                print(error?.localizedDescription)
                if((error) != nil)
                {
                    self.objAnimView.removeFromSuperview()
                    self.cardNumberErrorLabel.text = "Enter valid card details"
                    self.cardNumberTextFieldTopSpace.constant = 35
                    if(error?.localizedDescription == "Your card\'s number is invalid")
                    {
                        self.cardNumberTextField.layer.borderColor = UIColor.redColor().CGColor
                        self.cardNumberTextField.textColor = UIColor.redColor()
                    } else if(error?.localizedDescription == "Your card\'s expiration year is invalid") {
                        self.expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
                        self.expiryMonthYearTextField.textColor = UIColor.redColor()
                    }
                    else if(error?.localizedDescription == "Your card\'s expiration month is invalid") {
                        self.expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
                        self.expiryMonthYearTextField.textColor = UIColor.redColor()
                    }
                    else if(error?.localizedDescription == "Your card\'s security code is invalid") {
                        self.cvvTextField.layer.borderColor = UIColor.redColor().CGColor
                        self.cvvTextField.textColor = UIColor.redColor()
                    }
                }
                else {
                    let objAPI = API()
                    let userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
                    
                    var array : Array<Dictionary<String,AnyObject>> = []
                    let dict1 : Dictionary<String,AnyObject> = ["cardHolderName":self.cardHoldersNameTextField.text!,"cardNumber":self.cardNumberTextField.text!,"cardExpMonth":self.picker.month,"cardExpDate":self.picker.year,"cvv":self.cvvTextField.text!]
                    
                    //If user is adding new card call AddNewSavingCardDelegate
                    if(self.addNewCard == true)
                    {
                        if let saveCardArray = objAPI.getValueFromKeychainOfKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
                        {
                            array = saveCardArray
                            var cardNumberArray : Array<String> = []
                            for i in 0 ..< array.count{
                                let newDict = array[i]
                                cardNumberArray.append(newDict["cardNumber"] as! String)
                            }
                            if(cardNumberArray.contains(self.cardNumberTextField.text!) == false)
                            {
                                array.append(dict1)
                                NSUserDefaults.standardUserDefaults().setValue(dict1, forKey: "activeCard")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                objAPI.storeValueInKeychainForKey("saveCardArray", value: array)
                                
                                let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict["partyId"] as! NSNumber,"STRIPE_TOKEN":(token?.tokenId)!]
                                objAPI.addNewSavingCardDelegate = self
                                objAPI.addNewSavingCard(dict)
                                self.addNewCard = false
                                
                            }
                            else {
                                self.objAnimView.removeFromSuperview()
                                //show alert view controller if card is already added
                                let alertController = UIAlertController(title: "Warning", message: "You have already added this card", preferredStyle:UIAlertControllerStyle.Alert)
                                //alert view controll action method
                                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
                                { action -> Void in
                                    self.navigationController?.popViewControllerAnimated(true)
                                    })
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                        else {
                            //Call AddSavingCardDelegate
                            let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict["partyId"] as! NSNumber,"STRIPE_TOKEN":(token?.tokenId)!,"PTY_SAVINGPLAN_ID":NSUserDefaults.standardUserDefaults().valueForKey("PTY_SAVINGPLAN_ID") as! NSNumber]
                            objAPI.addSavingCardDelegate = self
                            objAPI.addSavingCard(dict)
                        }
                    }
                    else {
                        array.append(dict1)
                        NSUserDefaults.standardUserDefaults().setValue(dict1, forKey: "activeCard")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        objAPI.storeValueInKeychainForKey("saveCardArray", value: array)
                        
                        if(self.addNewCard == true)
                        {
                            let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict["partyId"] as! NSNumber,"STRIPE_TOKEN":(token?.tokenId)!]
                            
                            objAPI.addNewSavingCardDelegate = self
                            objAPI.addNewSavingCard(dict)
                            self.addNewCard = false
                        } else {
                            let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict["partyId"] as! NSNumber,"STRIPE_TOKEN":(token?.tokenId)!,"PTY_SAVINGPLAN_ID":NSUserDefaults.standardUserDefaults().valueForKey("PTY_SAVINGPLAN_ID") as! NSNumber]
                            
                            objAPI.addSavingCardDelegate = self
                            objAPI.addSavingCard(dict)
                        }
                        
                    }
                }
            })
        }
        else {
            errorFlag = false
            objAnimView.removeFromSuperview()
        }
        
    }
    
    func checkTextFieldValidation()->Bool
    {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        //Validations for card holders name text field
        if(cardHoldersNameTextField.text?.characters.count == 0 && cardHoldersNameTextField.text?.characters.count == 0) {
            nameErrorLabel.text = "Enter name on card"
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
            errorFlag = true
        }
        else if (self.checkTextFieldContentOnlyNumber(cardHoldersNameTextField.text!) == true) {
            nameErrorLabel.text = "Name should contain alphabets only"
            errorFlag = true
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
        }
        else if (self.checkTextFieldContentSpecialChar(cardHoldersNameTextField.text!)) {
            nameErrorLabel.text = "Name should not contain special characters"
            errorFlag = true
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
        }
        else if cardHoldersNameTextField.text?.characters.count > 50 {
            nameErrorLabel.text = "Wow, that’s such a long name we can’t save it"
            errorFlag = true
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
        }
        else {
            nameErrorLabel.text = ""
        }
        
        //Validations for card number text field
        if cardNumberTextField.text == "" {
            cardNumberErrorLabel.text = "Enter valid card details"
            cardNumberTextFieldTopSpace.constant = 35
            errorFlag = true
            cardNumberTextField.layer.borderColor = UIColor.redColor().CGColor
            cardNumberTextField.textColor = UIColor.redColor()
        }
        if cardNumberTextField.text?.characters.count < 16 {
            cardNumberErrorLabel.text = "Enter valid card details"
            cardNumberErrorLabel.hidden = false
            cardNumberTextFieldTopSpace.constant = 35
            errorFlag = true
            cardNumberTextField.layer.borderColor = UIColor.redColor().CGColor
            cardNumberTextField.textColor = UIColor.redColor()
        }
        else {
            cardNumberTextFieldTopSpace.constant = 5
            cardNumberErrorLabel.text = ""
        }
        
        //Validations for expiry date text field and cvv text field
        if(expiryMonthYearTextField.text == "" || cvvTextField.text == "")
        {
            cardNumberErrorLabel.text = "Enter valid card details"
            cardNumberTextFieldTopSpace.constant = 35
            errorFlag = true
            cvvTextField.layer.borderColor = UIColor.redColor().CGColor
            cvvTextField.textColor = UIColor.redColor()
            expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
            expiryMonthYearTextField.textColor = UIColor.redColor()
        }
            
        else if(expiryMonthYearTextField.text == String(format:"%d/%d",components.month,components.year))
        {
            cardNumberErrorLabel.text = "Enter valid card details"
            cardNumberTextFieldTopSpace.constant = 35
            errorFlag = true
            expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
            expiryMonthYearTextField.textColor = UIColor.redColor()
        }
        else if(cvvTextField.text?.characters.count < 3)
        {
            cardNumberErrorLabel.text = "Enter valid card details"
            cardNumberTextFieldTopSpace.constant = 35
            errorFlag = true
            cvvTextField.layer.borderColor = UIColor.redColor().CGColor
            cvvTextField.textColor = UIColor.redColor()
        }
        else {
            cardNumberErrorLabel.text = ""
        }
        
        return errorFlag
    }
    
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
    
    
    func checkTextFieldContentSpecialChar(str:String)->Bool{
        let characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "~!@#$%^&*()_-+={}|\\;:'\",.<>*/")
        if (str.rangeOfCharacterFromSet(characterSet) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //UITextField delegate method
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        activeTextField.textColor = UIColor.blackColor()
        self.registerForKeyboardNotifications()
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        if(textField == cardNumberTextField)
        {
            let newLength = text.utf16.count + string.utf16.count - range.length
            return newLength <= 16
        }
        else if(textField == cvvTextField){
            let newLength = text.utf16.count + string.utf16.count - range.length
            return newLength <= 3
        }
        else {
            return true
        }
        
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
        lastOffset = (scrlView?.contentOffset)!
        let yOfTextField = activeTextField.frame.height + 280
        if (yOfTextField - (lastOffset.y)) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            scrlView?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        scrlView?.setContentOffset(CGPointZero, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        objAnimView.removeFromSuperview()
    }
    
    // MARK: - API Response
    //Success response of AddSavingCardDelegate
    func successResponseForAddSavingCardDelegateAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String{
            if(message == "Successful")
            {
                if(objResponse["stripeCustomerStatusMessage"] as? String == "Customer Card detail Added Succeesfully")
                {
                    if(self.isFromGroupMemberPlan == true)
                    {
                        //Navigate to SAThankYouViewController
                        self.isFromGroupMemberPlan = false
                        NSUserDefaults.standardUserDefaults().setValue(1, forKey: "groupMemberPlan")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        let objThankyYouView = SAThankYouViewController()
                        self.navigationController?.pushViewController(objThankyYouView, animated: true)
                    }
                    else {
                        let objSummaryView = SASavingSummaryViewController()
                        self.navigationController?.pushViewController(objSummaryView, animated: true)
                    }
                    
                }
            }
        }
    }
    
    //Error response of AddSavingCardDelegate
    func errorResponseForAddSavingCardDelegateAPI(error: String) {
        objAnimView.removeFromSuperview()
        if(error == "No network found")
        {
        let alert = UIAlertView(title: "Sorry, the connection was lost.", message: "Please try again.", delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }else {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //Success response of AddNewSavingCardDelegate
    func successResponseForAddNewSavingCardDelegateAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String{
            if(message == "Successfull")
            {
                if(self.isFromGroupMemberPlan == true)
                {
                    //Navigate to showing group progress
                    self.isFromGroupMemberPlan = false
                    NSUserDefaults.standardUserDefaults().setValue(1, forKey: "groupMemberPlan")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    let objThankyYouView = SAThankYouViewController()
                    self.navigationController?.pushViewController(objThankyYouView, animated: true)
                    
                }else if(self.isFromImpulseSaving){
                    let objAPI = API()
                    objAPI.impulseSavingDelegate = self
                    
                    var newDict : Dictionary<String,AnyObject> = [:]
                    let userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
                    let cardDict = objResponse["card"] as? Dictionary<String,AnyObject>
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    newDict["STRIPE_CUSTOMER_ID"] = cardDict!["customer"]
                    newDict["PAYMENT_DATE"] = dateFormatter.stringFromDate(NSDate())
                    newDict["AMOUNT"] = NSUserDefaults.standardUserDefaults().valueForKey("ImpulseAmount")
                    newDict["PAYMENT_TYPE"] = "debit"
                    newDict["AUTH_CODE"] = "test"
                    newDict["PTY_SAVINGPLAN_ID"] = NSUserDefaults.standardUserDefaults().valueForKey("PTY_SAVINGPLAN_ID") as! NSNumber
                    print(newDict)
                    objAPI.impulseSaving(newDict)
                }
                else if(isFromEditUserInfo)
                {
                    let objSavedCardView = SASaveCardViewController()
                    objSavedCardView.isFromEditUserInfo = true
                    objSavedCardView.isFromImpulseSaving = true
                    objSavedCardView.showAlert = true
                    self.navigationController?.pushViewController(objSavedCardView, animated: true)
                }
                else {
                    let objSummaryView = SASavingSummaryViewController()
                    self.navigationController?.pushViewController(objSummaryView, animated: true)
                }
            }
        }
    }
    
    //error response of AddNewSavingCardDelegate
    func errorResponseForAddNewSavingCardDelegateAPI(error: String) {
        objAnimView.removeFromSuperview()
        if(error == "No network found")
        {
            let alert = UIAlertView(title: "Sorry, the connection was lost.", message: "Please try again.", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //Success response of ImpulseSavingDelegate
    func successResponseImpulseSavingDelegateAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let errorCode = objResponse["errorCode"] as? NSNumber
        {
            if (errorCode == 200)
            {
                self.isFromImpulseSaving = false
                let objImpulseView = SAImpulseSavingViewController()
                objImpulseView.isFromPayment = true
                self.navigationController?.pushViewController(objImpulseView, animated: true)
            }
        }else {
            let alert = UIAlertView(title: "Sorry, transaction is not completed", message: "Please try again.", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //Error response of ImpulseSavingDelegate
    func errorResponseForImpulseSavingDelegateAPI(error: String) {
        objAnimView.removeFromSuperview()
        if(error == "No network found")
        {
            let alert = UIAlertView(title: "Sorry, the connection was lost.", message: "Please try again.", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
    
}

