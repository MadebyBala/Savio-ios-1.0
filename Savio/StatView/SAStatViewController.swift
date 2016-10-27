//
//  SAStatViewController.swift
//  Savio
//
//  Created by Prashant on 27/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
import Social
import Google
import SafariServices

class SAStatViewController: UIViewController, LineChartDelegate, UIDocumentInteractionControllerDelegate,SFSafariViewControllerDelegate {
    
    @IBOutlet weak var GraphContentView: UIView! //IBOutlet for Graph container
    @IBOutlet weak var scrHt: NSLayoutConstraint! //IBOutlet to set scrollview height
    @IBOutlet weak var scrlView: UIScrollView?   //IBOutlet for scrollview
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var offersButton: UIButton!   //IBoutlet for offer tab button
    @IBOutlet weak var planButton: UIButton!     //IBOutlet for plan tab button
    @IBOutlet weak var spendButton: UIButton!    //IBOutlet for spend tab button
    @IBOutlet weak var makeImpulseBtn: UIButton!  //IBOutlet for make impules button
    @IBOutlet var scrollViewForGraph: UIScrollView!   //IBOutlet for scrollview to scroll graph hotizantal
    @IBOutlet var widthOfContentView: NSLayoutConstraint!  //IBoutlet to set width of contentview
    @IBOutlet var graphSliderView: UISlider!               //IBOutlet for slider view
    @IBOutlet weak var sharingVw: UIView?                  //IBOutlet for social sharing popup.
    @IBOutlet weak var lbl: UILabel?
    
    var planType = ""   //Variable for identifying plan type
    var lineChart: LineChart! //Object of LineChart class to draw Line chart
    var label = UILabel()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var itemTitle = ""
    var endDate = ""
    var cost = ""
    var xLabels: [String] = [] //Array for holding x-axis lable
    var documentInteractionController = UIDocumentInteractionController()  // UIDocumentInteractionController object for sharing data to whatsapp friends
    var shareImg: UIImage?
    
    // MARK: - View life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting up Stat view UI
        self.setUpView()
        //--------------Draw Line chart on graph contentview----------------------------
        lineChart = LineChart()
        lineChart.planTitle = self.planType
        lineChart.maximumValue = 3000
        lineChart.minimumValue = 0
        let data: [CGFloat] = [0,600,600-1,-1]
        
        // simple line with custom x axis labels // hear need to pass json value
        xLabels = ["1","2","3","4","5"]
        lineChart.animation.enabled = true
        lineChart.area = true
        // hide grid line Visiblity
        lineChart.x.grid.visible = true
        lineChart.y.grid.visible = true
        
        // hide dots visiblety in line chart
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = CGFloat(data.count)
        lineChart.x.grid.color = UIColor.grayColor()
        lineChart.y.grid.count = CGFloat(xLabels.count)
        lineChart.y.grid.color = UIColor.grayColor()
        lineChart.scrollViewReference = self.scrollViewForGraph
        
