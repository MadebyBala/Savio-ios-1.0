//
//  SASavingSummaryViewController.swift
//  Savio
//
//  Created by Prashant on 08/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASavingSummaryViewController: UIViewController {
    //Set up IBoutlets
    // BackgroundView of Continue button
    @IBOutlet weak var continueButtonBackgroundView: UIView!
    // Set up top space dynamicaly
    @IBOutlet weak var topSpaceContonueView: NSLayoutConstraint!
    @IBOutlet weak var vwUpper : UIView?  // View to show Plan's image and description
    @IBOutlet weak var vwCongrats : UIView?
    @IBOutlet weak var vwScrContent : UIView?
    @IBOutlet weak var vwSummary : UIView?     // View for showing summary of plan
    @IBOutlet weak var vwOffer : UIView?       // View for showing offer's list
    @IBOutlet weak var vwOfferSubView : UIView?
    @IBOutlet weak var scrlVw : UIScrollView?    //IBOutlet for scrollview
    @IBOutlet weak var lblOffer : UILabel?       // IBOutlet for Lable on offer list
    @IBOutlet weak var btnContinue : UIButton?    //IBOutlet for continue button
    
    @IBOutlet weak var lblNextDebit: UILabel!
    @IBOutlet weak var htOfferView: NSLayoutConstraint!    // IBOutlet to assign height of offerView
    @IBOutlet weak var htContentView: NSLayoutConstraint!  // IBoutlet to assign height for contentview as per present subViews
    @IBOutlet weak var topSpaceForContinue: NSLayoutConstraint! // IBOutlet for assigning top space of continue button
    
    @IBOutlet weak var topBgImageView: UIImageView!    //IBOutlet for showing Plan image
    
    @IBOutlet weak var lblTitle: UILabel!               //IBOutlet for seeting plan titel
    
    @IBOutlet weak var paymentLastDate: UILabel!        //IBOutlet for showing Last EMI date
    
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    
    //-----------Setup IBOutlet to showing Invite user Name and contacts--------
    @IBOutlet weak var lblName1: UILabel?
    @IBOutlet weak var lblContact1: UILabel?
    
    @IBOutlet weak var lblName2: UILabel?
    @IBOutlet weak var lblContact2: UILabel?
    
    @IBOutlet weak var lblName3: UILabel?
    @IBOutlet weak var lblContact3: UILabel?
    
    @IBOutlet weak var lblName4: UILabel?
    @IBOutlet weak var lblContact4: UILabel?
    
    @IBOutlet weak var lblName5: UILabel?
    @IBOutlet weak var lblContact5: UILabel?
    
    @IBOutlet weak var lblName6: UILabel?
    @IBOutlet weak var lblContact6: UILabel?
    
    @IBOutlet weak var lblName7: UILabel?
    @IBOutlet weak var lblContact7: UILabel?
    
    //-----------------------------------------------------------------------------
    
    @IBOutlet weak var htDescriptionContentView: NSLayoutConstraint! // Set up hieght of plan's summary as per present subview
    
    var indexId : Int = 0  // Variable for showing wishlist count
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    
    var itemDataDict : Dictionary<String,AnyObject> = [:]
    
    var offersArray : Array<Dictionary<String,AnyObject>> = []
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    @IBOutlet weak var summaryViewHt: NSLayoutConstraint!  // Setup height of summary as per count of invited user
    var isUpdatePlan = false
    @IBOutlet weak var groupViewHt: NSLayoutConstraint!   // Height assign for Invited user's view
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView() // Setup summary UI
        
        //Customize View's titel
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function invoke on tapping continue button
    @IBAction func btnContinueClicked(sender: AnyObject) {
        // Navigate app as per plan type
        let str = itemDataDict["planType"] as! String
        //Navigate to showing individual/group progress screen
        NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAProgressViewController")
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAProgressViewController")
        
    }
    
    //Function invoking for set up UI as per the individual or group plan
    func setUpView(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("offerList")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        //  ----------------------------------------------------
        
        //--------------set Navigation left button------------
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        //----------------------------------------------------
        self.title = "Your plan" // Setting title of summary View
        
        //--------set Navigation right button nav-heart----------------------
        let btnName = UIButton()
        //        btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        //--------Hide all Invited user view for individual plan---------
        lblName1?.hidden = true
        lblName2?.hidden = true
        lblName3?.hidden = true
        lblName4?.hidden = true
        lblName5?.hidden = true
        lblName6?.hidden = true
        lblName7?.hidden = true
        
        lblContact1?.hidden = true
        lblContact2?.hidden = true
        lblContact3?.hidden = true
        lblContact4?.hidden = true
        lblContact5?.hidden = true
        lblContact6?.hidden = true
        lblContact7?.hidden = true
        //-------------------------------------------------------------
        groupViewHt.constant = 0.0
        
        //-------Setup the continue button UI---------------
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        btnContinue?.backgroundColor = self.setUpColor()
        continueButtonBackgroundView.backgroundColor = self.setUpShadowColor()
        continueButtonBackgroundView.layer.cornerRadius = 5
        btnContinue!.layer.cornerRadius = 5
        
        let objAPI = API()
        if let _ = objAPI.getValueFromKeychainOfKey("savingPlanDict") as? Dictionary<String,AnyObject>
        {
            itemDataDict = objAPI.getValueFromKeychainOfKey("savingPlanDict") as! Dictionary<String, AnyObject>
            
            //-------Check is invited user available or not and showing list----------------------------
            if let arr =  itemDataDict["INIVITED_USER_LIST"] as? Array<Dictionary<String,AnyObject>>
            {
                //Invited user list present
                if arr.count > 0 {
                    
                    //----------------Set up height as per invited user count-----------------------
                    let ht = (lblName1?.frame.origin.y)! + (CGFloat(arr.count) * (lblName1?.frame.size.height)!) as CGFloat
                    //            let ht = (lblName1?.frame.origin.y)! + (ct * (lblName1?.frame.size.height)!) as CGFloat
                    groupViewHt.constant = ht //+ 10
                    // --------------------------------------------------------------------
                    
                    //------Set Summary height as per invited user's view height----------
                    summaryViewHt.constant = (vwSummary?.frame.size.height)! + ht + 10
                    htContentView.constant = (vwScrContent?.frame.size.height)! + ht + 10
                    //------------------------------------------------------------------------
                    //-------------- Show invited user list--------------------------------------
                    for i in 0 ..< arr.count {
                        let dict = arr[i] as Dictionary<String, AnyObject>
                        var contactStr = ""
                        if dict["mobile_number"] != nil &&  dict["mobile_number"] as! String != "" {
                            contactStr = dict["mobile_number"] as! String
                        }
                        else {
                            contactStr = dict["email_id"] as! String
                        }
                        
                        switch i {
                        case 0:
                            lblName1?.hidden = false
                            lblContact1?.hidden = false
                            lblName1?.text = String(format: "%@ - ",dict["first_name"] as! String)
                            lblContact1?.text = contactStr
                            
                        case 1:
                            lblName2?.hidden = false
                            lblContact2?.hidden = false
                            lblName2?.text = String(format: "%@ - ",dict["first_name"] as! String)
                            lblContact2?.text = contactStr
                            
                        case 2:
                            lblName3?.hidden = false
                            lblContact3?.hidden = false
                            lblName3?.text = String(format: "%@ - ",dict["first_name"] as! String)
                            lblContact3?.text = contactStr
                            
                        case 3:
                            lblName4?.hidden = false
                            lblContact4?.hidden = false
                            lblName4?.text = String(format: "%@ - ",dict["first_name"] as! String)
                            lblContact4?.text = contactStr
                            
                        case 4:
                            lblName5?.hidden = false
                            lblContact5?.hidden = false
                            lblName5?.text = String(format: "%@ - ",dict["first_name"] as! String)
                            lblContact5?.text = contactStr
                            
                        case 5:
                            lblName6?.hidden = false
                            lblContact6?.hidden = false
                            lblName6?.text = String(format: "%@ - ",dict["first_name"] as! String)
                            lblContact6?.text = contactStr
                            
                        case 6:
                            lblName7?.hidden = false
                            lblContact7?.hidden = false
                            lblName7?.text = String(format: "%@ - ",dict["first_name"] as! String)
                            lblContact7?.text = contactStr
                            
                        default: print("Default Line Reached")
                        }
                    }
                    //------------------------------------------------------------------------------------
                    NSUserDefaults.standardUserDefaults().setValue(1, forKey: "groupPlan")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
                }
            }else {
                NSUserDefaults.standardUserDefaults().setValue(1, forKey: "individualPlan")
                NSUserDefaults.standardUserDefaults().synchronize()
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
            }
            
            //-----------------End of showing Invited user list-------------------------------------------
            
            //--------showing wishlist count--------------------------------------------------------------
            if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
            {
                let dataSave = str
                wishListArray = (NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>)!
                
                for i in 0 ..< wishListArray.count
                {
                    let dict = wishListArray[i] as Dictionary<String,AnyObject>
                    if(dict["id"] as? NSNumber == itemDataDict["id"] as? NSNumber)
                    {
                        indexId = i
                        break
                    }
                }
                
                let dataNew = NSKeyedArchiver.archivedDataWithRootObject(wishListArray)
                
                NSUserDefaults.standardUserDefaults().setObject(dataNew, forKey: "wishlistArray")
                NSUserDefaults.standardUserDefaults().synchronize()
                
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
            
            //-------------------------------------------------------------------------------------------------------------
            
            //Setup UI for showing plan image
            vwCongrats?.layer.borderColor = UIColor.whiteColor().CGColor
            vwCongrats?.layer.borderWidth = 2.0
            vwScrContent?.layer.cornerRadius = 1.0
            vwScrContent?.layer.masksToBounds = true
            
            //Setup border to summary view
            vwSummary?.layer.borderColor = UIColor.blackColor().CGColor
            vwSummary?.layer.borderWidth = 1.5
            
            lblOffer?.hidden = true
            //        topSpaceForContinue.constant = 30
            //        topSpaceContonueView.constant = 30
            self.view.bringSubviewToFront(btnContinue!)
            htOfferView.constant = 0
            
            
            //----------Setting up UI for showing offer list---------------------------------------
            if let arrOff = itemDataDict ["offers"] as? Array<Dictionary<String,AnyObject>>{
                //        let arrOff = itemDataDict ["offers"] as! Array<Dictionary<String,AnyObject>>
                var topMargin: CGFloat = 0.0   // variable for ste top margine for each offer
                for var i=0; i<arrOff.count; i++ {
                    
                    lblOffer?.hidden = false
                    // Load the SummaryPage view.
                    let summaryPageView = NSBundle.mainBundle().loadNibNamed("SummaryPage", owner: self, options: nil)[0] as! UIView
                    // Set its frame and data to pageview
                    topMargin = CGFloat(i) * 60 + 35
                    //                summaryPageView.frame = CGRectMake(0, topMargin + 10, (vwOffer?.frame.size.width)!, 55)
                    
                    summaryPageView.layer.cornerRadius = 3.0
                    summaryPageView.layer.masksToBounds = true
                    vwOffer?.addSubview(summaryPageView)
                    //Setting height of offer list view
                    htOfferView.constant = topMargin + 60
                    
                    //-------Setting Autolayout constrains to offer view-------------------------
                    summaryPageView.translatesAutoresizingMaskIntoConstraints = false
                    
                    let topConst = NSLayoutConstraint.init(item: summaryPageView, attribute: .Top, relatedBy: .Equal, toItem: vwOffer!, attribute: .Top, multiplier: 1, constant: topMargin)
                    
                    let leadingConst = NSLayoutConstraint.init(item: summaryPageView, attribute: .Leading, relatedBy: .Equal, toItem: vwOffer!, attribute: .Leading, multiplier: 1, constant: 0)
                    let trailingConst = NSLayoutConstraint.init(item: summaryPageView, attribute: .Trailing, relatedBy: .Equal, toItem: vwOffer!, attribute: .Trailing, multiplier: 1, constant: 0)
                    let htConst = NSLayoutConstraint.init(item: summaryPageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 55)
                    vwOffer?.addConstraints([topConst, leadingConst, trailingConst, htConst])
                    //-------------------------------------------------------------------------------
                    
                    //------Setting up values to offer view-------------------------------------------
                    let objDict = arrOff[i]
                    let lblTitle = summaryPageView.viewWithTag(1)! as! UILabel
                    lblTitle.text = objDict["offCompanyName"] as? String
                    lblTitle.hidden = false
                    
                    let lblDetail = summaryPageView.viewWithTag(2)! as! UILabel
                    lblDetail.text = objDict["offTitle"] as? String
                    
                    let lblOfferDetail = summaryPageView.viewWithTag(3)! as! UILabel
                    lblOfferDetail.text = objDict["offDesc"] as? String
                    
                    if let urlStr = objDict["offImage"] as? String
                    {
                        let urlStr = urlStr
                        let url = NSURL(string: urlStr)
                        let bgImageView = summaryPageView.viewWithTag(4) as! UIImageView
                        let request: NSURLRequest = NSURLRequest(URL: url!)
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                            if (data != nil && data?.length > 0) {
                                let image = UIImage(data: data!)
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    bgImageView.image = image
                                })
                            }
                        })
                    }
                    //--------------------------------------------------------------------------------
                }
                
            }
            //Setting up height of summary container view
            htDescriptionContentView.constant = continueButtonBackgroundView.frame.origin.y + continueButtonBackgroundView.frame.size.height + htOfferView.constant + (groupViewHt.constant - 10)
            
            htContentView.constant = (vwUpper?.frame.size.height)! + htDescriptionContentView.constant  //htContentView.constant + htOfferView.constant
            
            //Setting scrollview content size as per contentView
            scrlVw?.contentSize = CGSizeMake(0, htContentView.constant - 30)
            
            //SHOWING PLAN TITLE
            lblTitle.text = itemDataDict["title"] as? String
            //Showing plan amount
            if let amount = itemDataDict["amount"] as? String
            {
                lblPrice.text =  String(format:"£%@",amount)
            }
            else
            {
                lblPrice.text =  String(format:"£%d",(itemDataDict["amount"] as? NSNumber)!)
            }
            
            //Showing plan image
            if (itemDataDict["imageURL"] != nil) {
                
                let newDict =  itemDataDict["imageURL"]
                
                if newDict!["imageName.jpg"] != nil {
                    
                    if let data :NSData = NSData(base64EncodedString: (newDict!["imageName.jpg"] as? String)!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)! {
                        topBgImageView.contentMode = UIViewContentMode.ScaleAspectFill
                        topBgImageView.layer.masksToBounds = true
                        
                        topBgImageView.image = UIImage(data: data)
                    }
                }
            }
            
            // Set date as per date formatter
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            //lblDate.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
            
            lblDate.text = itemDataDict["PLAN_END_DATE"] as? String
            
            lblMonth.text =  String(format: "£%@", itemDataDict["emi"] as! String)
            
            //Calculation of last date of EMI
            if(itemDataDict["day"] as? String == "date")
            {
                // calculation as per selection month
                paymentLastDate.text =  "Monthly"
                let dateComponents = NSDateComponents()
                dateComponents.month = 1
                let calender = NSCalendar.currentCalendar()
                let newDate = calender.dateByAddingComponents(dateComponents, toDate: NSDate(), options:NSCalendarOptions(rawValue: 0))
                
                var pathComponents2 : NSArray!
                pathComponents2 = dateFormatter.stringFromDate(newDate!).componentsSeparatedByString("-")
                
                //            lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict["payDate"] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
                lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict["PAY_DATE"] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
            }
            else {
                //calculation as per week
                paymentLastDate.text = "Weekly"
                let daysToAdd : Double = 7
                let newDate = NSDate().dateByAddingTimeInterval(60*60*24 * daysToAdd)
                var pathComponents2 : NSArray!
                pathComponents2 = dateFormatter.stringFromDate(newDate).componentsSeparatedByString("-")
                
                //            lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict["payDate"] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
                lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict["PAY_DATE"] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlVw?.contentSize = CGSizeMake(0, (superContainerView?.frame.size.height)!)
        //        scrlVw?.contentSize = CGSizeMake(0, htContentView.constant)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    //function invoking on tapping on heart button
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
    
    //function invoking for set up button shadow color
    func setUpShadowColor()-> UIColor
    {
        return ColorCodes.colorForShadow(colorDataDict["savPlanID"] as! Int)
    }
    
    //function invoking for set up color as per the plan
    func setUpColor()-> UIColor
    {
        return ColorCodes.colorForCode(colorDataDict["savPlanID"] as! Int)
    }
    
}
