 //
 //  GroupsavingViewController.swift
 //  Savio
 //
 //  Created by Maheshwari on 22/06/16.
 //  Copyright © 2016 Prashant. All rights reserved.
 //
 
 import UIKit
 import AddressBook
 import AddressBookUI
 
 class GroupsavingViewController: UIViewController,SavingPlanTitleTableViewCellDelegate,SavingPlanCostTableViewCellDelegate,SavingPlanDatePickerCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ABPeoplePickerNavigationControllerDelegate,SAContactViewDelegate,UITableViewDelegate,UITableViewDataSource,SACreateGroupSavingPlanDelegate {
    
    @IBOutlet weak var topBackgroundImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    @IBOutlet weak var contentViewHt: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tblViewHt: NSLayoutConstraint!
    @IBOutlet weak var scrlView: UIScrollView!
    
    var cost : Int = 0
    var imageDataDict : Dictionary<String,AnyObject> = [:]
    var dateDiff : Int = 0
    var dateString = "date"
    var popOverSelectedStr = ""
    var datePickerDate : String = ""
    var itemTitle : String = ""
    var itemDetailsDataDict : Dictionary<String,AnyObject> = [:]
    var participantsArr: Array<Dictionary<String,AnyObject>> = []
    var userInfoDict  : Dictionary<String,AnyObject> = [:]
    var objAnimView = ImageViewAnimation()
    var isClearPressed = false
    var addressBook: ABPeoplePickerNavigationController?
    var isFromWishList = false
    var isImageclicked = false
    var imagePicker = UIImagePickerController()
    var isContactAdded = false
    var groupArrayCount = 0
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "GothamRounded-Medium", size: 16)!]
        self.title = "Plan setup"
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        tblView!.registerNib(UINib(nibName: "SavingPlanTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanTitleIdentifier")
        tblView!.registerNib(UINib(nibName: "SavingPlanCostTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanCostIdentifier")
        tblView!.registerNib(UINib(nibName: "SavingPlanDatePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanDatePickerIdentifier")
        tblView!.registerNib(UINib(nibName: "SavingPlanDatePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanDatePickerIdentifier")
        tblView!.registerNib(UINib(nibName: "InviteFriendsButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteFriendsButtonCellIdentifier")
        tblView!.registerNib(UINib(nibName: "GroupParticipantNameTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupParticipantNameTableViewCellIdentifier")
        tblView!.registerNib(UINib(nibName: "NextButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "NextButtonCellIdentifier")
        tblView!.registerNib(UINib(nibName: "ClearButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ClearButtonIdentifier")
        
        let objAPI = API()
        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        
        if let array =  NSUserDefaults.standardUserDefaults().objectForKey("InviteGroupArray") as? Array<Dictionary<String,AnyObject>>  {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("InviteGroupArray")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        topBackgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        topBackgroundImageView.layer.masksToBounds = true
        
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
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setTitle(String(format:"%d",wishListArray!.count), forState: UIControlState.Normal)
            //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
            if(wishListArray!.count > 0) {
                
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
        
        //Get image for the saving plan
        if let urlString = itemDetailsDataDict["imageURL"] as? String {
            let url = NSURL(string:urlString)
            
            let request: NSURLRequest = NSURLRequest(URL: url!)
            if(urlString != "") {
                
                //Add spinner to UIImageView until image loads
                let spinner =  UIActivityIndicatorView()
                spinner.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, topBackgroundImageView.frame.size.height/2)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
                topBackgroundImageView.addSubview(spinner)
                spinner.startAnimating()
                //load the image from URL
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                    if(data?.length > 0) {
                        let image = UIImage(data: data!)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            //Remove the spinner after image load
                            spinner.stopAnimating()
                            spinner.hidden = true
                            self.cameraButton.hidden = true
                            self.topBackgroundImageView.image = image
                        })
                    }
                    else {
                        //Remove the spinner after image load
                        spinner.stopAnimating()
                        spinner.hidden = true
                    }
                })
            }
            else {
                imageDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
                cameraButton.hidden = false
                
            }
            isFromWishList = true
            itemTitle = itemDetailsDataDict["title"] as! String
            cost = Int(itemDetailsDataDict["amount"] as! NSNumber)
            groupArrayCount = Int(itemDetailsDataDict["totalMembers"] as! NSNumber)
        }
        else {
            imageDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
            self.cameraButton.hidden = false
            isFromWishList = false
        }
        let ht : CGFloat = 100
        scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblView.frame.size.height + ht)
        contentViewHt.constant = contentViewHt.constant + 35
        tblViewHt.constant = tblViewHt.constant + 35
        
    }
    
    //Navigation bar button action methods
    func backButtonClicked()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func heartBtnClicked(){
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData {
            
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>
            
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        objAnimView.removeFromSuperview()
    }
    
    func clearAll() {
        self.setUpView()
        self.dateDiff = 0
        self.cost = 0
        NSUserDefaults.standardUserDefaults().removeObjectForKey("InviteGroupArray")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.itemTitle = ""
        self.isClearPressed = true
        self.popOverSelectedStr = ""
        if(participantsArr.count > 0) {
            participantsArr.removeAll()
        }
        if(self.itemDetailsDataDict.keys.count > 0) {
            self.itemDetailsDataDict.removeAll()
        }
        self.topBackgroundImageView.image = UIImage(named:"groupsave-setup-bg.png")
        self.tblViewHt.constant = 500
        self.scrlView.contentOffset = CGPointMake(0, 20)
        self.scrlView.contentSize = CGSizeMake(0, self.tblView.frame.origin.y + self.tblViewHt.constant)
        self.tblView.reloadData()
    }
    
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        //Open camera or gallery as per users selection
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
    
    //MARK: - Addressbook integration
    func showAddressBook(){
        addressBook = ABPeoplePickerNavigationController()
        addressBook?.peoplePickerDelegate = self
        self.presentViewController(addressBook!, animated: true, completion: nil)
        
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController) {
        addressBook?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, shouldContinueAfterSelectingPerson person: ABRecord) -> Bool {
        return true
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        var contactDict: Dictionary<String,AnyObject> = [:]
        //Get person's last name
        
        if  (ABRecordCopyValue(person, kABPersonLastNameProperty) != nil){
            
            if  (ABRecordCopyValue(person, kABPersonFirstNameProperty) != nil){
                if let firstName: ABMultiValueRef = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue(){
                    contactDict["name"] = firstName as! String
                }
            }
            else {
                contactDict["name"] = ""
            }
            
            if let lastName: ABMultiValueRef = ABRecordCopyValue(person, kABPersonLastNameProperty).takeRetainedValue(){
                contactDict["lastName"] = lastName as! String
            }
        }
        else { //Get person's first name
            if  (ABRecordCopyValue(person, kABPersonFirstNameProperty) != nil){
                if let firstName: ABMultiValueRef = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue(){
                    contactDict["name"] = firstName as! String
                }
            }
            else {
                contactDict["name"] = ""
            }
            contactDict["lastName"] = ""
            
        }
        
        //Get Phone Number
        
        var phoneNumber:String?;
        let unmanagedPhones:Unmanaged? = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if(unmanagedPhones != nil) {
            let index = 0 as CFIndex
            let phoneNumbers = unmanagedPhones?.takeRetainedValue();
            
            if(ABMultiValueGetCount(phoneNumbers) > 0) {
                
                phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbers, index).takeRetainedValue() as? String;
                contactDict["mobileNum"] = phoneNumber
                
            } else {
                phoneNumber = "Phone Number is empty!";
            }
        }
        
        //Get person's email id
        if (ABRecordCopyValue(person, kABPersonEmailProperty) != nil)  {
            let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
            if ABMultiValueGetCount(emails) > 0 {
                let index = 0 as CFIndex
                let emailAddress = ABMultiValueCopyValueAtIndex(emails, index).takeRetainedValue() as! String
                contactDict["email"] = emailAddress
            } else {
                print("No email address")
            }
        }
        
        var pic: UIImage?
        let picTemp1 = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)
        if picTemp1 == nil {
            pic = nil
        }
        else {
            let picTemp2: NSObject? = Unmanaged<NSObject>.fromOpaque(picTemp1!.toOpaque()).takeRetainedValue()
            if picTemp2 != nil {
                pic = UIImage(data: picTemp2! as! NSData)!
                contactDict["imageData"] = pic
            }
        }
        
        let contactView = ContactViewController()
        contactView.delegate = self
        contactView.contactDict = contactDict
        self.navigationController?.pushViewController(contactView, animated: true)
        
    }
    //Add contact delegate methods
    func addedContact(contactDict: Dictionary<String, AnyObject>) {
        isContactAdded = true
        participantsArr.append(contactDict)
        NSUserDefaults.standardUserDefaults().setObject(participantsArr, forKey:"InviteGroupArray")
        NSUserDefaults.standardUserDefaults().synchronize()
        contentViewHt.constant = contentViewHt.constant + 40
        tblViewHt.constant = tblViewHt.constant + 40
        scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblView.frame.size.height + 40)
        tblView.reloadData()
    }
    
    func skipContact(){
        isContactAdded = true
    }
    
    // MARK: - UITableViewDelegate methods
    //return the number of sections in table view.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if itemDetailsDataDict["title"] != nil {
            return 4
        } else {
            return 7
        }
    }
    
    //return the number of rows in each section in table view.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 4) {
            return participantsArr.count
            
        }
        else {
            return 1
        }
    }
    
    //create custom cell from their respective Identifiers.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if(indexPath.section == 0)  {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanTitleIdentifier", forIndexPath: indexPath) as! SavingPlanTitleTableViewCell
            cell1.tblView = tblView
            cell1.view = self.scrlView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            cell1.savingPlanTitleDelegate = self
            if(itemDetailsDataDict["title"] != nil) {
                cell1.titleTextField.text = itemDetailsDataDict["title"] as? String
                cell1.titleTextField.userInteractionEnabled = false
                itemTitle = itemDetailsDataDict["title"] as! String
                
            }
            if(isClearPressed) {
                cell1.titleTextField.text = itemTitle
            }
            cell1.titleTextField.textColor = UIColor(red: 161/256, green: 214/256, blue: 248/256, alpha: 1.0)
            return cell1
        }
        else if(indexPath.section == 1){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanCostIdentifier", forIndexPath: indexPath) as! SavingPlanCostTableViewCell
            cell1.tblView = tblView
            cell1.delegate = self
            cell1.view = self.scrlView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            
            if(itemDetailsDataDict["amount"] != nil)
            {
                if(itemDetailsDataDict["amount"] is String)
                {
                    let amountString = "£" + String(itemDetailsDataDict["amount"])
                    
                    cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                    cell1.slider.value = (itemDetailsDataDict["amount"] as! NSString).floatValue
                    cost = Int(cell1.slider.value)
                }
                else
                {
                    let amountString = "£" + String(format: "%d", (itemDetailsDataDict["amount"] as! NSNumber).intValue)
                    cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                    cell1.slider.value = (itemDetailsDataDict["amount"] as! NSNumber).floatValue
                    cost = Int(cell1.slider.value)
                }
                cell1.costTextField.userInteractionEnabled = false
                cell1.slider.userInteractionEnabled = false
                cell1.minusButton.userInteractionEnabled = false
                cell1.plusButton.userInteractionEnabled = false
                cost = Int(cell1.slider.value)
            }
            else if( isContactAdded == true) {
                let amountString = "£" + String(format: "%d", cost)
                cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                cell1.slider.value =  Float(cost)
                cost = Int(cell1.slider.value)
            }
            else {
                cell1.costTextField.attributedText = cell1.createAttributedString("£0")
                cell1.slider.value = 0
                cost = 0
            }
            if(isClearPressed)
            {
                cell1.costTextField.attributedText = cell1.createAttributedString("£0")
                cell1.slider.value = 0
                cost = 0
            }
            return cell1
        }
        else if(indexPath.section == 2) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanDatePickerIdentifier", forIndexPath: indexPath) as! SavingPlanDatePickerTableViewCell
            cell1.tblView = tblView
            cell1.savingPlanDatePickerDelegate = self
            cell1.view = self.scrlView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            
            if(itemDetailsDataDict["planEndDate"] != nil) {
                cell1.datePickerTextField.text = itemDetailsDataDict["planEndDate"] as? String
                cell1.datePickerTextField.textColor = UIColor.whiteColor()
                cell1.datePickerTextField.userInteractionEnabled = false
                let date  = itemDetailsDataDict["planEndDate"] as? String
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                var pathComponents2 : NSArray!
                pathComponents2 = (itemDetailsDataDict["planEndDate"] as! String).componentsSeparatedByString("-")
                datePickerDate = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
                let timeDifference : NSTimeInterval = dateFormatter.dateFromString(date!)!.timeIntervalSinceDate(NSDate())
                cell1.datePickerTextField.text = datePickerDate
                dateDiff = Int(timeDifference/3600)
                
            }
            if(isClearPressed) {
                let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let currentDate: NSDate = NSDate()
                let components: NSDateComponents = NSDateComponents()
                components.day = +7
                let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                cell1.datePickerTextField.text = dateFormatter.stringFromDate(minDate)
                
            }
            return cell1
        }
        else if(indexPath.section == 3) {
            if(itemDetailsDataDict["title"] == nil) {
                
                let cell1 = tableView.dequeueReusableCellWithIdentifier("InviteFriendsButtonCellIdentifier", forIndexPath: indexPath) as! InviteFriendsButtonTableViewCell
                if(participantsArr.count == 0) {
                    cell1.layer.cornerRadius = 5
                    cell1.layer.masksToBounds = true
                }
                else {
                    cell1.layer.cornerRadius = 0
                    let maskPath: UIBezierPath = UIBezierPath(roundedRect: cell1.bounds, byRoundingCorners: ([.TopLeft,.TopRight]), cornerRadii: CGSizeMake(5.0, 5.0))
                    let maskLayer: CAShapeLayer = CAShapeLayer()
                    maskLayer.frame = cell1.bounds
                    maskLayer.path = maskPath.CGPath
                    cell1.layer.mask = maskLayer
                }
                if(itemDetailsDataDict["title"] != nil) {
                    cell1.inviteButton.userInteractionEnabled = false
                }
                cell1.inviteButton.addTarget(self, action: Selector("inviteButtonPressed"), forControlEvents: .TouchUpInside)
                if(participantsArr.count > 0) {
                    cell1.bottomBorderLabel.hidden = false
                }
                else {
                    cell1.bottomBorderLabel.hidden = true
                }
                return cell1
            }
            else {
                let cell1 = tableView.dequeueReusableCellWithIdentifier("NextButtonCellIdentifier", forIndexPath: indexPath) as! NextButtonTableViewCell
                cell1.tblView = tblView
                
                cell1.nextButton.addTarget(self, action: Selector("nextButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
                return cell1
            }
            
        }
        else if(indexPath.section == 5) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("NextButtonCellIdentifier", forIndexPath: indexPath) as! NextButtonTableViewCell
            cell1.tblView = tblView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if(itemDetailsDataDict["title"] != nil) {
                cell1.nextButton.setTitle("Join group", forState: UIControlState.Normal)
                cell1.nextButton.addTarget(self, action: Selector("nextButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            }
            else {
                cell1.nextButton.addTarget(self, action: Selector("nextButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            }
            return cell1
        }
        else if(indexPath.section ==  6) {
            
            let cell1 = tableView.dequeueReusableCellWithIdentifier("ClearButtonIdentifier", forIndexPath: indexPath) as! ClearButtonTableViewCell
            cell1.tblView = tblView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if(itemDetailsDataDict["title"] != nil) {
                cell1.clearButton.userInteractionEnabled = false
            }
            cell1.clearButton.addTarget(self, action: Selector("clearButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
            
        else {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("GroupParticipantNameTableViewCellIdentifier", forIndexPath: indexPath) as! GroupParticipantNameTableViewCell
            if(indexPath.row  == (participantsArr.count - 1)) {
                let maskPath: UIBezierPath = UIBezierPath(roundedRect: cell1.bounds, byRoundingCorners: ([.BottomLeft,.BottomRight]), cornerRadii: CGSizeMake(5.0, 5.0))
                
//                let maskPath1: UIBezierPath = UIBezierPath(roundedRect: cell1.bounds, byRoundingCorners: ([.TopLeft,.TopRight]), cornerRadii: CGSizeMake(1.0, 1.0))
//                
//                let combinedPath : CGMutablePathRef = CGPathCreateMutableCopy(maskPath.CGPath)!
//                CGPathAddPath(combinedPath, nil, maskPath1.CGPath)
                
                let maskLayer: CAShapeLayer = CAShapeLayer()
                maskLayer.frame = cell1.bounds
                maskLayer.path = maskPath.CGPath
                cell1.layer.mask = maskLayer
            }
            else {
                let maskPath: UIBezierPath = UIBezierPath(roundedRect: cell1.bounds, byRoundingCorners: ([.BottomLeft,.BottomRight,.TopLeft,.TopRight]), cornerRadii: CGSizeMake(0, 0))
                let maskLayer: CAShapeLayer = CAShapeLayer()
                maskLayer.frame = cell1.bounds
                maskLayer.backgroundColor = UIColor(red:90/255,green:90/255,blue:100/255,alpha:1).CGColor
                maskLayer.path = maskPath.CGPath
                
                cell1.layer.mask = maskLayer
            }
            
            if(participantsArr.count != 0) {
                let dict = participantsArr[indexPath.row]
                cell1.ParticipantsNameLabel.text = dict["first_name"] as? String
                if (dict["email_id"] as? String != "") {
                    cell1.phoneOrEmailLabel.text = dict["email_id"] as? String
                }
                else {
                    cell1.phoneOrEmailLabel.text = dict["mobile_number"] as? String
                }
                cell1.deleteContactButton.addTarget(self, action:  Selector("deleteContactButtonPressed:"), forControlEvents: .TouchUpInside)
                cell1.deleteContactButton.tag = indexPath.row
                
            }
            return cell1
        }
        
    }
    
    func deleteContactButtonPressed(sender:UIButton)
    {
        let alert = UIAlertController(title: "Are you sure?", message: "You want to delete this person from list", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
        { action -> Void in
            self.participantsArr.removeAtIndex(sender.tag)
            self.contentViewHt.constant = self.contentViewHt.constant - 40
            self.tblViewHt.constant = self.tblViewHt.constant - 40
            self.scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, self.tblView.frame.origin.y + self.tblView.frame.size.height - 40)
            self.tblView.reloadData()
            
            })
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func inviteButtonPressed()
    {
        if(participantsArr.count == 7) {
            self.displayAlert(" You can't add more than 7 contacts into group saving plan")
        }
        else {
            self.showAddressBook()
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
        if(section == 4) {
            if(participantsArr.count > 0) {
                return 0
                
            }
            else {
                return 3
            }
        }
        else {
            return 3
        }
    }
    
    //This is UITableViewDelegate method used to set the height of rows per section.
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.section == 0) {
            return 44
        }
        else if(indexPath.section == 1) {
            return 90
        }
        else if(indexPath.section == 2) {
            return 70
        }
        else if(indexPath.section == 3) {
            return 119
        }
        else if(indexPath.section ==   4) {
            if(participantsArr.count == 0) {
                return 0
            }
            else {
                return 35
            }
        }
        else if(indexPath.section ==   5) {
            return 65
        }
        else {
            return 40
        }
        
    }
    
    //Create Dictionary to send to the CreatePartySavingPlan API.
    func getParameters() -> Dictionary<String,AnyObject>
    {
        var parameterDict : Dictionary<String,AnyObject> = [:]
        
        if(itemDetailsDataDict["id"] != nil) {
            parameterDict["wishList_ID"] = itemDetailsDataDict["id"] as! NSNumber
        }
        
        if(itemDetailsDataDict["savingId"] != nil) {
            parameterDict["sav_id"] = itemDetailsDataDict["savingId"] as! NSNumber
        }
        
        if(itemDetailsDataDict["sharedPtySavingPlanId"] != nil) {
            parameterDict["sharedPtySavingPlanId"] = itemDetailsDataDict["sharedPtySavingPlanId"] as! NSNumber
        }
        
        if(itemDetailsDataDict["title"] != nil) {
            parameterDict["title"] = itemDetailsDataDict["title"]
            parameterDict["isUpdate"] = "Yes"
        }
        else {
            parameterDict["title"] = itemTitle
            parameterDict["isUpdate"] = "No"
        }
        
        if(itemDetailsDataDict["amount"] != nil) {
            parameterDict["amount"]  = String(format: "%d", cost)
        }
        else {
            parameterDict["amount"] = String(format:"%d",cost)
        }
        
        if(itemDetailsDataDict["imageURL"] != nil && (itemDetailsDataDict["imageURL"] as! String).characters.count != 0) {
            
            let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
            let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            parameterDict["imageURL"] = base64String
        }
        else {
            if(cameraButton.hidden == true) {
                let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                parameterDict["imageURL"] = base64String
            }
            else {
                parameterDict["imageURL"] = ""
            }
        }
        
        let dateParameter = NSDateFormatter()
        dateParameter.dateFormat = "yyyy-MM-dd"
        if(itemDetailsDataDict["planEndDate"] != nil) {
            parameterDict["PLAN_END_DATE"] = itemDetailsDataDict["planEndDate"]
        }
        else {
            if(datePickerDate != "") {
                var pathComponents : NSArray!
                pathComponents = (datePickerDate).componentsSeparatedByString(" ")
                var dateStr = pathComponents.lastObject as! String
                dateStr = dateStr.stringByReplacingOccurrencesOfString("/", withString: "-")
                var pathComponents2 : NSArray!
                pathComponents2 = dateStr.componentsSeparatedByString("-")
                parameterDict["PLAN_END_DATE"] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
            }
        }
        
        parameterDict["INIVITED_DATE"] = dateParameter.stringFromDate(NSDate())
        parameterDict["pty_id"] = userInfoDict["partyId"]
        if(itemDetailsDataDict["savingId"] != nil) {
            parameterDict["sav_id"] = itemDetailsDataDict["savingId"]
        }
        else {
            if((imageDataDict["sav-id"]) != nil) {
                parameterDict["sav_id"] = imageDataDict["sav-id"]
            }
            else if(imageDataDict["savPlanID"] != nil) {
                parameterDict["sav_id"] = imageDataDict["savPlanID"]
            }
            else {
                parameterDict["sav_id"] = itemDetailsDataDict["sav-id"]
            }
        }
        parameterDict["dateDiff"] = String(format:"%d",dateDiff)
        parameterDict["participantsArr"] = participantsArr
        parameterDict["payDate"] = itemDetailsDataDict["payDate"]
        return parameterDict
    }
    
    func getTextFieldText(text: String) {
        itemTitle = text
    }
    
    func txtFieldCellText(txtFldCell: SavingPlanCostTableViewCell) {
        cost = Int(txtFldCell.slider.value)
    }
    
    func datePickerText(date: Int,dateStr:String) {
        dateDiff = date
        datePickerDate = dateStr
    }
    
    
    func nextButtonPressed(sender:UIButton) {
        self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        self.objAnimView.frame = self.view.frame
        self.objAnimView.animate()
        self.navigationController!.view.addSubview(self.objAnimView)
        
        if(isFromWishList) {
            if(itemTitle != "" && cost != 0 && dateDiff != 0 && datePickerDate != "") {
                let objGroupSavingPlanView = SACreateGroupSavingPlanViewController(nibName: "SACreateGroupSavingPlanViewController",bundle: nil)
                objGroupSavingPlanView.parameterDict = self.getParameters()
                objGroupSavingPlanView.delegate = self
                objGroupSavingPlanView.groupMemberCount = groupArrayCount
                self.navigationController?.pushViewController(objGroupSavingPlanView, animated: true)
                objAnimView.removeFromSuperview()
            }
            else {
                self.objAnimView.removeFromSuperview()
                if(itemTitle == "") {
                    self.displayAlert("Please enter title for your saving plan")
                }
                else if(cost == 0 ) {
                    self.displayAlert("Please enter amount for your saving plan")
                }
                else if(dateDiff == 0) {
                    self.displayAlert("Please select date for your saving plan")
                }
                else  {
                    self.displayAlert("Please enter all details")
                }
            }
        }
        else {
            if(itemTitle != "" && self.getParameters()["amount"] != nil && cost != 0 && dateDiff != 0 && datePickerDate != ""  && participantsArr.count > 0) {
                let objGroupSavingPlanView = SACreateGroupSavingPlanViewController(nibName: "SACreateGroupSavingPlanViewController",bundle: nil)
                objGroupSavingPlanView.parameterDict = self.getParameters()
                objGroupSavingPlanView.delegate = self
                self.navigationController?.pushViewController(objGroupSavingPlanView, animated: true)
                objAnimView.removeFromSuperview()
                
            }
            else {
                self.objAnimView.removeFromSuperview()
                var array : Array<String> = []
                self.objAnimView.removeFromSuperview()
                
                if(itemTitle == "") {
                    array.append("  Please enter title.")
                }
                if(cost == 0) {
                    array.append("  Please enter amount.")
                }
                if(dateDiff == 0 ) {
                    array.append("  Please select date.")
                }
                if(participantsArr.count == 0) {
                    array.append("  Please add atleast one contact.")
                }
                self.displayAlert(String(format:"%@",array.joinWithSeparator("\n")))
            }
        }
    }
    
    
    func displayAlert(message:String)
    {
        //Show of UIAlertView
        let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    
    func clearButtonPressed() {
        
        let alert = UIAlertController(title: "Aru you sure?", message: "Do you want to clear all data", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
        { action -> Void in
            self.setUpView()
            self.dateDiff = 0
            self.cost = 0
            self.itemTitle = ""
            self.isClearPressed = true
            self.popOverSelectedStr = ""
            if(self.itemDetailsDataDict.keys.count > 0) {
                self.itemDetailsDataDict.removeAll()
            }
            NSUserDefaults.standardUserDefaults().removeObjectForKey("InviteGroupArray")
            NSUserDefaults.standardUserDefaults().synchronize()
            if(self.participantsArr.count > 0) {
                self.participantsArr.removeAll()
            }
            self.topBackgroundImageView.image = UIImage(named:"groupsave-setup-bg.png")
            self.tblViewHt.constant = 500
            self.scrlView.contentOffset = CGPointMake(0, 20)
            self.scrlView.contentSize = CGSizeMake(0, self.tblView.frame.origin.y + self.tblViewHt.constant)
            self.tblView.reloadData()
            })
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        topBackgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        topBackgroundImageView.layer.masksToBounds = true
        topBackgroundImageView?.image = (info[UIImagePickerControllerEditedImage] as? UIImage)
        cameraButton.hidden = true
        isImageclicked = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
 }
