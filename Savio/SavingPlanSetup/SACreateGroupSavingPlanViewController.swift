//
//  SACreateGroupSavingPlanViewController.swift
//  Savio
//
//  Created by Maheshwari on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit


protocol SACreateGroupSavingPlanDelegate {
    
    func clearAll()
}

class SACreateGroupSavingPlanViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SegmentBarChangeDelegate,SAOfferListViewDelegate,PartySavingPlanDelegate,InviteMembersDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var tblViewHt: NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var addAPhotoLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var topBgImageView: UIImageView!
    @IBOutlet weak var scrlView: UIScrollView!
    
    var participantsArr : Array<Dictionary<String,AnyObject>> = []
    var selectedStr = ""
    var cost : Int = 0
    var parameterDict : Dictionary<String,AnyObject> = [:]
    var dateDiff : Int = 0
    var dateString = "date"
    var isClearPressed = false
    var isDateChanged =  false
    var isOfferShow = false
    var objAnimView = ImageViewAnimation()
    var delegate : SACreateGroupSavingPlanDelegate?
    var imagePicker = UIImagePickerController()
    var userInfoDict  : Dictionary<String,AnyObject> = [:]
    var isImageClicked = false
    var offerArr: Array<Dictionary<String,AnyObject>> = []
    var groupMemberCount = 0
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        self.title = "Plan setup"
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        tblView!.registerNib(UINib(nibName: "SetDayTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanSetDateIdentifier")
        tblView!.registerNib(UINib(nibName: "CreateSavingPlanTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateSavingPlanTableViewCellIdentifier")
        tblView!.registerNib(UINib(nibName: "GroupCalculationTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupCalculationCellIdentifier")
        tblView!.registerNib(UINib(nibName: "ClearButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ClearButtonIdentifier")
        tblView!.registerNib(UINib(nibName: "OfferTableViewCell", bundle: nil), forCellReuseIdentifier: "OfferTableViewCellIdentifier")
        dateDiff =  Int(parameterDict["dateDiff"] as! String)!
        participantsArr = parameterDict["participantsArr"] as! Array
        cost =  Int(parameterDict["amount"] as! String)!
        let objAPI = API()
        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        let dict = ["first_name":userInfoDict["first_name"]!,"email_id":userInfoDict["email"]!,"mobile_number":userInfoDict["phone_number"]!] as Dictionary<String,AnyObject>
        participantsArr.append(dict)
        topBgImageView.contentMode = UIViewContentMode.ScaleAspectFill
        topBgImageView.layer.masksToBounds = true
        self.setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setUpView(){
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("backButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData  {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setTitle(String(format:"%d",wishListArray!.count), forState: UIControlState.Normal)
            if(wishListArray?.count > 0) {
                
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
            }
            
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        if (parameterDict["imageURL"] as! String != "" &&  parameterDict["isUpdate"]!.isEqualToString("Yes")) {
            if let urlString = parameterDict["imageURL"] as? String {
                let data :NSData = NSData(base64EncodedString: urlString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                topBgImageView.image = UIImage(data: data)
                cameraButton.hidden = true
            }
        }
        else if let image = parameterDict["imageURL"] as? String {
            if(image == "") {
                self.cameraButton.hidden = false
                topBgImageView.image = UIImage(named: "groupsave-setup-bg.png")
            }
            else {
                let data :NSData = NSData(base64EncodedString: parameterDict["imageURL"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                topBgImageView.image = UIImage(data: data)
                cameraButton.hidden = true
            }
        }
        else {
            self.cameraButton.hidden = false
            topBgImageView.image = UIImage(named: "groupsave-setup-bg.png")
        }
        
        if parameterDict["isUpdate"]!.isEqualToString("Yes") {
            isDateChanged = true
        }
    }
    
    //Navigation bar button methods
    func backButtonClicked()
    {
        if isOfferShow == true && offerArr.count > 0 {
            let obj = SAOfferListViewController()
            obj.delegate = self
            if let savId = parameterDict["sav_id"] as? String {
                obj.savID = Int(savId)!
            }
            else if let savId = parameterDict["sav_id"] as? NSNumber {
                obj.savID = savId
            }
            self.navigationController?.pushViewController(obj, animated: true)
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    func heartBtnClicked(){
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData  {
            let dataSave = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as! NSData
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>
            //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
            if wishListArray!.count>0 {
                NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAWishListViewController")
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")
            }
            else {
                let alert = UIAlertView(title: "Wish list empty.", message: "You don’t have anything in your wish list yet. Get out there and set some goals!", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else {
            let alert = UIAlertView(title: "Wish list empty.", message: "You don’t have anything in your wish list yet. Get out there and set some goals!", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    //TableViewDelegate methods
    //return the number of sections in table view.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if parameterDict["isUpdate"]!.isEqualToString("Yes") {
            return offerArr.count + 3
        }
        else {
            return offerArr.count + 4
        }
    }
    
    //return the number of rows in each section in table view.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //create custom cell from their respective Identifiers.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if(indexPath.section == 0) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanSetDateIdentifier", forIndexPath: indexPath) as! SetDayTableViewCell
            cell1.tblView = tblView
            cell1.view = self.scrlView
            cell1.segmentDelegate = self
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if parameterDict["isUpdate"]!.isEqualToString("Yes") {
                if let payType = parameterDict["payType"] as? NSString {
                    if(payType == "Week") {
                        let button = UIButton()
                        button.tag = 0
                        cell1.segmentBar.toggleButton(button)
                    }
                }
                if let payDate = parameterDict["payDate"] as? String {
                    cell1.dayDateTextField.text = payDate
                }
            }
            else {
                if(isClearPressed) {
                    cell1.dayDateTextField.text = ""
                }
            }
            return cell1
        }
        else if(indexPath.section == 1) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("GroupCalculationCellIdentifier", forIndexPath: indexPath) as! GroupCalculationTableViewCell
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if(isDateChanged) {
                if parameterDict["isUpdate"]!.isEqualToString("Yes")
                {
                    cell1.percentageCalculationLabel.text = String(format: "The plan is split equally between everyone. You have %.2f%% of the plan which is £%d of the total goal of £%d",round(CGFloat(100)/CGFloat(groupMemberCount)),cost/(groupMemberCount),cost)
                    
                    if(dateString == "day") {
                        if((dateDiff/168) == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per week for %d week",round(CGFloat(cost)/CGFloat(groupMemberCount))/CGFloat(dateDiff/168),(dateDiff/168))
                        }
                        else if ((dateDiff/168) == 0) {
                            cell1.calculationLabel.text = "You will need to top up £0 per week for 0 week"
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per week for %d weeks",round(CGFloat(cost)/CGFloat((groupMemberCount))/CGFloat(dateDiff/168)),(dateDiff/168))
                        }
                    }
                    else {
                        if((dateDiff/168)/4 == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per month for %d month",round((CGFloat(cost)/CGFloat(groupMemberCount)/CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                        }
                        else if ((dateDiff/168)/4 == 0) {
                            cell1.calculationLabel.text = "You will need to top up £0 per month for 0 month"
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per month for %d months",round((CGFloat(cost)/CGFloat((groupMemberCount ))/CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                        }
                    }
                    
                    
                }else {
                    
                    cell1.percentageCalculationLabel.text = String(format: "The plan is split equally between everyone. You have %.2f%% of the plan which is £%d of the total goal of £%d",round(CGFloat(100)/CGFloat(participantsArr.count)),cost/(participantsArr.count),cost)
                    if(dateString == "day") {
                        if((dateDiff/168) == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per week for %d week",round(CGFloat(cost)/CGFloat(participantsArr.count))/CGFloat(dateDiff/168),(dateDiff/168))
                        }
                        else if ((dateDiff/168) == 0) {
                            cell1.calculationLabel.text = "You will need to top up £0 per week for 0 week"
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per week for %d weeks",round(CGFloat(cost)/CGFloat((participantsArr.count))/CGFloat(dateDiff/168)),(dateDiff/168))
                        }
                    }
                    else {
                        if((dateDiff/168)/4 == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per month for %d month",round((CGFloat(cost)/CGFloat(participantsArr.count)/CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                        }
                        else if ((dateDiff/168)/4 == 0) {
                            cell1.calculationLabel.text = "You will need to top up £0 per month for 0 month"
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per month for %d months",round((CGFloat(cost)/CGFloat((participantsArr.count ))/CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                        }
                    }
                    
                }
            }
     
            if(isClearPressed) {
                cell1.calculationLabel.text = ""
            }
            return cell1
        }
        else if(indexPath.section == offerArr.count+2) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("CreateSavingPlanTableViewCellIdentifier", forIndexPath: indexPath) as! CreateSavingPlanTableViewCell
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if parameterDict["isUpdate"]!.isEqualToString("Yes") {
                cell1.createSavingPlanButton.setTitle("Join group", forState: UIControlState.Normal)
                cell1.createSavingPlanButton.addTarget(self, action: Selector("joinGroupButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            }
            else {
                cell1.createSavingPlanButton.addTarget(self, action: Selector("createSavingPlanButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            }
            return cell1
        }
        else if(indexPath.section == offerArr.count+3) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("ClearButtonIdentifier", forIndexPath: indexPath) as! ClearButtonTableViewCell
            cell1.tblView = tblView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            cell1.clearButton.addTarget(self, action: Selector("clearButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("OfferTableViewCellIdentifier", forIndexPath: indexPath) as! OfferTableViewCell
            cell1.tblView = tblView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            cell1.closeButton.tag = indexPath.section
            cell1.closeButton.addTarget(self, action: Selector("closeOfferButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            let dict = offerArr[indexPath.section - 2]
            cell1.offerTitleLabel.text = dict["offCompanyName"] as? String
            cell1.offerDetailLabel.text = dict["offTitle"] as? String
            cell1.descriptionLabel.text = dict["offSummary"] as? String
            let urlStr = dict["offImage"] as! String
            let url = NSURL(string: urlStr)
            let request: NSURLRequest = NSURLRequest(URL: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if (data != nil && data?.length > 0) {
                    let image = UIImage(data: data!)
                    dispatch_async(dispatch_get_main_queue(), {
                        cell1.offerImageView?.image = image
                    })
                }
            })
            return cell1
        }
    }
    
    //This is UITableViewDelegate method used to set the view for UITableView header.
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view : UIView = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    //This is UITableViewDelegate method used to set the height of header.
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    
    //This is UITableViewDelegate method used to set the height of rows per section.
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section == 0) {
            return 64
        }
        else if(indexPath.section == offerArr.count+2) {
            return 65
        }
        else if(indexPath.section == offerArr.count+3) {
            return 40
        }
        else if(indexPath.section == 1) {
            if(isDateChanged) {
                return 100
            }
            else {
                return 0
            }
        }
        else {
            return 60
        }
    }
    
    func getDateTextField(str: String) {
        selectedStr = str
        isDateChanged = true
        isClearPressed = false
        tblView.reloadData()
    }
    
    func segmentBarChanged(str: String) {
        if(str == "date") {
            dateString = "date"
        }
        else {
            dateString = "day"
        }
        isDateChanged = true
    }
    
    func closeOfferButtonPressed(sender:UIButton)
    {
        let indx = sender.tag - 2
        offerArr.removeAtIndex(indx)
        tblViewHt.constant =  tblView.frame.size.height - 65
        self.scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, self.tblView.frame.origin.y + self.tblView.frame.size.height)
        tblView.reloadData()
    }
    
    func displayAlert(message:String)
    {
        //Show of UIAlertView
        let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    //Dictionary to join the Group plan.
    func getParametersForUpdate() -> Dictionary<String,AnyObject>
    {
        var newDict : Dictionary<String,AnyObject> = [:]
        if parameterDict["isUpdate"]!.isEqualToString("No") {
            newDict["INIVITED_USER_LIST"] = participantsArr
        }
        newDict["PLAN_END_DATE"] = parameterDict["PLAN_END_DATE"]
        newDict["TITLE"] = parameterDict["title"]
        newDict["AMOUNT"] = parameterDict["amount"]
        newDict["PARTY_ID"] = parameterDict["pty_id"]
        newDict["PARTY_SAVINGPLAN_ID"] = parameterDict["sharedPtySavingPlanId"]
        if (parameterDict["imageURL"] != nil) {
            if(parameterDict["imageURL"] as! String != "")  {
                let imageData:NSData = UIImageJPEGRepresentation(topBgImageView.image!, 1.0)!
                let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                let dict = ["imageName.jpg":base64String]
                newDict["IMAGE"] = dict
            }
            else  {
                let dict = ["imageName.jpg":""]
                newDict["IMAGE"] = dict
            }
        }
        newDict["SAV_PLAN_ID"] = NSUserDefaults.standardUserDefaults().objectForKey("savPlanID")
        newDict["WISHLIST_ID"] = parameterDict["wishList_ID"] as! NSNumber
        newDict["PAY_DATE"] = selectedStr
        if(dateString == "date") {
            newDict["PAY_TYPE"] = "Month"
        }
        else {
            newDict["PAY_TYPE"] = "Week"
        }
        newDict["PARTY_SAVINGPLAN_TYPE"] = "Group"
        newDict["STATUS"] = "Active"
        var newOfferArray : Array<NSNumber> = []
        if offerArr.count>0 {
            for i in 0 ..< offerArr.count {
                let dict = offerArr[i]
                newOfferArray.append(dict["offId"] as! NSNumber)
            }
            newDict["OFFERS"] = newOfferArray
        }
        else {
            newDict["OFFERS"] = newOfferArray
        }
        return newDict
    }
    
    //Dictionary to send to the CreatePartySavingPlan API.
    func getParameters() -> Dictionary<String,AnyObject>
    {
        var newDict : Dictionary<String,AnyObject> = [:]
        newDict["PLAN_END_DATE"] = parameterDict["PLAN_END_DATE"]
        newDict["TITLE"] = parameterDict["title"]
        newDict["AMOUNT"] = parameterDict["amount"]
        newDict["PARTY_ID"] = parameterDict["pty_id"]
        newDict["SAV_PLAN_ID"] = parameterDict["sav_id"]
        if(parameterDict["imageURL"] as! String != "") {
            let dict = ["imageName.jpg":parameterDict["imageURL"] as! String]
            newDict["IMAGE"] = dict
        }
        else if(isImageClicked) {
            let imageData:NSData = UIImageJPEGRepresentation(topBgImageView.image!, 1.0)!
            let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            let dict = ["imageName.jpg":base64String]
            newDict["IMAGE"] = dict
        }
        else {
            let dict = ["imageName.jpg":""]
            newDict["IMAGE"] = dict
        }
        newDict["PAY_DATE"] = selectedStr as String
        if(dateString == "date") {
            newDict["PAY_TYPE"] = "Month"
        }
        else {
            newDict["PAY_TYPE"] = "Week"
        }
        var newOfferArray : Array<NSNumber> = []
        if offerArr.count>0 {
            for i in 0 ..< offerArr.count {
                let dict = offerArr[i]
                newOfferArray.append(dict["offId"] as! NSNumber)
            }
            newDict["OFFERS"] = newOfferArray
        }
        else {
            newDict["OFFERS"] = newOfferArray
        }
        newDict["PARTY_SAVINGPLAN_TYPE"] = "Group"
        newDict["STATUS"] = "Active"
        return newDict
    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        //Open camera or gallery as per users choice
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        alertController.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default)
        { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.imagePicker.allowsEditing = true
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            })
        alertController.addAction(UIAlertAction(title: "Choose Photo", style: UIAlertActionStyle.Default)
        { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.imagePicker.allowsEditing = true
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func createSavingPlanButtonPressed()
    {
        if isOfferShow == true {
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.navigationController!.view.addSubview(self.objAnimView)
            if(selectedStr != "")  {
                let objAPI = API()
                objAPI.partySavingPlanDelegate = self
                objAPI .createPartySavingPlan(self.getParameters(),isFromWishList: "notFromWishList")
            }
            else {
                self.objAnimView.removeFromSuperview()
                self.displayAlert("Please select date/day")
            }
        }
        else {
            let obj = SAOfferListViewController()
            obj.delegate = self
            if let savId = parameterDict["sav_id"] as? String {
                obj.savID = Int(savId)!
            }
            else if let savId = parameterDict["sav_id"] as? NSNumber {
                obj.savID = savId
            }
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    func clearButtonPressed()
    {
        let alert = UIAlertController(title: "Aru you sure?", message: "Do you want to clear all data", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
        { action -> Void in
            NSUserDefaults.standardUserDefaults().removeObjectForKey("InviteGroupArray")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.navigationController?.popViewControllerAnimated(true)
            self.delegate?.clearAll()
            })
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func joinGroupButtonPressed(sender:UIButton)
    {
        if isOfferShow == true {
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.navigationController!.view.addSubview(self.objAnimView)
            if(isDateChanged) {
                let objAPI = API()
                objAPI.partySavingPlanDelegate = self
                objAPI .createPartySavingPlan(self.getParametersForUpdate(),isFromWishList: "FromWishList")
            }
            else {
                self.objAnimView.removeFromSuperview()
                self.displayAlert("Please select date/day")
            }
        }
        else {
            let obj = SAOfferListViewController()
            obj.delegate = self
            if let savId = parameterDict["sav_id"] as? String {
                obj.savID = Int(savId)!
            }
            else if let savId = parameterDict["sav_id"] as? NSNumber {
                obj.savID = savId
            }
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    func addedOffers(offerForSaveArr:Dictionary<String,AnyObject>){
        offerArr.append(offerForSaveArr)
        tblViewHt.constant = tblView.frame.size.height + 65
        self.scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, self.tblView.frame.origin.y + self.tblView.frame.size.height)
        tblView.reloadData()
        isOfferShow = true
    }
    
    func skipOffers(){
        isOfferShow = true
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
    
    //Delegate methods of create group saving plan
    func successResponseForPartySavingPlanAPI(objResponse:Dictionary<String,AnyObject>)
    {
        print(objResponse)
        if(parameterDict["isUpdate"]!.isEqualToString("Yes")) {
            if let message = objResponse["message"] as? String {
                if(message == "Party Saving Plan is succesfully added") {
                   
                    NSUserDefaults.standardUserDefaults().setValue(objResponse["partySavingPlanID"] as? NSNumber, forKey: "PTY_SAVINGPLAN_ID")
                    NSUserDefaults.standardUserDefaults().setValue("GM", forKey: "usersPlan")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    let objPaymentView = SAPaymentFlowViewController()
                    objPaymentView.isFromGroupMemberPlan = true
                    self.navigationController?.pushViewController(objPaymentView, animated: true)
                    
                    objAnimView.removeFromSuperview()
                }
                else {
                    let alert = UIAlertView(title: "Alert", message: "Internal Server Error", delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                }
            }
            else {
                let alert = UIAlertView(title: "Alert", message: "Internal Server Error", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            objAnimView.removeFromSuperview()
        }
        else {
            if let message = objResponse["errorCode"] as? String {
                if(message == "200") {
                    participantsArr.removeLast()
                    var dict : Dictionary<String,AnyObject> = [:]
                    dict["INIVITED_USER_LIST"] = participantsArr
                    dict["PARTY_ID"] = parameterDict["pty_id"]
                   
                    NSUserDefaults.standardUserDefaults().setValue(objResponse["partySavingPlanID"] as? NSNumber, forKey: "PTY_SAVINGPLAN_ID")
                         NSUserDefaults.standardUserDefaults().setValue("G", forKey: "usersPlan")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    let objAPI = API()
                    objAPI.inviteMemberDelegate = self
                    objAPI.sendInviteMembersList(dict)
                    
                }
                else {
                    let alert = UIAlertView(title: "Warning", message: objResponse["userMessage"] as! String, delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                    objAnimView.removeFromSuperview()
                }
            }
            else {
                let alert = UIAlertView(title: "Warning", message: objResponse["error"] as! String, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
                objAnimView.removeFromSuperview()
            }
        }
        
    }
    
    func errorResponseForPartySavingPlanAPI(error:String) {
        let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView.removeFromSuperview()
    }
    
    //Delegate methods of Invite members API
    
    func successResponseForInviteMembersAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let message = objResponse["message"] as? String  {
            if(message == "Invited user successfully") {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("InviteGroupArray")
                var newDict : Dictionary<String,AnyObject> = [:]
                newDict["title"] = self.getParameters()["TITLE"]
                newDict["amount"] = self.getParameters()["AMOUNT"]
                newDict["PAY_DATE"] = self.getParameters()["PAY_DATE"]
                let dict = self.getParameters()["IMAGE"]
                newDict["imageURL"] = dict
                newDict["INIVITED_USER_LIST"] = participantsArr
                newDict["day"] = dateString
                let dateParameter = NSDateFormatter()
                dateParameter.dateFormat = "yyyy-MM-dd"
                newDict["PLAN_END_DATE"] = self.getParameters()["PLAN_END_DATE"]
                if(dateString == "day") {
                    if(dateDiff > 0)
                    {
                        newDict["emi"] = String(format:"%d",cost/(dateDiff/168))
                    }
                    else {
                        newDict["emi"] = String(format:"%d",cost)
                    }

                    newDict["payType"] = "Weekly"
                }
                else {
                    if(dateDiff > 0)
                    {
                        newDict["emi"] = String(format:"%d",cost/((dateDiff/168)/4))
                    }
                    else {
                        newDict["emi"] = String(format:"%d",cost)
                    }
                    newDict["payType"] = "Monthly"
                }
                if offerArr.count>0 {
                    newDict["offers"] = offerArr
                }
     
              
                if(dateString == "day") {
                    if(dateDiff > 0)
                    {
                         newDict["emi"] = String(format:"%d",(cost/(participantsArr.count))/(dateDiff/168))
                    }
                    else {
                         newDict["emi"] = String(format:"%d",cost/(participantsArr.count))
                    }
                   
                }
                else {
                    if(dateDiff > 0)
                    {
                        newDict["emi"] = String(format:"%d",(cost/(participantsArr.count))/((dateDiff/168)/4))
                    }
                    else {
                        newDict["emi"] = String(format:"%d",cost/(participantsArr.count))
                    }
                    
                }
                newDict["planType"] = "group"
                
                let objAPI = API()
                objAPI.storeValueInKeychainForKey("savingPlanDict", value: self.checkNullDataFromDict(newDict))
                
                if let saveCardArray =  objAPI.getValueFromKeychainOfKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
                {
                    let objSavedCardView = SASaveCardViewController()
                    objSavedCardView.isFromSavingPlan = true
                    self.navigationController?.pushViewController(objSavedCardView, animated: true)
                    
                }else {
                    let objPaymentView = SAPaymentFlowViewController()
                    self.navigationController?.pushViewController(objPaymentView, animated: true)
                }

            }
        }
        objAnimView.removeFromSuperview()
    }
    
    func errorResponseForInviteMembersAPI(error: String) {
        let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView.removeFromSuperview()
    }
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        topBgImageView.contentMode = UIViewContentMode.ScaleAspectFill
        topBgImageView.layer.masksToBounds = true
        topBgImageView?.image = (info[UIImagePickerControllerEditedImage] as? UIImage)
        cameraButton.hidden = true
        isImageClicked = true
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("InviteGroupArray")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
