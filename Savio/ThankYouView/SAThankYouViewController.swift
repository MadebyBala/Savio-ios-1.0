//
//  SAThankYouViewController.swift
//  Savio
//
//  Created by Maheshwari on 16/09/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAThankYouViewController: UIViewController {
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView()
    {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.title = "Thank you"
        
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
    }
    
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func continueButtonPressed(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAProgressViewController")
        // Set all plan flag
        let individualFlag = NSUserDefaults.standardUserDefaults().valueForKey("individualPlan") as! NSNumber
        let groupFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupPlan") as! NSNumber
        let groupMemberFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupMemberPlan") as! NSNumber
        
        let plan = NSUserDefaults.standardUserDefaults().valueForKey("usersPlan") as? String
        //Individual plan
        if(plan == "individualPlan" || individualFlag == 1)
        {
            let objProgressView = SAProgressViewController()
            self.navigationController?.pushViewController(objProgressView, animated: true)
            NSUserDefaults.standardUserDefaults().setValue(1, forKey: "individualPlan")
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
        }
        else if(plan == "groupPlan" || groupFlag == 1)//group plan
        {
            NSUserDefaults.standardUserDefaults().setValue(1, forKey: "groupPlan")
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
            
            let objProgressView = SAGroupProgressViewController()
            self.navigationController?.pushViewController(objProgressView, animated: true)
        }
        else if(plan == "groupMemberPlan" || groupMemberFlag == 1)//Group member plan
        {
            NSUserDefaults.standardUserDefaults().setValue(1, forKey: "groupMemberPlan")
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
            
            let objProgressView = SAGroupProgressViewController()
            self.navigationController?.pushViewController(objProgressView, animated: true)
        }
    }
}
