//
//  SASaveCardViewController.swift
//  Savio
//
//  Created by Maheshwari on 14/09/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASaveCardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GetListOfUsersCardsDelegate,SetDefaultCardDelegate,ImpulseSavingDelegate {
    
    @IBOutlet weak var cardListView: UITableView!
    @IBOutlet weak var cardViewOne: UIView!
    @IBOutlet weak var cardViewTwo: UIView!
    @IBOutlet weak var cardLastFourDigitTextField: UITextField!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var newCardButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewDoneButton: UIButton!
    @IBOutlet weak var bottomViewNewCardbutton: UIButton!
    
    var isFromImpulseSaving = false
    var isFromSavingPlan = false
    var isFromEditUserInfo = false
    var showAlert  = false
    var objAnimView = ImageViewAnimation()
    var savedCardArray : Array<Dictionary<String,AnyObject>> = []
    var cardListResponse : Dictionary<String,AnyObject> = [:]
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    func setUpView()
    {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        
        let btnName = UIButton()
        
        
        if(isFromEditUserInfo)
        {
            leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
            leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
            
            btnName.frame = CGRectMake(0, 0, 30, 30)
            btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
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
        }
        else{
            leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
            leftBtnName.addTarget(self, action: Selector("backButtonClicked"), forControlEvents: .TouchUpInside)
            
            btnName.frame = CGRectMake(0, 0, 60, 30)
            btnName.setTitle("Done", forState: UIControlState.Normal)
            btnName.setTitleColor(UIColor(red: 0.95, green: 0.69, blue: 0.25, alpha: 1), forState: UIControlState.Normal)
            btnName.titleLabel!.font = UIFont(name: kBookFont, size: 15)
            btnName.addTarget(self, action: Selector("doneBtnClicked"), forControlEvents: .TouchUpInside)
        }
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //set Navigation right button nav-heart
        
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        cardViewOne.layer.borderWidth = 1
        cardViewOne.layer.cornerRadius = 5
        cardViewOne.layer.borderColor = UIColor(red: 0.95, green: 0.69, blue: 0.25, alpha: 1).CGColor
        
        cardViewTwo.layer.borderWidth = 1
        cardViewTwo.layer.cornerRadius = 5
        cardViewTwo.layer.borderColor = UIColor(red: 0.97, green: 0.87, blue: 0.69, alpha: 1).CGColor
        
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(self.objAnimView)
        
        if var activeCard = NSUserDefaults.standardUserDefaults().valueForKey("activeCard") as? Dictionary<String,AnyObject>
        {
            if var trimmedString = activeCard["cardNumber"] as? String
            {
                trimmedString = (activeCard["cardNumber"] as! NSString).substringFromIndex(max(activeCard["cardNumber"]!.length-4,0))
                cardLastFourDigitTextField.text = trimmedString
            }
            else if let trimmedString =  activeCard["last4"] as? String{
                cardLastFourDigitTextField.text = trimmedString
            }
            
        }
        if(isFromEditUserInfo)
        {
            self.topView.hidden = false
            self.newCardButton.hidden  = true
            self.bottomView.hidden = false
            
            if(showAlert == true)
            {
                let alert = UIAlertView(title: "Alert", message: "This card will be saved as default card", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        
        let objAPI = API()
        objAPI.getListOfUsersCardDelegate = self
        objAPI.getWishListOfUsersCards()
        
    }
    
    //NavigationBar button methods
    func backButtonClicked()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func doneBtnClicked()
    {
        if let dict = NSUserDefaults.standardUserDefaults().valueForKey("activeCard") as? Dictionary<String,AnyObject>
        {
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            
            let objAPI = API()
            objAPI.setDefaultCardDelegate = self
            var newDict : Dictionary<String,AnyObject> = [:]
            newDict["STRIPE_CUST_ID"] = dict["customer"]
            newDict["CUST_DEFAULT_CARD"] = dict["id"]
            objAPI.setDefaultPaymentCard(newDict)
            
        } else{
            let alert = UIAlertView(title: "No data found", message: "Please try again later", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func heartBtnClicked(){
        
        if wishListArray.count>0{
            NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAWishListViewController")
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: "Wish list empty.", message: "You don’t have anything in your wish list yet. Get out there and set some goals!", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    // MARK: - Tableview Delegate & Datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return savedCardArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        //--------create custom cell from CardTableViewCell.xib------------
        let bundleArr : Array = NSBundle.mainBundle().loadNibNamed("CardTableViewCell", owner: nil, options: nil) as Array
        let cell = bundleArr[0] as! CardTableViewCell
        let dict = self.checkNullDataFromDict(savedCardArray[indexPath.row])
        
        let trimmedString: String = (dict["last4"] as? String)!
        //(dict["cardNumber"] as! NSString).substringFromIndex(max(dict["cardNumber"]!.length-4,0))
        let attributedString = NSMutableAttributedString(string: String(format: "%@ Ending in %@",dict["brand"] as! String,trimmedString))
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: UIColor.blackColor(),
                                      range: NSRange(
                                        location:0,
                                        length:(dict["brand"] as! String).characters.count))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: kMediumFont ,size: 15)!, range: NSRange(
            location:0,
            length:(dict["brand"] as! String).characters.count))
        
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: UIColor.blackColor(),
                                      range: NSRange(
                                        location:((dict["brand"] as! String).characters.count),
                                        length:11))
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: kLightFont,size: 15)!, range: NSRange(
            location:((dict["brand"] as! String).characters.count),
            length:11))
        
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: UIColor.blackColor(),
                                      range: NSRange(
                                        location:((dict["brand"] as! String).characters.count) + 11,
                                        length:trimmedString.characters.count))
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: kMediumFont,size: 15)!, range: NSRange(
            location:((dict["brand"] as! String).characters.count) + 11,
            length:trimmedString.characters.count))
        
        cell.cardHolderNameLabel.attributedText = attributedString
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:CardTableViewCell? = cardListView!.cellForRowAtIndexPath(indexPath)as? CardTableViewCell
        //Changing background color of selected row
        selectedCell!.contentView.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        
        let dict = self.checkNullDataFromDict(savedCardArray[indexPath.row])
        NSUserDefaults.standardUserDefaults().setValue(dict, forKey: "activeCard")
        NSUserDefaults.standardUserDefaults().synchronize()
        let trimmedString: String = (dict["last4"] as? String)!
        cardLastFourDigitTextField.text = trimmedString
        
    }
    
    @IBAction func addNewCardButtonPressed(sender: UIButton) {
        let objPaymentView = SAPaymentFlowViewController()
        objPaymentView.addNewCard = true
        if(isFromImpulseSaving)
        {
            objPaymentView.isFromImpulseSaving = true
        }
        else if(isFromEditUserInfo)
        {
            objPaymentView.isFromEditUserInfo = true
        }
        self.navigationController?.pushViewController(objPaymentView, animated: true)
    }
    
    //Go to SAEditUserInfoViewController
    @IBAction func profileButtonPressed(sender: UIButton) {
        let objEditUserInfo = SAEditUserInfoViewController(nibName: "SAEditUserInfoViewController", bundle: nil)
        self.navigationController?.pushViewController(objEditUserInfo, animated: true)
    }
    
    //Call the API to set selected card as Default card
    @IBAction func bottomviewDoneButtonPressed(sender: UIButton) {
        if let dict = NSUserDefaults.standardUserDefaults().valueForKey("activeCard") as? Dictionary<String,AnyObject>
        {
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            let objAPI = API()
            objAPI.setDefaultCardDelegate = self
            var newDict : Dictionary<String,AnyObject> = [:]
            newDict["STRIPE_CUST_ID"] = dict["customer"]
            newDict["CUST_DEFAULT_CARD"] = dict["id"]
            objAPI.setDefaultPaymentCard(newDict)
        } else{
            let alert = UIAlertView(title: "No data found", message: "Please try again later", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
    @IBAction func paymentButtonPressed(sender: UIButton) {
    }
    
    //function checking any key is null and return not null values in dictionary
    func checkNullDataFromDict(dict:Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject> {
        var replaceDict: Dictionary<String,AnyObject> = dict
        let blank = ""
        //check each key's value
        for var key:String in Array(dict.keys) {
            let ob = dict[key]! as? AnyObject
            //if value is Null or nil replace its value with blank
            if (ob is NSNull)  || ob == nil {
                replaceDict[key] = blank
            }
            else if (ob is Dictionary<String,AnyObject>) {
                replaceDict[key] = self.checkNullDataFromDict(ob as! Dictionary<String,AnyObject>)
            }
            else if (ob is Array<Dictionary<String,AnyObject>>) {
                
            }
        }
        
        return replaceDict
    }
    
     // MARK: - API Response
    //Success reponse of GetListOfUsersCardsDelegate
    func successResponseForGetListOfUsersCards(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String{
            if(message == "Successfully Received")
            {
                cardListResponse = checkNullDataFromDict(objResponse)
                let dict = cardListResponse["exCollection"] as! Dictionary<String, AnyObject>
                savedCardArray = dict["data"]! as! Array<Dictionary<String,AnyObject>>
                let newDict = self.checkNullDataFromDict(savedCardArray[0])
                NSUserDefaults.standardUserDefaults().setValue(newDict, forKey: "activeCard")
                cardListView.reloadData()
                cardListView.selectRowAtIndexPath(NSIndexPath(forRow:0,inSection: 0), animated: true, scrollPosition:UITableViewScrollPosition.Top)
                let selectedCell:CardTableViewCell? = cardListView!.cellForRowAtIndexPath(NSIndexPath(forRow:0,inSection: 0))as? CardTableViewCell
                //Changing background color of selected row
                selectedCell!.contentView.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
            }
        }
    }
    
    //Error reponse of GetListOfUsersCardsDelegate
    func errorResponseForGetListOfUsersCards(error: String) {
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    //Success reponse of SetDefaultCardDelegate
    func successResponseForSetDefaultCard(objResponse: Dictionary<String, AnyObject>)
    {
        let individualFlag = NSUserDefaults.standardUserDefaults().valueForKey("individualPlan") as! NSNumber
        let groupFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupPlan") as! NSNumber
        let groupMemberFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupMemberPlan") as! NSNumber
        if(isFromSavingPlan)
        {
            let objSummaryView = SASavingSummaryViewController()
            self.navigationController?.pushViewController(objSummaryView, animated: true)
            
        }
        else if (isFromImpulseSaving == true){
            let objAPI = API()
            objAPI.impulseSavingDelegate = self
            let dict = NSUserDefaults.standardUserDefaults().valueForKey("activeCard") as? Dictionary<String,AnyObject>
            var newDict : Dictionary<String,AnyObject> = [:]
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            newDict["STRIPE_CUSTOMER_ID"] = dict!["customer"]
            newDict["PAYMENT_DATE"] = dateFormatter.stringFromDate(NSDate())
            newDict["AMOUNT"] = NSUserDefaults.standardUserDefaults().valueForKey("ImpulseAmount")
            newDict["PAYMENT_TYPE"] = "debit"
            newDict["AUTH_CODE"] = "test"
            newDict["PTY_SAVINGPLAN_ID"] = NSUserDefaults.standardUserDefaults().valueForKey("PTY_SAVINGPLAN_ID") as! NSNumber
            print(newDict)
            objAPI.impulseSaving(newDict)
        }
        else {
            objAnimView.removeFromSuperview()
            //Navigate user to Progress screen
            if(individualFlag == 1)
            {
                NSUserDefaults.standardUserDefaults().setValue(1, forKey: "individualPlan")
                NSUserDefaults.standardUserDefaults().synchronize()
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
                
                let objProgressView = SAProgressViewController()
                self.navigationController?.pushViewController(objProgressView, animated: true)
            }
            else if(groupMemberFlag == 1 || groupFlag == 1)
            {   NSUserDefaults.standardUserDefaults().setValue(1, forKey: "groupPlan")
                NSUserDefaults.standardUserDefaults().synchronize()
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
                
                let objProgressView = SAGroupProgressViewController()
                self.navigationController?.pushViewController(objProgressView, animated: true)
            }
            else if(groupMemberFlag == 1)
            {
                NSUserDefaults.standardUserDefaults().setValue(1, forKey: "groupMemberPlan")
                NSUserDefaults.standardUserDefaults().synchronize()
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
                
                let objProgressView = SAGroupProgressViewController()
                self.navigationController?.pushViewController(objProgressView, animated: true)
            }
            
        }
    }
     //Success reponse of SetDefaultCardDelegate
    func errorResponseForSetDefaultCard(error: String) {
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    //Success reponse of ImpulseSavingDelegate
    func successResponseImpulseSavingDelegateAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let _ = objResponse["message"] as? String
        {
            self.isFromImpulseSaving = false
            let objImpulseView = SAImpulseSavingViewController()
            objImpulseView.isFromPayment = true
            self.navigationController?.pushViewController(objImpulseView, animated: true)
        }
        
    }
    
    //Success reponse of ImpulseSavingDelegate
    func errorResponseForImpulseSavingDelegateAPI(error: String) {
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        
    }
}
