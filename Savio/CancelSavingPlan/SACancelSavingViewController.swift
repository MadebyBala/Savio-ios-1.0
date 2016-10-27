//
//  SACancelSavingViewController.swift
//  Savio
//
//  Created by Maheshwari on 07/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SACancelSavingViewController: UIViewController,CancelSavingPlanDelegate {
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var wouldYouLikeToStartNewSavingPlanLabel: UILabel!
    @IBOutlet weak var yourMoneyWillBeReturnLabel: UILabel!
    @IBOutlet weak var cancelDetailLabel: UILabel!
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var  objAnimView = ImageViewAnimation()
    
    //MARK: ViewController lifeCycle method.  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        
        //set attributed text for UILabel
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.alignment = NSTextAlignment.Center
        let attrString = NSMutableAttributedString(string: "Cancelling your plan will stop all regular top ups. Your money will remain on your Savio card and you are able to use it in ATMs and shops as usual.")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        cancelDetailLabel.attributedText = attrString
        
        let attrStringForWouldYouLikeToStartNewSavingPlanLabel = NSMutableAttributedString(string: "Would you like to start a new plan?")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        wouldYouLikeToStartNewSavingPlanLabel.attributedText = attrStringForWouldYouLikeToStartNewSavingPlanLabel
        
        let attrStringForYourMoneyWillBeReturnLabelLabel = NSMutableAttributedString(string: "Your money will returned to your bank in the next 5-10 working days.")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        yourMoneyWillBeReturnLabel.attributedText = attrStringForYourMoneyWillBeReturnLabelLabel
        
        self.setUpView()
    }
 
    //Set up the UIView
    func setUpView(){
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.title = "Plan setup"
        
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
        
        //Check if NSUserDefaults.standardUserDefaults() has value for "wishlistArray"
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
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        if wishListArray.count>0{
            //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
            NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAWishListViewController")
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: "Wish list empty.", message: "You don’t have anything in your wish list yet. Get out there and set some goals!", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    @IBAction func keepSavingButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    //Call the API for cancelling the saving plan
    @IBAction func yesButtonPressed(sender: AnyObject) {
        self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        self.objAnimView.frame = self.view.frame
        self.objAnimView.animate()
        self.navigationController!.view.addSubview(self.objAnimView)
        
        let objAPI = API()
        objAPI.cancelSavingPlanDelegate = self
        objAPI .cancelSavingPlan()
    }
    
    //success rsponse of CancelSavingPlanDelegate
    func successResponseForCancelSavingPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String
        {
            if (message == "Cancelled Plan successfully")
            {
                //Remove the individualPlan's value from NSUserDefaults
                NSUserDefaults.standardUserDefaults().setValue(0, forKey: "individualPlan")
                NSUserDefaults.standardUserDefaults().synchronize()
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
                view1.hidden = true
                view2.hidden = false
            }
            else {
                let alert = UIAlertView(title: "Alert", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            
        }
        else  if let message = objResponse["error"] as? String{
            let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
    
    //error rsponse of CancelSavingPlanDelegate
    func errorResponseForCancelSavingPlanAPI(error: String) {
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    //Your saving plan is canceled, go to create new saving plan
    @IBAction func startNewSavingPlanButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SACreateSavingPlanViewController")
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SACreateSavingPlanViewController")
    }
}
