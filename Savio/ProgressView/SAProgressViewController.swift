//
//  SAProgressViewController.swift
//  Savio
//
//  Created by Prashant on 21/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAProgressViewController: UIViewController,GetUsersPlanDelegate {
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    @IBOutlet weak var calculationLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var circularProgressOne: KDCircularProgress!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var makeImpulseSavingButton: UIButton!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    
    var objAnimView = ImageViewAnimation()
    var totalAmount : Float = 0.0
    var paidAmount : Float = 0.0
    var planTitle = ""
    let spinner =  UIActivityIndicatorView()
    var savingPlanDetailsDict : Dictionary<String,AnyObject> =  [:]
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        self.setUPNavigation()
        
        //Create obj of ImageViewAnimation to show user while  uploading/downloading something
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        savingPlanTitleLabel.hidden = true
        self.view.addSubview(objAnimView)
        
        //Create API class object to get usersSaving Plan
        let objAPI = API()
        objAPI.getSavingPlanDelegate = self
        objAPI.getUsersSavingPlan("i")
        
    }
    
    //This method is used to set the contentSize of UIScrollView
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlView.contentSize = CGSizeMake(3 * UIScreen.mainScreen().bounds.size.width, 0)
    }
    
    //set up navigation view
    func setUPNavigation()
    {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "My Plan"
        
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
        makeImpulseSavingButton!.layer.cornerRadius = 5
    }
    
    
    //set up the UIView
    func setUpView(){
        planTitle = String(format: "My %@ plan",savingPlanDetailsDict["title"] as! String)
        //create attribute text to savingPlanTitleLabel
        let attrText = NSMutableAttributedString(string: planTitle)
        attrText.addAttribute(NSFontAttributeName,
                              value: UIFont(
                                name: kMediumFont,
                                size: 16.0)!,
                              range: NSRange(
                                location: 3,
                                length: (savingPlanDetailsDict["title"] as! String).characters.count))
        
        savingPlanTitleLabel.attributedText = attrText
        savingPlanTitleLabel.hidden = false
        
        //get the total amount of plan from the Dictionary
        if let amount = savingPlanDetailsDict["amount"] as? NSNumber
        {
            totalAmount = amount.floatValue
        }
        //get the total paid amount of plan from the Dictionary
        if let totalPaidAmount = savingPlanDetailsDict["totalPaidAmount"] as? NSNumber
        {
            paidAmount = totalPaidAmount.floatValue
        }
        
        //Set page control pages
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        
        for i in 0 ..< 3
        {
            //load the CircularProgress.xib to create progress view
            let circularProgress = NSBundle.mainBundle().loadNibNamed("CircularProgress", owner: self, options: nil)[0] as! UIView
            circularProgress.frame = CGRectMake(CGFloat(i) * UIScreen.mainScreen().bounds.size.width,0,  scrlView.frame.size.width, scrlView.frame.size.height)
            scrlView.addSubview(circularProgress)
            
            //customization of KDCircularProgress
            let circularView = circularProgress.viewWithTag(1) as! KDCircularProgress
            circularView.startAngle = -90
            circularView.roundedCorners = true
            circularView.angle = Double((paidAmount * 360)/totalAmount)
            
            let labelOne = circularProgress.viewWithTag(3) as! UILabel
            let labelTwo = circularProgress.viewWithTag(2) as! UILabel
            let imgView = circularProgress.viewWithTag(4) as! UIImageView
            let activityIndicator = circularProgress.viewWithTag(6) as! UIActivityIndicatorView
            activityIndicator.hidden = false
            //check if plan has image
            if !(savingPlanDetailsDict["image"] is NSNull) {
                if let url = NSURL(string:savingPlanDetailsDict["image"] as! String)
                {
                    //load image from url
                    let request: NSURLRequest = NSURLRequest(URL: url)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                        if(data?.length > 0){
                            let image = UIImage(data: data!)
                            dispatch_async(dispatch_get_main_queue(), {
                                //Remove the activityIndicator after image load
                                imgView.image = image
                                activityIndicator.stopAnimating()
                                activityIndicator.hidden = true
                            })
                        }
                        else
                        {
                            //Remove the activityIndicator after image load
                            activityIndicator.stopAnimating()
                            activityIndicator.hidden = true
                        }
                    })
                }
                else {
                    //Remove the activityIndicator if image is not present
                    activityIndicator.stopAnimating()
                    activityIndicator.hidden = true
                }
            }
            else {
                activityIndicator.stopAnimating()
                activityIndicator.hidden = true
            }
            
            if(i == 0)
            {
                labelOne.hidden = true
                labelTwo.hidden = true
                imgView.hidden = false
                imgView.layer.cornerRadius = imgView.frame.width/2
            }
            else if(i == 1) {
                labelOne.hidden = false
                labelOne.text = "0.0%"
                labelTwo.hidden = false
                labelTwo.text = String(format: "£ %0.2f added",paidAmount)
                imgView.hidden = true
                activityIndicator.hidden = true
            }
            else {
                labelOne.hidden = false
                labelOne.text = String(format: "£ %0.2f",totalAmount - paidAmount)
                labelTwo.hidden = false
                labelTwo.text = "0 days to go"
                imgView.hidden = true
                activityIndicator.hidden = true
            }
        }
        
        //customization of plan button as per the psd
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.TopRight, .TopLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.CGPath
        self.planButton?.layer.mask = maskLayer
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
        if wishListArray.count>0{
            NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAWishListViewController")
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")        }
        else {
            let alert = UIAlertView(title: "Wish list empty.", message: "You don’t have anything in your wish list yet. Get out there and set some goals!", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }
    
    //UIPageView control method
    @IBAction func changePage(sender: AnyObject) {
        var newFrame = scrlView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        //scroll the content view so that the area defined by newFrame will be visible inside the scroll view
        scrlView!.scrollRectToVisible(newFrame, animated: true)
    }
    
    //Goto stats tab
    @IBAction func clickOnStatButton(sender:UIButton){
        if let title = savingPlanDetailsDict["title"] as? String
        {
            let obj = SAStatViewController()
            obj.itemTitle = title
            obj.planType = "Individual"
            obj.cost =  String(format:"%@",savingPlanDetailsDict["amount"] as! NSNumber)
            obj.endDate = savingPlanDetailsDict["planEndDate"] as! String
            self.navigationController?.pushViewController(obj, animated: false)
        }
        else {
            let alert = UIAlertView(title: "No data found", message: "Please try again later", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    @IBAction func offersButtonPressed(sender: AnyObject) {
        let obj = SAOfferListViewController()
        obj.savID = 63
        //save the Generic plan in NSUserDefaults, so it will show its specific offers
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        obj.hideAddOfferButton = false
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func spendButtonPressed(sender: AnyObject) {
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        self.navigationController?.pushViewController(objPlan, animated: false)
    }
    
    @IBAction func impulseSavingButtonPressed(sender: UIButton) {
        let objImpulseSave = SAImpulseSavingViewController()
        self.navigationController?.pushViewController(objImpulseSave, animated: true)
    }
    
    //get users plan delegate methods
    func successResponseForGetUsersPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let message = objResponse["message"] as? String
        {
            if(message == "Success")
            {
                savingPlanDetailsDict = objResponse["partySavingPlan"] as! Dictionary<String,AnyObject>
                self.setUpView()
            }
            else {
                pageControl.hidden = true
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else {
            pageControl.hidden = true
            let alert = UIAlertView(title: "Alert", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        objAnimView.removeFromSuperview()
    }
    
    func errorResponseForGetUsersPlanAPI(error: String) {
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView.removeFromSuperview()
    }
}
