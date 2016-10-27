//
//  SAImpulseSavingViewController.swift
//  Savio
//
//  Created by Maheshwari on 07/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

extension String {
    func chopPrefix(count: Int = 1) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(count))
    }
    
    func chopSuffix(count: Int = 1) -> String {
        return self.substringFromIndex(self.endIndex.advancedBy(-count))
    }
}

import UIKit

class SAImpulseSavingViewController: UIViewController {
    @IBOutlet weak var addFundsButton: UIButton!
    @IBOutlet weak var deductMoneyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var anotherStepLabel: UILabel!
    @IBOutlet weak var savedPaymentLabel: UILabel!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var messagePopupImageView: UIImageView!
    @IBOutlet weak var messagePopUpView: UIView!
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var addFundsViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var circularViewTopSpace: NSLayoutConstraint!
    
    var isFromPayment = false
    var circleSlider: CircleSlider! {
        didSet {
            self.circleSlider.tag = 0
        }
    }
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    private var valueLabel: UILabel!
    private var progressLabel: UILabel!
    private var timer: NSTimer?
    private var progressValue: Float = 0
    var lastOffset: CGPoint = CGPointZero
    private var sliderOptions: [CircleSliderOption] {
        return [
            .BarColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1)),
            .ThumbImage(UIImage (named: "slider-handle@2x.png")),
            .TrackingColor(UIColor(red: 244/255, green: 176/255, blue: 58/255, alpha: 1)),
            .BarWidth(20),
            .StartAngle(-90),
            .MaxValue(3000),
            .MinValue(0),
            .ThumbWidth(40)
        ]
    }
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildCircleSlider()
        self.setUpView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(isFromPayment)
        {
            messagePopUpView.hidden = true
            circularView.backgroundColor = UIColor(red : 244/255,
                                                   green : 172/255,
                                                   blue : 58/255, alpha: 1)
            circularView.layer.cornerRadius = circularView.frame.height / 2
            priceTextField.hidden = true
            if let _ = NSUserDefaults.standardUserDefaults().valueForKey("ImpulseAmount") as? String
            {
               priceLabel.text = String(format:"£%@",(NSUserDefaults.standardUserDefaults().valueForKey("ImpulseAmount") as? String)!)
            }else {
                priceLabel.text = "£0"
            }
            
            circleSlider.hidden = true
            priceLabel.hidden = false
            anotherStepLabel.hidden = false
            savedPaymentLabel.hidden = false
            addFundsButton.setTitle("Continue", forState: .Normal)
            addFundsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            addFundsButton.backgroundColor = UIColor(red : 244/255,
                                                     green : 172/255,
                                                     blue : 58/255, alpha: 1)
            deductMoneyLabel.text = String(format:"Your payment of £%@ has been added to your saving plan.",(NSUserDefaults.standardUserDefaults().valueForKey("ImpulseAmount") as? String)!)
            isFromPayment = false
            
  
            circularViewTopSpace.constant = 10
        }
        else {
          
            circularViewTopSpace.constant = 70
            deductMoneyLabel.text = ""
            }
    }
    //customization of circle slider
    private func buildCircleSlider() {
        self.circleSlider = CircleSlider(frame: CGRectMake(0, 0, circularView.frame.size.width, circularView.frame.size.height), options: self.sliderOptions)
        self.circleSlider?.addTarget(self, action: Selector("valueChange:"), forControlEvents: .ValueChanged)
        self.valueLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.valueLabel.textAlignment = .Center
        self.valueLabel.center = CGPoint(x: CGRectGetWidth(self.circleSlider.bounds) * 0.5, y: CGRectGetHeight(self.circleSlider.bounds) * 0.5)
        self.circleSlider.addSubview(self.valueLabel)
        circularView.addSubview(circleSlider)
    }
    
    
    //Circle slider action method
    func valueChange(sender: CircleSlider) {
       // messagePopUpView.hidden = true
        let attrString2 = NSAttributedString(string: String(format:"£%d",Int(sender.value)), attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,NSFontAttributeName:UIFont(name: kMediumFont, size: 32)!])
     
        priceTextField.attributedText = attrString2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlView.contentSize = CGSizeMake(0, UIScreen.mainScreen().bounds.height + 20)
        
        //add rounded corners to plan button
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.TopRight, .TopLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.CGPath
        self.planButton?.layer.mask = maskLayer
    }
    
    func setUpView(){
        
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.title = "Add more funds"
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = str
            wishListArray = (NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>)!
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
            }
            btnName.setTitle(String(format:"%d",wishListArray.count), forState: UIControlState.Normal)
        }
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        var customToolBar : UIToolbar?
        customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        customToolBar!.items = [acceptButton]
        priceTextField.inputAccessoryView = customToolBar
        priceTextField.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
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
            circleSlider.value = 3000
            let alert = UIAlertView(title: "Warning", message: "Please enter cost less than £ 3000", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            self.removeKeyboardNotification()
            return false
        }
        if combinedString.characters.count < 6 {
            
            circleSlider.value = Float(valueString)!
        }
        return false
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
        let yOfTextField = priceTextField.frame.height
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
    
    
    //UITextfieldDelegate method
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        messagePopUpView.hidden = true
        self.registerForKeyboardNotifications()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.removeKeyboardNotification()
        return true
    }
    
    @IBAction func offersButtonPressed(sender: AnyObject) {
        let obj = SAOfferListViewController()
        obj.savID = 92
        //save the Generic plan in NSUserDefaults, so it will show its specific offers
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        obj.hideAddOfferButton = true
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    //Go to SASpendViewController
    @IBAction func spendButtonPressed(sender: AnyObject) {
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        self.navigationController?.pushViewController(objPlan, animated: false)
    }
    
    func doneBarButtonPressed(){
        var tfString: String = priceTextField.text!
        tfString = tfString.chopPrefix(1)
        priceTextField.resignFirstResponder()
    
        if(Float(tfString) > 3000) {
            let alert = UIAlertView(title: "Warning", message: "Please enter cost less than £ 3000", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        self.removeKeyboardNotification()
        
    }
    
    @IBAction func addFundsButtonPressed(sender: AnyObject) {
        if(addFundsButton.titleLabel?.text == "MAKE PAYMENT")
        {
            var tfString: String = priceTextField.text!
            tfString = tfString.chopPrefix(1)
            if(tfString == "00")
            {
                let alert = UIAlertView(title: "Warning", message: "Please enter cost more than £ 0", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else {
                NSUserDefaults.standardUserDefaults().setValue(tfString, forKey: "ImpulseAmount")
                NSUserDefaults.standardUserDefaults().synchronize()
                let objSavedCardView = SASaveCardViewController()
                objSavedCardView.isFromImpulseSaving = true
                self.navigationController?.pushViewController(objSavedCardView, animated: true)
            }
    
        }
        else
        {
            if let plan = NSUserDefaults.standardUserDefaults().valueForKey("usersPlan") as? String
            { //Individual plan
                if(plan == "individualPlan")
                {
                    let objProgressView = SAProgressViewController()
                    self.navigationController?.pushViewController(objProgressView, animated: true)
                   
                }
                else if(plan == "groupPlan")
                {
                    let objProgressView = SAGroupProgressViewController()
                    self.navigationController?.pushViewController(objProgressView, animated: true)
                }
                else if(plan == "groupMemberPlan")
                {
                    let objProgressView = SAGroupProgressViewController()
                    self.navigationController?.pushViewController(objProgressView, animated: true)
                }
            }

        }
    }
    
    
    func heartBtnClicked(){
        //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
        if wishListArray.count>0{
            NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAWishListViewController")
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: "Wish list empty.", message: "You don’t have anything in your wish list yet. Get out there and set some goals!", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
}
