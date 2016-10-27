//
//  SASwitchViewController.swift
//  Savio
//
//  Created by Prashant on 21/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASwitchViewController: UIViewController,GetListOfUsersPlanDelegate {
    
    
    @IBOutlet var scrView : UIScrollView?
    @IBOutlet var confirmBtn : UIButton?
    @IBOutlet weak var planOneImageView: UIImageView!
    @IBOutlet weak var planTwoImageView: UIImageView!
    @IBOutlet weak var planOneButton: UIButton!
    @IBOutlet weak var planTwoButton: UIButton!
    @IBOutlet weak var spinnerOne: UIActivityIndicatorView!
    @IBOutlet weak var spinnerTwo: UIActivityIndicatorView!
    
    var usersPlanArray : Array<Dictionary<String,AnyObject>> = []
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var objAnimView = ImageViewAnimation()
    var planOneSharedSavingPlanID = ""
    var planTwoSharedSavingPlanID = ""
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        
        //Create object of API class to call the GETSavingPlanDelegate methods.
        let objAPI = API()
        objAPI.getListOfUsersPlanDelegate = self
        objAPI.getListOfUsersPlan()
        
        
        self.setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrView?.contentSize = CGSizeMake(0, confirmBtn!.frame.origin.y + confirmBtn!.frame.size.height + 10)
        //        scrlVw?.contentSize = CGSizeMake(0, htContentView.constant)
    }
    
    func setUpView(){
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
        self.title = "Switch plans"
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        //        btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
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
    }
    
    
    @IBAction func confirmButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAProgressViewController")
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAProgressViewController")
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
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
    
    @IBAction func planOneButtonPressed(sender: AnyObject) {
        planTwoImageView.layer.borderWidth = 0
        planOneImageView.layer.borderWidth = 3
        planOneImageView.layer.borderColor = UIColor(red:244/255,green: 176/255,blue: 58/255,alpha: 1).CGColor
        
        let dictOne = usersPlanArray[0] as Dictionary<String,AnyObject>
        
        var planOneType = ""
        if(dictOne["partySavingPlanType"] as! String == "Group" || dictOne["partySavingPlanType"] as! String == "group")
        {
            if let sharedSavingPlanID = dictOne["sharedSavingPlanID"] as? NSNumber
            {
                planOneType = "GM"
            }
            else {
                planOneType = "G"
            }
        }
        else {
            planOneType = "I"
        }
        
        NSUserDefaults.standardUserDefaults().setObject(planOneType, forKey: "UsersPlan")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func planTwoButtonPressed(sender: AnyObject) {
        planOneImageView.layer.borderWidth = 0
        planTwoImageView.layer.borderWidth = 3
        planTwoImageView.layer.borderColor = UIColor(red:244/255,green: 176/255,blue: 58/255,alpha: 1).CGColor
        
        let dictTwo = usersPlanArray[1] as Dictionary<String,AnyObject>
        
        var planTwoType = ""
        if(dictTwo["partySavingPlanType"] as! String == "Group" || dictTwo["partySavingPlanType"] as! String == "group")
        {
            if let sharedSavingPlanID = dictTwo["sharedSavingPlanID"] as? NSNumber
            {
                planTwoType = "GM"
            }
            else {
                planTwoType = "G"
            }
        }
        else {
            planTwoType = "I"
        }
        
        NSUserDefaults.standardUserDefaults().setObject(planTwoType, forKey: "UsersPlan")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    //MARK: GetListOfUsersPlanDelegate methods
    
    func successResponseForGetListOfUsersPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        print(objResponse)
        if let message = objResponse["message"] as? String
        {
            if(message == "Successfully received")
            {
                usersPlanArray = (objResponse["lstPartysavingplan"] as? Array<Dictionary<String,AnyObject>>)!
                
                for i in 0 ..< usersPlanArray.count {
                    spinnerOne.hidden = false
                    spinnerOne.startAnimating()
                    
                    spinnerTwo.hidden = false
                    spinnerTwo.startAnimating()
                    
                    let dict = usersPlanArray[i] as Dictionary<String,AnyObject>
                    if(i == 0)
                    {
                        planOneButton .setTitle(dict["title"] as? String , forState: .Normal)
                        self.view.bringSubviewToFront(planOneButton)
                    }
                    else if(i == 1)
                    {
                        planTwoButton .setTitle(dict["title"] as? String , forState: .Normal)
                        self.view.bringSubviewToFront(planTwoButton)
                    }
                    
                    if let urlString = dict["image"] as? String
                    {
                        let url = NSURL(string:urlString)
                        let request: NSURLRequest = NSURLRequest(URL: url!)
                        if(urlString != "")
                        {
                            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                                if data?.length > 0
                                {
                                    let image = UIImage(data: data!)
                                    dispatch_async(dispatch_get_main_queue(), {
                                        if(i == 0)
                                        {
                                            self.planOneImageView.image = image
                                            self.spinnerOne.hidden = true
                                            self.spinnerOne.stopAnimating()
                                        }
                                        else {
                                            self.planTwoImageView.image = image
                                            self.spinnerTwo.hidden = true
                                            self.spinnerTwo.stopAnimating()
                                        }
                                    })
                                }
                                else {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.spinnerOne.hidden = true
                                        self.spinnerOne.stopAnimating()
                                        self.spinnerTwo.hidden = true
                                        self.spinnerTwo.stopAnimating()
                                    })
                                }
                            })
                        }
                        else {
                            self.spinnerOne.hidden = true
                            self.spinnerOne.stopAnimating()
                            self.spinnerTwo.hidden = true
                            self.spinnerTwo.stopAnimating()
                        }
                    }else {
                        self.spinnerOne.hidden = true
                        self.spinnerOne.stopAnimating()
                        self.spinnerTwo.hidden = true
                        self.spinnerTwo.stopAnimating()
                    }
                    
                    
                }
                
                planOneImageView.layer.cornerRadius = planOneImageView.frame.size.height / 2
                self.planOneImageView.clipsToBounds = true
                planTwoImageView.layer.cornerRadius = planTwoImageView.frame.size.height / 2
                self.planTwoImageView.clipsToBounds = true
                self.setUpView()
            }
        }
    }
    
    func errorResponseForGetListOfUsersPlanAPI(error: String) {
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView.removeFromSuperview()
        
    }
}
