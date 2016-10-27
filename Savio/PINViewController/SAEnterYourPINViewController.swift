//
//  SAEnterYourPINViewController.swift
//  Savio
//
//  Created by Maheshwari  on 21/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAEnterYourPINViewController: UIViewController,UITextFieldDelegate,OTPSentDelegate,LogInDelegate,UIScrollViewDelegate {
    @IBOutlet weak var btnVwBg: UIView!
    @IBOutlet weak var pinTextFieldsContainerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet weak var passcodeDoesNotMatchLabel: UILabel!
    @IBOutlet weak var btnForgottPasscode: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblSentYouCode: UILabel!
    @IBOutlet weak var lblForgottonYourPasscode: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgotPasscodeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var textFieldOne: UITextField!
    @IBOutlet weak var textFieldTwo: UITextField!
    @IBOutlet weak var textFieldThree: UITextField!
    @IBOutlet weak var textFieldFour: UITextField!
    @IBOutlet weak var enterYourPasscodeLabel: UILabel!
    @IBOutlet weak var registerButtonBackgroundView: UIView!
    @IBOutlet weak var scrlView: UIScrollView!
    
    var lastOffset: CGPoint = CGPointZero
    var activeTextField = UITextField()
    var objAnimView = ImageViewAnimation()
    let objAPI = API()
    var userInfoDict = Dictionary<String,AnyObject>()
    var arrayTextFields: Array<UITextField>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customizeTextFields()
        
        // Do any additional setup after loading the view.
        //change the border color and placeholder color of UITextField
        
        //Add shadowcolor to UIButtons
        
        registerButton.layer.cornerRadius = 5
        btnVwBg.layer.cornerRadius = 5
      
        loginButton.layer.cornerRadius = 5
        
        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        //add custom tool bar for UITextField
        let customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed:"))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBarButtonPressed:"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar.items = [cancelButton,flexibleSpace,acceptButton]
        
        self.arrayTextFields = [textFieldOne,
                                textFieldTwo,
                                textFieldThree,
                                textFieldFour]
        
        for tf: UITextField in arrayTextFields {
            tf.inputAccessoryView = customToolBar
        }

    }
    
    func doneBarButtonPressed(sender: AnyObject) {
        activeTextField.resignFirstResponder()
        self.removeKeyboardNotification()
    }
    
    func cancelBarButtonPressed(sender: AnyObject) {
        activeTextField.resignFirstResponder()
        self.removeKeyboardNotification()
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
        let yOfTextField = activeTextField.frame.height + pinTextFieldsContainerView.frame.origin.y
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
    

    //UITextField delegate method
    func textFieldDidBeginEditing(textField: UITextField) {
         activeTextField = textField
        self.registerForKeyboardNotifications()
        errorLabel.hidden = true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        errorLabel.hidden = true
        textField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        let currentCharacterCount = textField.text?.characters.count ?? 0
        let newLength = currentCharacterCount + string.characters.count
        if (newLength > 1) {
            return false;
        }
        return true;
    }
    
    
    @IBAction func clickOnRegisterButton(sender: AnyObject) {
        if(registerButton.titleLabel?.text == "Register")
        {
            let saRegisterViewController = SARegistrationViewController(nibName:"SARegistrationViewController",bundle: nil)
            self.navigationController?.pushViewController(saRegisterViewController, animated: true)
        }
        else  {
            //Send the OTP to mobile number
            
            //Get the user details from Keychain
            //
            //            let objCreatePINView = CreatePINViewController(nibName: "CreatePINViewController",bundle: nil)
            //            self.navigationController?.pushViewController(objCreatePINView, animated: true)
            //
            
            objAPI.otpSentDelegate = self;
            objAPI.getOTPForNumber(userInfoDict["phone_number"]! as! String, country_code: "91")
            
            //Add animation of logo
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            
            objAnimView.animate()
            self.view.addSubview(objAnimView)
        }
        
    }
    
    @IBAction func clickedOnForgotPasscode(sender: AnyObject) {
        
        lblSentYouCode.hidden = false
        lblForgottonYourPasscode.hidden = false
        btnCancel.hidden = false
        registerButton .setTitle("Send me a code", forState: UIControlState.Normal)
        registerButtonBackgroundView.hidden = false
        registerButton.hidden = false
        forgotPasscodeButton.hidden = true
        loginButton.hidden = true
        btnVwBg.hidden = true
        checkString = "ForgotPasscode"
        errorLabel.hidden = true
        pinTextFieldsContainerView.hidden = true
        
        enterYourPasscodeLabel.hidden = true
        textFieldOne.resignFirstResponder()
        textFieldTwo.resignFirstResponder()
        textFieldThree.resignFirstResponder()
        textFieldFour.resignFirstResponder()
        textFieldOne.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        textFieldTwo.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        textFieldThree.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        textFieldFour.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
    }
    
    
    @IBAction func onClickCancelButton(sender: AnyObject) {
        
        lblSentYouCode.hidden = true
        lblForgottonYourPasscode.hidden = true
        btnCancel.hidden = true
        registerButton.hidden = true
        
        registerButton .setTitle("Register", forState: UIControlState.Normal)
        registerButtonBackgroundView.hidden = true
        forgotPasscodeButton.hidden = false
        loginButton.hidden = false
        btnVwBg.hidden = false
        pinTextFieldsContainerView.hidden = false
        enterYourPasscodeLabel.hidden = false
        
    }
    
    @IBAction func clickOnLoginButton(sender: AnyObject) {
        //LogInButton click
        if(textFieldOne.text == "" || textFieldTwo.text == ""  || textFieldThree.text == ""  || textFieldFour.text == ""  )
        {
            //Show error when field is empty
            
            errorLabel.hidden = false
            errorLabel.text = "Please enter passcode"
            
            if  textFieldOne.text == "" {
                textFieldOne.layer.borderColor = UIColor.redColor().CGColor
            }
            if  textFieldTwo.text == "" {
                textFieldTwo.layer.borderColor = UIColor.redColor().CGColor
            }
            if  textFieldThree.text == "" {
                textFieldThree.layer.borderColor = UIColor.redColor().CGColor
            }
            if  textFieldFour.text == "" {
                textFieldFour.layer.borderColor = UIColor.redColor().CGColor
            }
        }
        else
        {
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            objAPI.logInDelegate = self;
            objAnimView.animate()
            self.view.addSubview(objAnimView)
            
            var userDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
            var param = Dictionary<String,AnyObject>()
            param["userID"] = userDict["partyId"]
            let pinPassword = textFieldOne.text! + textFieldTwo.text! + textFieldThree.text! + textFieldFour.text!
            param["pin"] = pinPassword.MD5()
            
            if let apnsDeviceToken = NSUserDefaults.standardUserDefaults().valueForKey("APNSTOKEN") as? NSString
            {
                param["PNS_DEVICE_ID"] =  apnsDeviceToken
                
            } else {
                param["PNS_DEVICE_ID"] =  ""
            }
            objAPI.logInWithUserID(param)
        }
    }
    
    func setAllPinEntryFieldsToColor(color: UIColor) {
        textFieldOne.layer.borderColor = color.CGColor
        textFieldTwo.layer.borderColor = color.CGColor
        textFieldThree.layer.borderColor = color.CGColor
        textFieldFour.layer.borderColor = color.CGColor
    }
    
    //LogIn Delegate Methods
    
    func successResponseForLogInAPI(objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        let dict = objResponse["party"]
        let udidDict = dict!["deviceRegistration"] as! Array<Dictionary<String,AnyObject>>
        let udidArray = udidDict[0]
        userInfoDict["cookie"] = udidArray["COOKIE"] as! String
        objAPI.storeValueInKeychainForKey("userInfo", value: userInfoDict)
        
        let passcode = self.textFieldOne.text! + self.textFieldTwo.text! + self.textFieldThree.text! + self.textFieldFour.text!
        objAPI.storeValueInKeychainForKey("myPasscode", value: passcode.MD5())
        
        let groupPlan = objResponse["G"] as! NSNumber
        let individualPlan = objResponse["I"] as! NSNumber
        let groupMemberPlan = objResponse["GM"] as! NSNumber
        
     //Store the plan info in NSUserDefaults
        NSUserDefaults.standardUserDefaults().setObject(groupPlan, forKey: "groupPlan")
        NSUserDefaults.standardUserDefaults().setObject(individualPlan, forKey: "individualPlan")
        NSUserDefaults.standardUserDefaults().setObject(groupMemberPlan, forKey: "groupMemberPlan")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.setUpMenu(groupPlan, individual: individualPlan, member: groupMemberPlan)
        
        if (groupPlan == 1 || individualPlan == 1 || groupMemberPlan == 1) {
                let objContainer = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
                self.navigationController?.pushViewController(objContainer, animated: true)
        
        }else {
            let objHurrrayView = HurreyViewController(nibName:"HurreyViewController",bundle: nil)
            self.navigationController?.pushViewController(objHurrrayView, animated: true)
        }
    }

    func errorResponseForOTPLogInAPI(error: String) {
        objAnimView.removeFromSuperview()
        if(error == "No network found")
        {
            let alert = UIAlertView(title: "Warning", message: "No network found", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }

        else if(error == "Passcode is incorrect")
        {
            errorLabel.hidden = false
            errorLabel.text = "Passcode is not correct"
            textFieldOne.text = ""
            textFieldTwo.text = ""
            textFieldThree.text = ""
            textFieldFour.text = ""
            self.setAllPinEntryFieldsToColor( UIColor.redColor())
        }
        else
        {
            let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
    
    
    func setUpMenu(group:NSNumber,individual:NSNumber,member:NSNumber)  {
        var className :String = ""
        
        if individual == 1 {
            className = "individualPlan"
        }
        else if group == 1 {
            className = "groupPlan"
        }
        else if member == 1 {
            className = "groupMemberPlan"
        }
        else {
            className = ""
        }
        NSUserDefaults.standardUserDefaults().setObject(className, forKey: "ShowProgress")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    //OTP Verification Delegate Method
    func successResponseForOTPSentAPI(objResponse:Dictionary<String,AnyObject>)
    {
        objAnimView.removeFromSuperview()
        let fiveDigitVerificationViewController = FiveDigitVerificationViewController(nibName:"FiveDigitVerificationViewController",bundle: nil)
        self.navigationController?.pushViewController(fiveDigitVerificationViewController, animated: true)
    }
    func errorResponseForOTPSentAPI(error:String){
        objAnimView.removeFromSuperview()
        if(error == "No network found")
        {
            let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else if (error == "The request timed out")
        {
            let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else
        {
        
        let fiveDigitVerificationViewController = FiveDigitVerificationViewController(nibName:"FiveDigitVerificationViewController",bundle: nil)
        self.navigationController?.pushViewController(fiveDigitVerificationViewController, animated: true)
        }
        
    }
    
    
    func customizeTextFields() {
        self.setAllPinEntryFieldsToColor( UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1))
        
        let borderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 3
        
        textFieldOne.layer.borderWidth = borderWidth
        textFieldOne.layer.cornerRadius = cornerRadius
        textFieldOne.layer.masksToBounds = true
        
        
        textFieldTwo.layer.borderWidth = borderWidth
        textFieldTwo.layer.cornerRadius = cornerRadius
        textFieldTwo.layer.masksToBounds = true
        
        textFieldThree.layer.borderWidth = borderWidth
        textFieldThree.layer.cornerRadius = cornerRadius
        textFieldThree.layer.masksToBounds = true
        
        textFieldFour.layer.borderWidth = borderWidth
        textFieldFour.layer.cornerRadius = cornerRadius
        textFieldFour.layer.masksToBounds = true
        
        textFieldFour.keyboardType = UIKeyboardType.NumberPad
        
        textFieldOne.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        textFieldTwo.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        textFieldThree.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        textFieldFour.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        
        let text = textField.text
        var tag = textField.tag
        if text?.utf16.count==1{
            for tf: UITextField in arrayTextFields {
                if tf.tag == tag && tag != 3 {
                    let tfNext = arrayTextFields[tag + 1]
                    tfNext.becomeFirstResponder()
                    break
                }
                else if tag == 3 {
                    textField.resignFirstResponder()
                    break
                }
            }
            
        }else {
            
            for idx in 0...tag {
                tag -= 1
                if tag >= 0 {
                    let tfPre = arrayTextFields[tag]
                    if tfPre.text?.characters.count > 0 {
                        tfPre.becomeFirstResponder()
                        break
                    }
                }
            }
            
        }
    }
    
    @IBAction func bgViewTapped(sender: AnyObject) {
        textFieldOne.resignFirstResponder()
        textFieldTwo.resignFirstResponder()
        textFieldThree.resignFirstResponder()
        textFieldFour.resignFirstResponder()
    }
    
}