        lineChart.x.labels.values = xLabels
        lineChart.y.labels.visible = true
        lineChart.addLine(data)
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        
        self.contentView?.addSubview(lineChart)
        //------------------------------------------------------------------------------------
    }
    
    //Function invoke for formatting graph as per plan type.
    func chartVerticalLineDrawingCompleted() {
        if planType == "Individual" {
            GraphContentView.backgroundColor = UIColor(red: 252/255,green:246/255,blue:236/255,alpha:1)
            lineChart.thumbImgView.image = UIImage(named: "generic-stats-slider-tab")
            lineChart.graphMovingVerticalLine.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        }
        else {
            GraphContentView.backgroundColor = UIColor(red: 239/255,green:247/255,blue:253/255,alpha:1)
            lineChart.thumbImgView.image = UIImage(named: "group-save-stats-slider-tab")
            lineChart.graphMovingVerticalLine.backgroundColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1)
        }
    }
    
    //MARK: -
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var views: [String: AnyObject] = [:]
        views["chart"] = lineChart
        if xLabels.count > 5 {
            self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[chart]-|", options: [], metrics: nil, views: views))
            let offsetSpace = 70
            let constant = String.init(format: "H:|-[chart(%d)]-|", xLabels.count * offsetSpace)
            self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constant, options: [], metrics: nil, views: views))
            self.widthOfContentView.constant = CGFloat( xLabels.count * offsetSpace)
            self.scrollViewForGraph.contentSize = CGSize(width: CGFloat( xLabels.count * offsetSpace), height: self.scrollViewForGraph.frame.height)
        }
        else  {
            self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: [], metrics: nil, views: views))
            self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[chart]-|", options: [], metrics: nil, views: views))
            self.widthOfContentView.constant = self.scrollViewForGraph.frame.width
            self.scrollViewForGraph.contentSize = CGSize(width: self.scrollViewForGraph.frame.width, height: self.scrollViewForGraph.frame.height)
            
        }
        //add rounded corners plan button
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.TopRight, .TopLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.CGPath
        self.planButton?.layer.mask = maskLayer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function invoke for set up the UI of stat view
    func setUpView(){
        //-------------------Set up navigation bar--------------------------------
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        //-------------------------------------------------------------------------
        
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        makeImpulseBtn!.layer.cornerRadius = 5
        //-----------------------------Set up tab buttons--------------------------------------------
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        //-------------------------------------------------------------------------------------------
        
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
        
        //Showing wishlist count
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
        
        //Setting right button of navigation bar
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        if(planType == "Individual") {
            let attrText = NSMutableAttributedString(string: String(format: "My %@ plan target is £%@",itemTitle,cost))
            attrText.addAttribute(NSFontAttributeName,
                                  value: UIFont(
                                    name: kMediumFont,
                                    size: 16.0)!,
                                  range: NSRange(
                                    location: 3,
                                    length: itemTitle.characters.count))
            lbl!.attributedText = attrText
        }
        else{
            lbl!.text = String(format: "Our target is £%@",cost)
            lbl?.textColor = UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1)
            self.view.bringSubviewToFront(lbl!)
        }
    }
    
    //Function invoke when user tapping on menu button from navigation bar.
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    //Function invoke when user tapping on heart button from navigation bar.
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
    
    //Function invoke when progress button clicked
    @IBAction func clickOnProgressBtn(sender:UIButton){
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    //Function invoke when offer tab button clicked
    @IBAction func offersButtonPressed(sender: AnyObject) {
        let obj = SAOfferListViewController()
        obj.savID = 63
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        //Hide add offer button from offer list
        obj.hideAddOfferButton = false
        //navigate to offer list
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    //Function invoke when offer tab button clicked
    @IBAction func spendButtonPressed(sender: AnyObject) {
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        self.navigationController?.pushViewController(objPlan, animated: false)
    }
    
    //Function invoke when make impulse button clicked for make extra payment
    @IBAction func makeImpulseSavingPressed(sender: AnyObject) {
        let objImpulseSave = SAImpulseSavingViewController()
        self.navigationController?.pushViewController(objImpulseSave, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //function invoke when user select point from line chart
    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>) {
        label.text = "\(yValues[0])"
    }
    
    
    //Mark: - Social Sharing
    //function invoke on tapping any achivement button for showing social media sharing option
    @IBAction func clickedOnAchivements(sender: UIButton){
        //load SocialSharingView.xib for showing pop up
        let testView = NSBundle.mainBundle().loadNibNamed("SocialSharingView", owner: self, options: nil)[0] as! UIView
        testView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        let vw = testView.viewWithTag(7)! as UIView
        vw.layer.borderWidth = 2.0
        
        //------------------------------Formatting popUp-----------------------------------------
        switch sender.tag {
        case 0:
            if(planType == "Individual") {
                vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
                shareImg = UIImage(named: "generic-streak-popup.png")
            }
            else {
                vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).CGColor
                shareImg = UIImage(named: "group-save-streak-popup.png")
            }
        case 1:
            if(planType == "Individual"){
                vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
                shareImg = UIImage(named: "stats-achievement-smiley-popup.png")
            }
            else {
                vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).CGColor
                shareImg = UIImage(named: "group-stats-achievement-smiley-popup.png")
            }
            
        case 2:
            if(planType == "Individual") {
                vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
                shareImg = UIImage(named: "stats-achievement-popup.png")
            }
            else {
                vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).CGColor
                shareImg = UIImage(named: "group-stats-achievement-badge-popup.png")
            }
            
        case 3:
            if(planType == "Individual") {
                vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
                shareImg = UIImage(named: "stats-achievement-money-popup.png")
            }
            else {
                vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).CGColor
                shareImg = UIImage(named: "group-stats-achievement-money-popup.png")
            }
            
        default:
            if(planType == "Individual"){
                vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
                shareImg = UIImage(named: "generic-streak-popup.png")
            }
            else {
                vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).CGColor
                shareImg = UIImage(named: "group-save-streak-popup.png")
            }
        }
        //----------------------------------------------------------------------------------------------------------------
        //Showing image to be sharing
        let imgVw = testView.viewWithTag(10) as! UIImageView
        imgVw.image = shareImg
        
        //Set up for close button
        let btnClose = testView.viewWithTag(6)! as! UIButton
        if(planType == "Individual")
        {
            btnClose.setImage(UIImage(named:"social-pop-up-close.png"), forState: .Normal)
        }
        else {
            btnClose.setImage(UIImage(named:"Group-social-pop-up-close.png"), forState: .Normal)
        }
        
        btnClose.addTarget(self, action: Selector("closeSharePopup:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        //setup for facebook sharing button
        let fbBtn = testView.viewWithTag(2) as! UIButton
        fbBtn.addTarget(self, action: Selector("clickedOnSocialMediaButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        //setup for twitter sharing button
        let twBtn = testView.viewWithTag(3) as! UIButton
        twBtn.addTarget(self, action: Selector("clickedOnSocialMediaButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        //setup for google sharing button
        let glBtn = testView.viewWithTag(4) as! UIButton
        glBtn.addTarget(self, action: Selector("clickedOnSocialMediaButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        //setup for whatsapp sharing button
        let waBtn = testView.viewWithTag(5) as! UIButton
        waBtn.addTarget(self, action: Selector("clickedOnSocialMediaButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.navigationController?.view.addSubview(testView)
    }
    
    //Close the share popup
    func closeSharePopup(sender: UIButton) {
        sender.superview?.superview!.removeFromSuperview()
    }
    
    //function identifying social media for sharing
    func clickedOnSocialMediaButton(sender: UIButton){
        switch sender.tag {
        case 2:
            self.shareOnFacebook(sender)
        case 3:
            self.shareOnTwitter(sender)
        case 4:
            self.shareOnGoogle(sender)
        case 5:
            self.shareOnWhatsApp(sender)
        default:
            print("Nothing")
        }
        //        self.shareOnFacebook(sender)
    }
    
    //Function invoke to open compose view for share content on facebook
    func shareOnFacebook(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Share on Facebook")
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "You’re not logged into Facebook", message: "You need to login to Facebook to be able share this.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //Function invoke to open compose view for share content on twitter
    func shareOnTwitter(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Share on Twitter")
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Twitter isn’t set up", message: "You can add your twitter account in the iOS Settings screens", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //Function invoke for open whatsapp with content
    func shareOnWhatsApp(sender: UIButton) {
        let urlWhats = "whatsapp://app"
        //Make URl for open whatsapp
        if let urlString = urlWhats.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            if let whatsappURL = NSURL(string: urlString) {
                //Open application if whatsapp is installed
                if UIApplication.sharedApplication().canOpenURL(whatsappURL) {
                    //Attached image to whatsapp dialog
                    if let image = shareImg {
                        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                            let tempFile = NSURL(fileURLWithPath: NSHomeDirectory()).URLByAppendingPathComponent("Documents/whatsAppTmp.wai")
                            do {
                                try imageData.writeToURL(tempFile, options: .DataWritingAtomic)
                                documentInteractionController = UIDocumentInteractionController(URL: tempFile)
                                documentInteractionController.UTI = "net.whatsapp.image"
                                documentInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
                            } catch {
                                print(error)
                            }
                        }
                    }
                } else {
                    //Whatsapp not install in device
                    let alert = UIAlertController(title: "No Whatsapp account set up", message: "Your What’s app account isn’t connected to iOS.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //Function invoke for share content on twitter
    func shareOnGoogle(sender: UIButton)
    {
        let urlComponents = NSURLComponents()
        urlComponents.path = "https://plus.google.com/share"
        urlComponents.queryItems = [NSURLQueryItem(name: "url", value: "hello")]
        let url =  NSURL(string: "https://plus.google.com/share")
        if #available(iOS 9.0, *) {
            let controller: SFSafariViewController = SFSafariViewController(URL: url!)
            controller.delegate = self
            self.presentViewController(controller, animated: true, completion: { _ in })
        } else {
            UIApplication.sharedApplication().openURL(url!)
        }
    }
}
