//
//  SAWishListViewController.swift
//  Savio
//
//  Created by Prashant on 04/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAWishListViewController: UIViewController,GetWishlistDelegate,DeleteWishListDelegate {
    
    @IBOutlet var wishListTable: UITableView?    //IBOutlet for tableview
    var objAnimView = ImageViewAnimation()       //object for loading indicator
    var wishListArray : Array<Dictionary<String,AnyObject>> = []   //Array for storing wishlist from webservice
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        // set up UI for wishlist
        self.setUpView()
        //calling get method of wishlist
        self.wishListAPI()
        
        //---------Setting navigation bar-------------------------
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        //----------------------------------------------------------------------
    }
    
    //Function invoke for design the UI
    func setUpView(){
        //Set view's title
        self.title = "My Wish List"
        //Register UIApplication Will Enter Foreground Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("getWishListData:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        //--------------set Navigation left button-----------------
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        //---------------------------------------------------------
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        //check if wishlist product is empty or not
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
            btnName.setTitle(String(format:"%d",wishListArray!.count), forState: UIControlState.Normal)
            
            //Showing wishlist count on heart button
            if(wishListArray!.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else  {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
            }
        }
        else {
            let dataNew = NSKeyedArchiver.archivedDataWithRootObject(wishListArray)
            NSUserDefaults.standardUserDefaults().setObject(dataNew, forKey: "wishlistArray")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        //-----------------------------------------------------------------------------------------
    }
    
    //Function invoke when application is come foreground state and UIApplicationWillEnterForegroundNotification broadcast
    func getWishListData(notification:NSNotification)
    {
        //call get method of wish list
        self.wishListAPI()
    }
    
    //function invoke for call get method of wishlist
    func wishListAPI(){
        //--------load the ImageViewAnimation.xib and showing loading animation--------------------
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        //----------------------------------------------------------------------------------------
        //------Create object of API class and request to server for get wishlist----------------
        let objAPI = API()
        let userDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        objAPI.getWishlistDelegate = self
        //provide the partyID as a parameter to API
        if(userDict["partyId"] is String)
        {
            objAPI.getWishListForUser(userDict["partyId"] as! String)
        }
        else
        {
            objAPI.getWishListForUser(String(format: "%d",((userDict["partyId"] as? NSNumber)?.doubleValue)!))
        }
        //----------------------------------------------------------------------------------------
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tableview Delegate & Datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return wishListArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        //--------create custom cell from WishListTableViewCell.xib------------
        let bundleArr : Array = NSBundle.mainBundle().loadNibNamed("WishListTableViewCell", owner: nil, options: nil) as Array
        let cell = bundleArr[0] as! WishListTableViewCell
        //-----------------------------------------------------------------------
        //Get individual dictionary of wishlist product
        let cellDict = wishListArray[indexPath.row]
        //Set product title
        cell.lblTitle!.text = cellDict["title"] as? String;
        //set product amount
        if(cellDict["amount"] is String){
            cell.lblPrice.text = cellDict["amount"] as? String
        }
        else{
            cell.lblPrice.text = String(format: "%d", (cellDict["amount"] as! NSNumber).intValue)
        }
        //Check wishlist product is invited for group member or not
        if let sharedPartySavingPlan =  cellDict["sharedPtySavingPlanId"] as? NSNumber
        {
            //Not invited for group member
            if(sharedPartySavingPlan == 0)
            {
                if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 0 && NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 0) {
                    cell.btnSavingPlan?.setTitle("Start plan", forState: UIControlState.Normal)
                    cell.btnSavingPlan?.addTarget(self, action: Selector("navigateToSetUpSavingPlan:"), forControlEvents: UIControlEvents.TouchUpInside)
                    cell.deleteButtonTopSpace.constant = 60
                }
                else{
                    cell.btnSavingPlan?.hidden = true
                    cell.deleteButtonTopSpace.constant = 20
                }
            }
            else
            {
                //Invited for group member
                if(NSUserDefaults.standardUserDefaults().objectForKey("groupMemberPlan") as? NSNumber == 0){
                    cell.btnSavingPlan?.setTitle("Join Group", forState: UIControlState.Normal)
                    cell.btnSavingPlan?.addTarget(self, action: Selector("joinGroupSavingPlan:"), forControlEvents: UIControlEvents.TouchUpInside)
                    cell.deleteButtonTopSpace.constant = 60
                }
                else {
                    cell.btnSavingPlan?.hidden = true
                    cell.deleteButtonTopSpace.constant = 20
                }
            }
        }
        else
        {
            //Not invited for group member
            if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 0 && NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 0){
                cell.btnSavingPlan?.setTitle("Start plan", forState: UIControlState.Normal)
                cell.btnSavingPlan?.addTarget(self, action: Selector("navigateToSetUpSavingPlan:"), forControlEvents: UIControlEvents.TouchUpInside)
                cell.deleteButtonTopSpace.constant = 60
            }
            else{
                cell.btnSavingPlan?.hidden = true
                cell.deleteButtonTopSpace.constant = 20
            }
        }
        //set up delete button
        cell.btnDelete?.addTarget(self, action: Selector("deleteButtonPress:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        //------------------Showing prodict image-------------------------------------------
        let spinner =  UIActivityIndicatorView()
        spinner.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, cell.imgView.frame.size.height/2)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        cell.imgView.addSubview(spinner)
        spinner.startAnimating()
        
        if let urlString = cellDict["imageURL"] as? String
        {
            //get image URL from response dict
            let url = NSURL(string:urlString)
            let request: NSURLRequest = NSURLRequest(URL: url!)
            if(urlString != "")
            {
                //request server to fetch image data
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                    //if imagedata getting then show image
                    if data?.length > 0{
                        let image = UIImage(data: data!)
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.imgView.image = image
                            spinner.hidden = true
                            spinner.stopAnimating()
                        })
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), {
                            spinner.hidden = true
                            spinner.stopAnimating()
                        })
                    }
                })
            }
        }
        //----------------------------------------------------------------------------------
        cell.btnSavingPlan?.tag = indexPath.row
        cell.btnDelete?.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let cellDict = wishListArray[indexPath.row]
        if let sharedPartySavingPlan =  cellDict["sharedPtySavingPlanId"] as? NSNumber
        {
            if(sharedPartySavingPlan == 0)
            {
                //If any plan is already created by login user then hide start saving button
                if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 0 && NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 0){
                    return 310.0
                }
                else{
                    return 280.0
                }
            }
            else
            {
                //If already join other group then hide Join button
                if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 0 && NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 0){
                    return 310.0
                }
                else{
                    return 280.0
                }
            }
        }
        else
        {
            if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 0 && NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 0){
                return 310.0
                
            }
            else{
                return 280.0
            }
        }
    }
    
    //Function navigate when user tapping on start saving plan button and navigate to setup plan screen
    func navigateToSetUpSavingPlan(sender:UIButton) {
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let objSavingPlanViewController = SASavingPlanViewController(nibName: "SASavingPlanViewController",bundle: nil)
        objSavingPlanViewController.itemDetailsDataDict = wishListArray[sender.tag]
        self.navigationController?.pushViewController(objSavingPlanViewController, animated: true)
    }
    
    //Function navigate when user tapping on join plan button and navigate to group setup plan screen
    func joinGroupSavingPlan(sender: UIButton)
    {
        let dict = ["savLogo1x":"group-save-category-icon","savLogo2x":"group-save-category-icon","savLogo3x":"group-save-category-icon","title":"Group Save","detail":"Set up savings goal between friends and family","savPlanID":85]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let objSavingPlanViewController = GroupsavingViewController(nibName: "GroupsavingViewController",bundle: nil)
        objSavingPlanViewController.itemDetailsDataDict = wishListArray[sender.tag]
        self.navigationController?.pushViewController(objSavingPlanViewController, animated: true)
    }
    
    //Funtion invoke for delete product from wishlist
    func deleteButtonPress(sender:UIButton)  {
        //Give confirmation alert to user
        let alert = UIAlertController(title: "Are you sure", message: "You want to delete this item?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
        { action -> Void in
            //if yes then show loading animation
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            
            //Create API object and call delete method of wishlist API
            let objAPI = API()
            //Provide product detail to be delete
            let dateDict = self.wishListArray[sender.tag] as Dictionary<String,AnyObject>
            let dict : Dictionary<String,AnyObject> = ["id":dateDict["id"] as! NSNumber]
            objAPI.deleteWishList = self
            objAPI.deleteWishList(dict)
            //Remove from array
            self.wishListArray.removeAtIndex(sender.tag)
            self.wishListTable?.reloadData()
            let dataNew = NSKeyedArchiver.archivedDataWithRootObject(self.wishListArray)
            
            NSUserDefaults.standardUserDefaults().setObject(dataNew, forKey: "wishlistArray")
            NSUserDefaults.standardUserDefaults().synchronize()
            })
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: DELETE Wishlist delegate
    func successResponseForDeleteWishListAPI(objResponse: Dictionary<String, AnyObject>) {
        
        objAnimView.removeFromSuperview()
        self.setUpView()
    }
    //If Delete Fail
    func errorResponseForDeleteWishListAPI(error: String) {
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView.removeFromSuperview()
    }
    
    //MARK: Bar button action
    //Function invoke when menu button clicked from navigation bar
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    //Function invoke when hear button clicked from navigation bar
    func heartBtnClicked(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK:- GetWishlist API  delegate
    func successResponseForGetWishlistAPI(objResponse: Dictionary<String, AnyObject>) {
        if wishListArray.count > 0 {
            wishListArray.removeAll()
        }
        if let obj = objResponse["wishListList"] as? Array<Dictionary<String,AnyObject>>{
            NSNotificationCenter.defaultCenter().removeObserver(self)
            self.wishListArray = obj
            self.objAnimView.removeFromSuperview()
            self.setUpView()
            self.wishListTable?.reloadData()
        }
    }
    //Fail response GetWishlist API
    func errorResponseForGetWishlistAPI(error: String) {
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView.removeFromSuperview()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        objAnimView.removeFromSuperview()
    }
}
