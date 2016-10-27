//
//  SACreateSavingPlanViewController.swift
//  Savio
//
//  Created by Prashant on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SACreateSavingPlanViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GetWishlistDelegate,CategoriesSavingPlan, GetOfferlistDelegate{
    //-------------Setup IBOutlets------------------------------------------------------------
    @IBOutlet weak var tblView: UITableView?         //IBOutlet for tableview
    @IBOutlet weak var scrlView: UIScrollView?       //IBOutlet for scrollview
    @IBOutlet weak var pageControl: UIPageControl?  // IBOutlet for page control
    @IBOutlet weak var btnWishList: UIButton?       //Iboutlet for wishlist button
    @IBOutlet weak var lblLine: UILabel?
    @IBOutlet weak var suggestedTop: NSLayoutConstraint!    //IBOutlet for set top space from scrollview
    @IBOutlet weak var suggestedY: NSLayoutConstraint!      //IBOutlet for set Y position of lable as per whishlist present
    @IBOutlet weak var suggestedHt: NSLayoutConstraint!     //IBOutlet for set height of view as per wishlist available or not
    @IBOutlet weak var verticalScrlView: UIScrollView!      //IBoutlet for wishlist scrollview
    @IBOutlet weak var btnVwBg: UIView!                     //IBOutlet for button background view
    @IBOutlet weak var contentView: UIView!                 //IBOutlet for scrollview container view
    //-----------------------------------------------------------------------------------------
    
    var objAnimView = ImageViewAnimation() //Object of custom loding indicator
    var heartBtn: UIButton = UIButton()    //Heart button on navigation bar
    var colors:[Dictionary<String,AnyObject>] = []
    
    var tblArr : Array<Dictionary<String,AnyObject>> = []
    //Set default placeholder for all saving plan icon image
    var placeHolderImgArr: Array<String> = ["group-save-category-icon","wedding-category-icon","baby-category-icon","holiday-category-icon","ride-category-icon","home-category-icon","gadget-category-icon","generic-category-icon"]
    var valueArray : Array<Dictionary<String,AnyObject>> = [["savLogo1x":"group-save-category-icon","savLogo2x":"group-save-category-icon","savLogo3x":"group-save-category-icon","title":"Group goal","savDescription":"Set up a goal between friends and family","sav-id":"85"]
        ,["savLogo1x":"wedding-category-icon","savLogo2x":"wedding-category-icon","savLogo3x":"wedding-category-icon","title":"Wedding","savDescription":"Get great deals on everything from flowers to videos","sav-id":"86"]
        ,["savLogo1x":"baby-category-icon","savLogo2x":"baby-category-icon","savLogo3x":"baby-category-icon","title":"Baby","savDescription":"Get everything ready for the new arrival","sav-id":"87"],
         ["savLogo1x":"holiday-category-icon","savLogo2x":"holiday-category-icon","savLogo3x":"holiday-category-icon","title":"Holiday","savDescription":"Get your money together to pay for big trip or mini break.","sav-id":"88"],
         ["savLogo1x":"ride-category-icon","savLogo2x":"ride-category-icon","savLogo3x":"ride-category-icon","title":"Ride","savDescription":"There's always room for another bike.","sav-id":"89"],
         ["savLogo1x":"home-category-icon","savLogo2x":"home-category-icon","savLogo3x":"home-category-icon","title":"Home","savDescription":"Time to make that project a reality.","sav-id":"90"],
         ["savLogo1x":"gadget-category-icon","savLogo2x":"gadget-category-icon","savLogo3x":"gadget-category-icon","title":"Gadget","savDescription":"The one thing you really need, from smartphones to sewing machines.","sav-id":"91"],
         ["savLogo1x":"generic-category-icon","savLogo2x":"generic-category-icon","savLogo3x":"generic-category-icon","title":"Generic plan","savDescription":"Not sure yet or just setting some money aside.","sav-id":"92"]]
    
    let pageArr: Array<String> = ["Page5", "Page1", "Page2", "Page3", "Page4"] //Set up list of page on page controller
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //----------------------------------------Setting navigation Bar-------------------------------------------
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        //------------------------------------------------------------------------------------------------------------
        //Register UIApplication Will Enter Foreground Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("getWishListData:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        tblView?.registerClass(SavingCategoryTableViewCell.self, forCellReuseIdentifier: "SavingCategoryTableViewCell")
        tblView?.separatorInset = UIEdgeInsetsZero
        //Setting up UI
        self.setUpView()
        //Setting up animation loader
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        //--------Call get saving plans and get wishlist API----------
        let objAPI = API()
        objAPI.categorySavingPlanDelegate = self
        objAPI.getCategoriesForSavingPlan()
        self.callWishListAPI()
        //------------------------------------------------------------
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
    }
    //Function invoke for call get offer list API
    func callGetOfferListAPI() {
        let objAPI = API()
        objAPI.getofferlistDelegate = self
        objAPI.getOfferListForSavingId()
    }
    
    //Function invoke for call get wish list API
    func callWishListAPI()
    {
        let objAPI = API()
        //get keychain values
        let userDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        objAPI.getWishlistDelegate = self
        
        //Call get method of wishlist API by providing partyID
        if(userDict["partyId"] is String)
        {
            objAPI.getWishListForUser(userDict["partyId"] as! String)
        }
        else
        {
            objAPI.getWishListForUser(String(format: "%d",((userDict["partyId"] as? NSNumber)?.doubleValue)!))
        }
    }
    //Function invoke when UIApplicationWillEnterForegroundNotification brodcast
    func getWishListData(notification:NSNotification)
    {
        self.callWishListAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Called to notify the view controller that its view has just laid out its subviews.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        verticalScrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width,  scrlView!.frame.size.height + tblView!.frame.size.height + suggestedHt.constant)
    }
    
    //Function invoke for Set up the UI
    func setUpView(){
        btnWishList!.layer.cornerRadius = 5
        btnVwBg.layer.cornerRadius = 5
        
        //--------set Navigation left button--------------------
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        //-------------------------------------------------------
        self.title = "Create a plan"
        
        //---------------set Navigation right button nav-heart-------------------
        heartBtn.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        heartBtn.frame = CGRectMake(0, 0, 30, 30)
        heartBtn.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        let heartCount:String = String(format: "%d",colors.count)
        heartBtn.setTitle(heartCount, forState: UIControlState.Normal)
        heartBtn.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        heartBtn.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = heartBtn
        self.navigationItem.rightBarButtonItem = rightBarButton
        //------------------------------------------------------------------------
        self.configureScrollView()
    }
    
    //Set up scrollview as per the wishlist availability
    func configureScrollView() {
        //--------Remove all subview from scrollview-----------
        if self.scrlView!.subviews.count > 0 {
            for subview in self.scrlView!.subviews{
                subview.removeFromSuperview()
            }
        }
        //------------------------------------------------------
        
        // Enable paging.
        scrlView!.pagingEnabled = true
        // Set the following flag values.
        scrlView!.showsHorizontalScrollIndicator = false
        scrlView!.showsVerticalScrollIndicator = false
        scrlView!.scrollsToTop = false
        
        // Set the scrollview content size.
        if(colors.count >= 5)
        {
            scrlView!.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width * 5, 0)
        }
        else
        {
            scrlView!.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width * CGFloat(colors.count), 0)
        }
        // Load the PageView view from the SavingPageView.xib file and configure it properly.
        if colors.count > 0{
            
            if(colors.count >= 5)
            {
                for i in 0 ..< 5 {
                    heartBtn.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                    heartBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                    let dataSave = NSKeyedArchiver.archivedDataWithRootObject(colors)
                    
                    NSUserDefaults.standardUserDefaults().setObject(dataSave, forKey: "wishlistArray")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    // Load the TestView view.
                    let testView = NSBundle.mainBundle().loadNibNamed("SavingPageView", owner: self, options: nil)[0] as! UIView
                    // Set its frame and data to pageview
                    testView.frame = CGRectMake(CGFloat(i) * UIScreen.mainScreen().bounds.size.width, 0, UIScreen.mainScreen().bounds.size.width, scrlView!.frame.size.height)
                    let vw = testView.viewWithTag(2)! as UIView
                    vw.layer.borderWidth = 1
                    vw.layer.borderColor = UIColor.whiteColor().CGColor
                    //Get individual product from wishlist
                    let objDict = colors[i] as Dictionary<String,AnyObject>
                    
                    let lblNoWishList = testView.viewWithTag(5)! as! UILabel
                    lblNoWishList.hidden = true
                    //----------show product title--------------------
                    let lblTitle = testView.viewWithTag(3)! as! UILabel
                    lblTitle.text = objDict["title"] as? String
                    lblTitle.hidden = false
                    //-----------------------------------------------
                    //-----------Show product cost-------------------
                    let lblCost = testView.viewWithTag(4)! as! UILabel
                    if(objDict["amount"] is String)
                    {
                        lblCost.text = objDict["amount"] as? String
                    }
                    else
                    {
                        lblCost.text = String(format: "%d", (objDict["amount"] as! NSNumber).intValue)
                    }
                    //----------------------------------------------------
                    
                    //------------------Showing image of wishlist product---------------
                    let bgImageView = testView.viewWithTag(1) as! UIImageView
                    if let urlString = objDict["imageURL"] as? String
                    {
                        //Get product URL
                        let url = NSURL(string:urlString)
                        let request: NSURLRequest = NSURLRequest(URL: url!)
                        if(urlString != "")
                        {
                            // fetch image data from url
                            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                                if(data != nil && data?.length > 0)
                                {
                                    //showing image if data available
                                    let image = UIImage(data: data!)
                                    dispatch_async(dispatch_get_main_queue(), {
                                        bgImageView.image = image
                                    })
                                }
                            })
                        }
                    }
                    //---------------------------------------------------------------------
                    let imgEuro = testView.viewWithTag(6)! as! UIImageView
                    imgEuro.hidden = false
                    
                    suggestedHt.constant = 113.0
                    suggestedTop.constant = 16.0
                    btnWishList?.hidden = false
                    pageControl?.hidden = false
                    btnVwBg.hidden = false
                    //---------show at most 5 latest products to scrollview---------
                    if(colors.count >= 5)
                    {
                        pageControl?.numberOfPages = 5
                    }
                    else {
                        pageControl?.numberOfPages = colors.count
                    }
                    lblLine?.hidden = false
                    // Add the test view as a subview to the scrollview.
                    scrlView!.addSubview(testView)
                    //-------------------------------------------------------------
                }
            }
            else {
                for i in 0 ..< colors.count {
                    heartBtn.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                    heartBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                    let dataSave = NSKeyedArchiver.archivedDataWithRootObject(colors)
                    
                    NSUserDefaults.standardUserDefaults().setObject(dataSave, forKey: "wishlistArray")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    // Load the TestView view.
                    let testView = NSBundle.mainBundle().loadNibNamed("SavingPageView", owner: self, options: nil)[0] as! UIView
                    // Set its frame and data to pageview
                    testView.frame = CGRectMake(CGFloat(i) * UIScreen.mainScreen().bounds.size.width, 0, UIScreen.mainScreen().bounds.size.width, scrlView!.frame.size.height)
                    let vw = testView.viewWithTag(2)! as UIView
                    vw.layer.borderWidth = 1
                    vw.layer.borderColor = UIColor.whiteColor().CGColor
                    
                    let objDict = colors[i] as Dictionary<String,AnyObject>
                    
                    let lblNoWishList = testView.viewWithTag(5)! as! UILabel
                    lblNoWishList.hidden = true
                    
                    let lblTitle = testView.viewWithTag(3)! as! UILabel
                    lblTitle.text = objDict["title"] as? String
                    lblTitle.hidden = false
                    
                    let lblCost = testView.viewWithTag(4)! as! UILabel
                    
                    if(objDict["amount"] is String)
                    {
                        lblCost.text = objDict["amount"] as? String
                    }
                    else
                    {
                        lblCost.text = String(format: "%d", (objDict["amount"] as! NSNumber).intValue)
                    }
                    
                    
                    let bgImageView = testView.viewWithTag(1) as! UIImageView
                    if let urlString = objDict["imageURL"] as? String
                    {
                        let url = NSURL(string:urlString)
                        
                        let request: NSURLRequest = NSURLRequest(URL: url!)
                        if(urlString != "")
                        {
                            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                                if(data != nil && data?.length > 0)
                                {
                                    let image = UIImage(data: data!)
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        bgImageView.image = image
                                    })
                                }
                            })
                        }
                    }
                    
                    let imgEuro = testView.viewWithTag(6)! as! UIImageView
                    imgEuro.hidden = false
                    
                    suggestedHt.constant = 113.0
                    suggestedTop.constant = 16.0
                    btnWishList?.hidden = false
                    pageControl?.hidden = false
                    btnVwBg.hidden = false
                    if(colors.count >= 5)
                    {
                        pageControl?.numberOfPages = 5
                    }
                    else {
                        pageControl?.numberOfPages = colors.count
                    }
                    
                    lblLine?.hidden = false
                    
                    // Add the test view as a subview to the scrollview.
                    scrlView!.addSubview(testView)
                }
                
            }
            
        }
        else {
            
            //--------------If whishlist is empty setup UI--------------------------------------------
            NSUserDefaults.standardUserDefaults().setObject(colors, forKey: "wishlistArray")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            scrlView!.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width , 0)
            let testView = NSBundle.mainBundle().loadNibNamed("SavingPageView", owner: self, options: nil)[0] as! UIView
            // Set its frame and data to pageview
            testView.frame = CGRectMake(scrlView!.bounds.origin.x, 0, scrlView!.frame.size.width, scrlView!.frame.size.height)
            let vw = testView.viewWithTag(2)! as UIView
            vw.layer.borderWidth = 1
            vw.layer.borderColor = UIColor.whiteColor().CGColor
            let lblNoWishList = testView.viewWithTag(5)! as! UILabel
            lblNoWishList.hidden = false
            let lblTitle = testView.viewWithTag(3)! as! UILabel
            lblTitle.hidden = true
            
            let lblCost = testView.viewWithTag(4)! as! UILabel
            lblCost.hidden = true
            
            let imgEuro = testView.viewWithTag(6)! as! UIImageView
            imgEuro.hidden = true
            
            //-----Set topspace and height of view if empty wishlist-----
            suggestedHt.constant = 50.0
            suggestedTop.constant = -52.0
            //--------------------------------------------------------
            btnVwBg.hidden = true
            btnWishList?.hidden = true
            pageControl?.hidden = true
            lblLine?.hidden = true
            // Add the SavingPageView as a subview to the scrollview.
            scrlView!.addSubview(testView)
            //---------------------------------------------------------------------------------------
        }
        
        
    }
    
    
    //Function invoking for configure the page control for animated pages
    func configurePageControl() {
        // Set the total pages to the page control.
        pageControl!.numberOfPages = 5
        // Set the initial page.
        pageControl!.currentPage = 0
    }
    
    // MARK: UIScrollViewDelegate method implementation
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        //Brodcast notification for toggle menu
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        if colors.count>0{
            NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAWishListViewController")
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: "Wish list empty.", message: "You don’t have anything in your wish list yet. Get out there and set some goals!", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    // MARK: IBAction method implementation
    @IBAction func changePage(sender: AnyObject) {
        // Calculate the frame that should scroll to based on the page control current page.
        var newFrame = scrlView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        scrlView!.scrollRectToVisible(newFrame, animated: true)
    }
    
    @IBAction func clickedOnWishListButton(sender:UIButton){
        NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAWishListViewController")
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")
    }
    
    
    //MARK: TableView Delegate and Datasource method
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tblArr.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let bundleArr : Array = NSBundle.mainBundle().loadNibNamed("SavingCategoryTableViewCell", owner: nil, options: nil) as Array
        let cell = bundleArr[0] as! SavingCategoryTableViewCell
        let cellDict = tblArr[indexPath.row]
        cell.layoutMargins = UIEdgeInsetsZero
        cell.lblHeader!.text = cellDict["title"] as? String;
        cell.lblDetail?.text = cellDict["savDescription"] as? String
        cell.imgView?.image = UIImage(named: placeHolderImgArr[indexPath.row])  //placeHolderImgArr[indexPath.row]
        
        cell.imgView?.image = UIImage(named: placeHolderImgArr[indexPath.row])
        if (cellDict["savLogo1x"] != nil){
            let request: NSURLRequest = NSURLRequest(URL: NSURL(string:cellDict["savLogo1x"] as! String)!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if(data != nil)
                {
                    let image = UIImage(data: data!)
                    dispatch_async(dispatch_get_main_queue(), {
                        if image != nil {
                            cell.imgView?.image = image
                        }
                    })
                }
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 79.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Check If any plan is created by login user
        if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 1 || NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 1)
        {
            //if plan already created then restrict user to create all plan
            let alert = UIAlertView(title: "Alert", message: "Sorry, can only have one personal plan and be a member of one group plan at a time.", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else
        {
            //If plan is not created then allow user to create plan
            NSUserDefaults.standardUserDefaults().setObject(self.checkNullDataFromDict(tblArr[indexPath.row]), forKey:"colorDataDict")
            NSUserDefaults.standardUserDefaults().synchronize()
            if(indexPath.row == 0)
            {
                let objGroupSavingPlanViewController = GroupsavingViewController(nibName: "GroupsavingViewController",bundle: nil)
                self.navigationController?.pushViewController(objGroupSavingPlanViewController, animated: true)
            }
            else
            {
                NSUserDefaults.standardUserDefaults().setObject( self.checkNullDataFromDict(tblArr[indexPath.row]), forKey:"colorDataDict")
                NSUserDefaults.standardUserDefaults().synchronize()
                if(indexPath.row == 0)
                {
                    let objGroupSavingPlanViewController = GroupsavingViewController(nibName: "GroupsavingViewController",bundle: nil)
                    self.navigationController?.pushViewController(objGroupSavingPlanViewController, animated: true)
                }
                else
                {
                    let objSavingPlanViewController = SASavingPlanViewController(nibName: "SASavingPlanViewController",bundle: nil)
                    self.navigationController?.pushViewController(objSavingPlanViewController, animated: true)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if( tblView!.respondsToSelector(Selector("setSeparatorInset:"))){
            tblView!.separatorInset = UIEdgeInsetsZero
        }
        if( tblView!.respondsToSelector(Selector("setLayoutMargins:"))){
            tblView!.layoutMargins = UIEdgeInsetsZero
        }
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    //MARK: GetCategorysavingPlan API Delegate method
    func successResponseForCategoriesSavingPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        //setup UI and reload tableview
        
        if let tblArray = (objResponse["savingPlanList"] as? Array<Dictionary<String,AnyObject>>)
        {
            tblArr = tblArray
            if(tblArr.count != 0)
            {
                for i in 0 ..< tblArr.count {
                    let dict = tblArr[i] as Dictionary<String,AnyObject>
                    if(dict["title"] as! String == "Group Save")
                    {
                        NSUserDefaults.standardUserDefaults().setObject(dict["savPlanID"], forKey: "savPlanID")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                }
            }
            else {
                 tblArr = valueArray
            }
            self.setUpView()
            tblView?.scrollsToTop = true
            tblView?.reloadData()
            //Call get method of offer list
            self.callGetOfferListAPI()
    
        }
     
    }
    //function invoke when GetCategorysavingPlan API request fail
    func errorResponseForCategoriesSavingPlanAPI(error: String) {
        objAnimView.removeFromSuperview()
        if(error == "No network found")
        {
            let alert = UIAlertView(title: "Connection problem", message: "Savio needs the internet to work. Check your data connection and try again.", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else {
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
    }
    
    //MARK: GetWishlist Delegate method
    func successResponseForGetWishlistAPI(objResponse: Dictionary<String, AnyObject>) {
        if let error = objResponse["error"] as? String
        {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else
        {
            let wishListResponse = self.checkNullDataFromDict(objResponse)
            colors = wishListResponse["wishListList"] as! Array<Dictionary<String,AnyObject>>
            self.setUpView()
        }
        if let arr =  NSUserDefaults.standardUserDefaults().valueForKey("offerList") as? Array<Dictionary<String,AnyObject>>{
            if arr.count > 0{
                objAnimView.removeFromSuperview()
            }
        }
    }
     //function invoke when GetWishlist API request fail
    func errorResponseForGetWishlistAPI(error: String) {
        objAnimView.removeFromSuperview()
        if(error == "No network found")
        {
            let alert = UIAlertView(title: "Connection problem", message: "Savio needs the internet to work. Check your data connection and try again.", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }

    }
    
    //MARK: GetOfferlistAPI Delegate method
    func successResponseForGetOfferlistAPI(objResponse:Dictionary<String,AnyObject>){
        var offerArr:Array<Dictionary<String,AnyObject>> = objResponse["offerList"] as! Array<Dictionary<String,AnyObject>>
        var arr: Array<Dictionary<String,AnyObject>> = []
        for var i = 0; i < offerArr.count; i++ {
            let dict = self.checkNullDataFromDict(offerArr[i] as Dictionary<String,AnyObject>)
            arr.append(dict)
        }
        NSUserDefaults.standardUserDefaults().setObject(arr, forKey: "offerList")
        NSUserDefaults.standardUserDefaults().synchronize()
        objAnimView.removeFromSuperview()
    }
    
     //function invoke when GetOfferlist API request fail
    func errorResponseForGetOfferlistAPI(error:String){
        objAnimView.removeFromSuperview()
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
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
