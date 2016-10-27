//
//  SAEditUserInfoViewController.swift
//  Savio
//
//  Created by Vishal  on 11/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAEditUserInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,TxtFieldTableViewCellDelegate,TitleTableViewCellDelegate,FindAddressCellDelegate,ButtonCellDelegate,PostCodeVerificationDelegate,DropDownTxtFieldTableViewCellDelegate,PickerTxtFieldTableViewCellDelegate,ImportantInformationViewDelegate,NumericTxtTableViewCellDelegate,EmailTxtTableViewCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GetUserInfoDelegate,UpdateUserInfoDelegate{
    
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addProfilePictureButton: UIButton!
    @IBOutlet weak var contentViewHt: NSLayoutConstraint!
    @IBOutlet weak var tblViewHt: NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    
    var arrRegistration  = [Dictionary <String, AnyObject>]()     //Array for hold json file data to create UI
    var arrRegistrationFields = [UITableViewCell]()               //Array of textfield cell
    var dictForTextFieldValue : Dictionary<String, AnyObject> = [:] // dictionary for saving user data and error messages
    var objAnimView : ImageViewAnimation?                     //Instance of ImageViewAnimation to showing loding aniation on API call
    var arrAddress = [String]()
    var firstName = ""
    var lastName = ""
    var dateOfBirth = ""
    var phoneNumber = ""
    var editUser = true
    var isImageClicked = false
    var image1 = UIImage(named: "img1")
    var getUserInfoDelegate = GetUserInfoDelegate.self
    var imagePicker = UIImagePickerController()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var userInfoDict : Dictionary<String,AnyObject> = [:]
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        addProfilePictureButton.setTitle("Add\n profile\n picture", forState: .Normal)
        addProfilePictureButton.titleLabel?.lineBreakMode =  NSLineBreakMode.ByWordWrapping
        addProfilePictureButton.titleLabel?.textAlignment = .Center
        addProfilePictureButton.titleLabel?.numberOfLines = 0
        addProfilePictureButton.layer.cornerRadius = addProfilePictureButton.frame.size.height/2
        
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView!.frame = self.view.frame
        objAnimView!.animate()
        self.view.addSubview(objAnimView!)
        
        let objAPI = API()
        objAPI.getUserInfoDelegate = self
        objAPI.getUserInfo()
        self.setUPNavigation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUPNavigation()
    {
        self.navigationController?.navigationBarHidden = false
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
        self.title = "Personal settings"
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
    
    func getJSONForUI(){
        //create file url
        let fileUrl: NSURL = NSBundle.mainBundle().URLForResource("Registration", withExtension: "json")!
        //getting file data
        let jsonData: NSData = NSData(contentsOfURL: fileUrl)!
        //parsing json file to setup UI
        let json = (try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments))
        self.arrRegistration = json as! Array
    }
    
    func createCells(){
        // if any old cell belong in array then remove all
        if arrRegistrationFields.count>0{
            arrRegistrationFields.removeAll()
        }
        for i in 0 ..< arrRegistration.count {
            // dictionary to identifying cell and its properies
            let dict = arrRegistration[i] as Dictionary<String,AnyObject>
            //get tableviewCell as per the classtype
            let bundleArr : Array = NSBundle.mainBundle().loadNibNamed(dict["classType"] as! String, owner: nil, options: nil)
            
            //Setup all error message lable tableViewCell
            if dict["classType"]!.isEqualToString("ErrorTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! ErrorTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                let tfTitleDict = metadataDict["lable"]as! Dictionary<String,AnyObject>
                //Set Error messages to error lable
                cell.lblError?.text = tfTitleDict["title"] as? String
                let isErrorShow = tfTitleDict["isErrorShow"] as! String
                //identifying to which error message show for textfield
                
                if isErrorShow == "Yes"{
                    arrRegistrationFields.append(cell)
                }
            }
            
            //SetUp Titel and Name textfield tableView cell and its validation messages
            if dict["classType"]!.isEqualToString("TitleTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! TitleTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.dict = dict
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                cell.tfTitle?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                cell.tfName?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                
                cell.tfTitle!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                if(editUser)
                {
                    cell.tfTitle!.userInteractionEnabled = false
                    cell.tfTitle?.text = userInfoDict["title"] as? String
                }
                if (dictForTextFieldValue["title"] != nil){
                    cell.tfTitle?.text = dictForTextFieldValue["title"] as? String
                }
                let tfNameDict = metadataDict["textField2"]as! Dictionary<String,AnyObject>
                cell.tfName!.attributedPlaceholder = NSAttributedString(string:(tfNameDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if(editUser)
                {
                    cell.tfName?.text = userInfoDict["first_name"] as? String
                }
                if (dictForTextFieldValue["name"] != nil){
                    cell.tfName?.text = dictForTextFieldValue["name"] as? String
                }
                
                if (dictForTextFieldValue["errorTitle"] != nil) {
                    if dictForTextFieldValue["errorTitle"]!.isEqualToString("We need to know your title and name"){
                        cell.tfName?.layer.borderColor = UIColor.redColor().CGColor
                        cell.tfTitle?.layer.borderColor = UIColor.redColor().CGColor
                    }
                    else if dictForTextFieldValue["errorTitle"]!.isEqualToString("Please select a title"){
                        cell.tfTitle?.layer.borderColor = UIColor.redColor().CGColor
                    }
                    else if dictForTextFieldValue["errorTitle"]!.isEqualToString("We need to know what to call you"){
                        cell.tfName?.layer.borderColor = UIColor.redColor().CGColor
                    }
                    else if (dictForTextFieldValue["errorTitle"]!.isEqualToString("Wow, that’s such a long name we can’t save it") || dictForTextFieldValue["errorTitle"]!.isEqualToString("Surname should contain character only") ){
                        cell.tfName?.textColor = UIColor.redColor()
                    }
                }
                arrRegistrationFields.append(cell)
                
            }
            if dict["classType"]!.isEqualToString("TxtFieldTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! TxtFieldTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.blackColor()
                
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                
                
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorTxt"] != nil && cell.tf?.placeholder == "Surname") {
                    let str = dictForTextFieldValue["errorTxt"]
                    if (str!.isEqualToString("We need to know your surname")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                
                if (dictForTextFieldValue["errorSurname"] != nil && cell.tf?.placeholder == "Surname") {
                    let str = dictForTextFieldValue["errorSurname"]
                    if (str!.isEqualToString("Wow, that’s such a long name we can’t save it")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                    }
                }
                
                if (dictForTextFieldValue["errorFirstAddress"] != nil && cell.tf?.placeholder == "First Address Line") {
                    let str = dictForTextFieldValue["errorFirstAddress"]
                    if (str!.isEqualToString("Don’t forget your house number")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorTown"] != nil && cell.tf?.placeholder == "Town") {
                    let str = dictForTextFieldValue["errorTown"]
                    if (str!.isEqualToString("Don’t forget your town")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorCounty"] != nil && cell.tf?.placeholder == "County") {
                    let str = dictForTextFieldValue["errorCounty"]
                    if (str!.isEqualToString("Don’t forget your county")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorMobile"] != nil && cell.tf?.placeholder == "Mobile number") {
                    let str = dictForTextFieldValue["errorMobile"]
                    if (str!.isEqualToString("Don't forget your mobile number")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorMobileValidation"] != nil && cell.tf?.placeholder == "Mobile number") {
                    let str = dictForTextFieldValue["errorMobileValidation"]
                    if (str!.isEqualToString("That mobile number doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                    }
                }
                if (dictForTextFieldValue["errorEmail"] != nil && cell.tf?.placeholder == "Email") {
                    let str = dictForTextFieldValue["errorEmail"]
                    if (str!.isEqualToString("Don't forget your email address")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorEmailValid"] != nil && cell.tf?.placeholder == "Email") {
                    let str = dictForTextFieldValue["errorEmailValid"]
                    if (str!.isEqualToString("That email address doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                    }
                }
                
                if(editUser)
                {
                    if(cell.tf?.placeholder == "Surname")
                    {
                        cell.tf?.text = userInfoDict["second_name"] as? String
                    }
                    else if(cell.tf?.placeholder == "First Address Line")
                    {
                        cell.tf?.text = userInfoDict["address_1"] as? String
                    }
                    else if(cell.tf?.placeholder == "Town")
                    {
                        cell.tf?.text = userInfoDict["town"] as? String
                    }
                    else if(cell.tf?.placeholder == "County")
                    {
                        cell.tf?.text = userInfoDict["county"] as? String
                    }
                    else if(cell.tf?.placeholder == "Second Address Line")
                    {
                        cell.tf?.text = userInfoDict["address_2"] as? String
                    }
                    else if(cell.tf?.placeholder == "Third Address Line")
                    {
                        cell.tf?.text = userInfoDict["address_3"] as? String
                    }
                }
                
                arrRegistrationFields.append(cell)
            }
            
            if dict["classType"]!.isEqualToString("PickerTextfildTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! PickerTextfildTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                cell.tfDatePicker!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if(editUser)
                {
                    cell.tfDatePicker.userInteractionEnabled = false
                    cell.tfDatePicker.text = userInfoDict["date_of_birth"] as? String
                }
                cell.tfDatePicker?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                if (dictForTextFieldValue[(cell.tfDatePicker?.placeholder)!] != nil){
                    cell.tfDatePicker?.text = dictForTextFieldValue[(cell.tfDatePicker?.placeholder)!] as? String
                }
                arrRegistrationFields.append(cell)
            }
            
            if dict["classType"]!.isEqualToString("FindAddressTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! FindAddressTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tfPostCode?.text = userInfoDict["post_code"] as? String
                cell.tfPostCode?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                let tfPostcodeDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                cell.tfPostCode!.attributedPlaceholder = NSAttributedString(string:(tfPostcodeDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tfPostCode?.placeholder)!] != nil){
                    cell.tfPostCode?.text = dictForTextFieldValue[(cell.tfPostCode?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorPostcode"] != nil) {
                    if dictForTextFieldValue["errorPostcode"]!.isEqualToString("Don’t forget your postcode"){
                        cell.tfPostCode?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                
                if (dictForTextFieldValue["errorPostcodeValid"] != nil) {
                    if dictForTextFieldValue["errorPostcodeValid"]!.isEqualToString("That postcode doesn't look right"){
                        cell.tfPostCode?.textColor = UIColor.redColor()
                    }
                }
                
                let btnPostcodeDict = metadataDict["button"]as! Dictionary<String,AnyObject>
                cell.btnPostCode?.setTitle(btnPostcodeDict["placeholder"] as? String, forState: UIControlState.Normal)
                arrRegistrationFields.append(cell)
            }
            
            if dict["classType"]!.isEqualToString("ButtonTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! ButtonTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.btn?.setTitle("Save", forState: UIControlState.Normal)
                arrRegistrationFields.append(cell)
            }
            
            if dict["classType"]!.isEqualToString("NumericTextTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! NumericTextTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.blackColor()
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                cell.tf!.userInteractionEnabled = false
                cell.tf?.text = userInfoDict["phone_number"] as? String
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorMobile"] != nil && cell.tf?.placeholder == "Mobile number") {
                    let str = dictForTextFieldValue["errorMobile"]
                    if (str!.isEqualToString("Don't forget your mobile number")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorMobileValidation"] != nil && cell.tf?.placeholder == "Mobile number") {
                    let str = dictForTextFieldValue["errorMobileValidation"]
                    if (str!.isEqualToString("That mobile number doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                    }
                }
                arrRegistrationFields.append(cell)
            }
            
            if dict["classType"]!.isEqualToString("EmailTxtTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! EmailTxtTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.blackColor()
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                cell.tf?.text = userInfoDict["email"] as? String
                cell.tf?.userInteractionEnabled = false
                
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorEmail"] != nil && cell.tf?.placeholder == "Email") {
                    let str = dictForTextFieldValue["errorEmail"]
                    if (str!.isEqualToString("Don't forget your email address")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorEmailValid"] != nil && cell.tf?.placeholder == "Email") {
                    let str = dictForTextFieldValue["errorEmailValid"]
                    if (str!.isEqualToString("That email address doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                    }
                }
                arrRegistrationFields.append(cell)
                
            }
            
            if dict["classType"]!.isEqualToString("DropDownTxtFieldTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! DropDownTxtFieldTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.dict = dict
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                    arrRegistrationFields.append(cell)
                }
                let arrDropDown = arrAddress
                cell.arr = arrDropDown
                if arrDropDown.count>0{
                    arrRegistrationFields.append(cell)
                }
            }
        }
        
        tblViewHt.constant =  CGFloat(35 * (arrRegistrationFields.count+5))
        let height: CGFloat = 35 * (CGFloat(arrRegistrationFields.count) + 5 ) + 130
        scrlView.contentSize = CGSizeMake(0, height)
        
        tblView.reloadData()
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
    
    //MARK: -UITableviewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrRegistrationFields.count;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        return arrRegistrationFields[indexPath.row]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(indexPath.row == arrRegistrationFields.count - 1){
            return 55.0
        }
        
        return 35
    }
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        isImageClicked = true
        
        image1 = info[UIImagePickerControllerEditedImage] as? UIImage
        
        addProfilePictureButton.setImage((info[UIImagePickerControllerEditedImage] as? UIImage), forState: .Normal)
        addProfilePictureButton.layer.cornerRadius = addProfilePictureButton.frame.size.height/2.0
        addProfilePictureButton.setTitle("", forState: .Normal)
        addProfilePictureButton.clipsToBounds = true
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func selectedDate(txtFldCell:PickerTextfildTableViewCell){
        
        dictForTextFieldValue.updateValue((txtFldCell.tfDatePicker?.text)!, forKey: (txtFldCell.tfDatePicker?.placeholder)!)
    }
    
    
    func switchKey<T, U>(inout myDict: [T:U], fromKey: T, toKey: T) {
        if let entry = myDict.removeValueForKey(fromKey) {
            myDict[toKey] = entry
        }
    }
    
    func txtFieldCellText(txtFldCell:TxtFieldTableViewCell){
        if txtFldCell.tf?.text?.characters.count>0{
            
            dictForTextFieldValue.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
            if(txtFldCell.tf?.placeholder == "Surname")
            {
                userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: "second_name")
            }
            else {
                userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
            }
        }
        else {
            dictForTextFieldValue.removeValueForKey((txtFldCell.tf?.placeholder)!)
        }
    }
    
    func titleCellText(titleCell:TitleTableViewCell){
        if titleCell.tfTitle?.text?.characters.count>0{
            dictForTextFieldValue.updateValue((titleCell.tfTitle?.text)!, forKey: "title")
        }
        if titleCell.tfName?.text?.characters.count>0{
            dictForTextFieldValue.updateValue((titleCell.prevName), forKey: "name")
            userInfoDict.updateValue((titleCell.prevName), forKey: "first_name")
        }
    }
    
    func getTextFOrPostCode(findAddrCell: FindAddressTableViewCell)
    {
        if findAddrCell.tfPostCode?.text?.characters.count>0{
            dictForTextFieldValue.updateValue((findAddrCell.tfPostCode?.text)!, forKey: (findAddrCell.tfPostCode?.placeholder)!)
            userInfoDict.updateValue((findAddrCell.tfPostCode?.text)!, forKey: "post_code")
        }
    }
    
    func getAddressButtonClicked(findAddrCell: FindAddressTableViewCell){
        let strPostCode = (findAddrCell.tfPostCode?.text)!
        dictForTextFieldValue.updateValue((findAddrCell.tfPostCode?.text)!, forKey: (findAddrCell.tfPostCode?.placeholder)!)
        userInfoDict.updateValue((findAddrCell.tfPostCode?.text)!, forKey: "post_code")
        
        let strCode = strPostCode
        if strCode.characters.count == 0 {
            var dict = arrRegistration[7] as Dictionary<String,AnyObject>
            var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
            let lableDict = metadataDict["lable"]!.mutableCopy()
            lableDict.setValue("Yes", forKey: "isErrorShow")
            lableDict.setValue("Don’t forget your postcode", forKey: "title")
            dictForTextFieldValue["errorPostcode"] = "Don’t forget your postcode"
            
            metadataDict["lable"] = lableDict
            dict["metaData"] = metadataDict
            arrRegistration[7] = dict
            self.createCells()
        }
        else if checkTextFieldContentSpecialChar(strPostCode){
            var dict = arrRegistration[7] as Dictionary<String,AnyObject>
            var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
            let lableDict = metadataDict["lable"]!.mutableCopy()
            lableDict.setValue("Yes", forKey: "isErrorShow")
            lableDict.setValue("That postcode doesn't look right", forKey: "title")
            metadataDict["lable"] = lableDict
            dict["metaData"] = metadataDict
            dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right"
            arrRegistration[7] = dict
            self.createCells()
        }
        else {
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            objAnimView!.frame = self.view.frame
            objAnimView?.animate()
            self.view.addSubview(objAnimView!)
            
            let objGetAddressAPI: API = API()
            objGetAddressAPI.delegate = self
            let trimmedString = strCode.stringByReplacingOccurrencesOfString(" ", withString: "")
            objGetAddressAPI.verifyPostCode(trimmedString)
        }
        
    }
    
    func dropDownTxtFieldCellText(dropDownTextCell:DropDownTxtFieldTableViewCell)
    {
        
        let str = dropDownTextCell.tf?.text
        let fullNameArr = str!.characters.split{$0 == ","}.map(String.init)
        
        dictForTextFieldValue.updateValue(fullNameArr[0], forKey: "First Address Line")
        dictForTextFieldValue.updateValue(fullNameArr[1], forKey: "Second Address Line")
        dictForTextFieldValue.updateValue(fullNameArr[2], forKey: "Third Address Line")
        dictForTextFieldValue.updateValue(fullNameArr[fullNameArr.count-2], forKey: "town")
        dictForTextFieldValue.updateValue(fullNameArr[fullNameArr.count-1], forKey: "County")
        
        userInfoDict.updateValue(fullNameArr[0], forKey: "address_1")
        userInfoDict.updateValue(fullNameArr[1], forKey: "address_2")
        userInfoDict.updateValue(fullNameArr[2], forKey: "address_3")
        userInfoDict.updateValue(fullNameArr[fullNameArr.count-2], forKey: "town")
        userInfoDict.updateValue(fullNameArr[fullNameArr.count-1], forKey: "county")
        self.createCells()
    }
    
    
    func numericCellText(txtFldCell: NumericTextTableViewCell) {
        dictForTextFieldValue.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
        userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: "mobile-number")
    }
    
    func emailCellText(txtFldCell:EmailTxtTableViewCell){
        dictForTextFieldValue.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
        userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: "email")
    }
    func emailCellTextImmediate(txtFldCell:EmailTxtTableViewCell, text: String) {
        
    }
    
    func buttonOnCellClicked(sender:UIButton){
        
        if (dictForTextFieldValue["errorPostcodeValid"]==nil && checkTextFiledValidation() == false){
            //call term and condition screen
            var dict = self.getAllValuesFromTxtFild()
            if(firstName.characters.count>0 && lastName.characters.count>0 )
            {
                for i in 0 ..< arrRegistrationFields.count {
                    if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                        let cell = arrRegistrationFields[i] as! TitleTableViewCell
                        dict["title"] = cell.tfTitle?.text
                        dict["first_name"] = cell.tfName?.text
                        if(cell.tfTitle!.text == "Mr") {
                            dict["party_gender"] = "male"
                        }
                        else  {
                            dict["party_gender"] = "female"
                        }
                    }
                    if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                    }
                }
            }
            else {
                
                objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
                objAnimView!.frame = self.view.frame
                objAnimView?.animate()
                self.navigationController!.view.addSubview(objAnimView!)
                
                let objAPI = API()
                let dict = objAPI.getValueFromKeychainOfKey("userInfo")
                userInfoDict["ptyid"] = dict["partyId"]
                if(isImageClicked) {
                    let imageData:NSData = UIImageJPEGRepresentation(image1!, 1.0)!
                    let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                    let newDict = ["imageName.jpg":base64String]
                    userInfoDict["imageurl"] = newDict
                }
                else {
                    let newDict = ["imageName.jpg":""]
                    userInfoDict["imageurl"] = newDict
                }
                
                var param = userInfoDict as Dictionary<String,AnyObject>
                param["town"] = userInfoDict["Town"]
                param.removeValueForKey("Town")
                param["ptystatus"] = "ENABLE"
                param.removeValueForKey("date_of_birth")
                param.removeValueForKey("pass_code")
                param.removeValueForKey("email")
                param.removeValueForKey("confirm_pin")
                param.removeValueForKey("imageURL")
                param.removeValueForKey("partyId")
                param.removeValueForKey("deviceRegistration")
                if let firstAddress = param["First Address Line"] as? String {
                    param.removeValueForKey("First Address Line")
                }
                if let secondAddress = param["Second Address Line"] as? String {
                    param.removeValueForKey("Second Address Line")
                }
                if let thirdAddress = param["Third Address Line"] as? String {
                    param.removeValueForKey("Third Address Line")
                }
                if let county = param["stripeCustomerId"] as? String {
                    param.removeValueForKey("stripeCustomerId")
                }
                
                if let County = param["County"] as? String {
                    param.removeValueForKey("County")
                }
                if let stripeStatusCode = param["stripeStatusCode"] as? String {
                    param.removeValueForKey("stripeStatusCode")
                }
                
                param.removeValueForKey("phone_number")
                param.removeValueForKey("pin")
                param.removeValueForKey("Surname")
                param.removeValueForKey("party_role")
                param.removeValueForKey("partyRole")
                param.removeValueForKey("partyStatus")
                param.removeValueForKey("partyGender")
                objAPI.updateUserInfoDelegate = self
                objAPI.updateUserInfo(param)
            }
        }
        else {
            if dictForTextFieldValue["errorPostcodeValid"] != nil{
                var dict = arrRegistration[7] as Dictionary<String,AnyObject>
                var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let lableDict = metadataDict["lable"]!.mutableCopy()
                lableDict.setValue("Yes", forKey: "isErrorShow")
                lableDict.setValue("That postcode doesn't look right", forKey: "title")
                metadataDict["lable"] = lableDict
                dict["metaData"] = metadataDict
                dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right"
                arrRegistration[7] = dict
                self.createCells()
            }
        }
    }
    
    
    func getAllValuesFromTxtFild()-> Dictionary<String,AnyObject>{
        var dict = Dictionary<String, AnyObject>()
        
        for i in 0 ..< arrRegistrationFields.count {
            if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                let cell = arrRegistrationFields[i] as! TitleTableViewCell
                dict["title"] = cell.tfTitle?.text
                dict["first_name"] = cell.tfName?.text
            }
            
            if arrRegistrationFields[i].isKindOfClass(TxtFieldTableViewCell){
                let cell = arrRegistrationFields[i] as! TxtFieldTableViewCell
                if cell.tf?.placeholder == "Surname"{
                    dict["second_name"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "First Address Line"{
                    dict["address_1"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "Second Address Line"{
                    dict["address_2"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "Third Address Line"{
                    dict["address_3"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "Town"{
                    dict["town"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "Mobile number"{
                    dict["phone_number"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "County"{
                    dict["county"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "Email"{
                    dict["email"] = cell.tf?.text
                }
            }
            
            if arrRegistrationFields[i].isKindOfClass(FindAddressTableViewCell){
                let cell = arrRegistrationFields[i] as! FindAddressTableViewCell
                dict["post_code"] = cell.tfPostCode?.text
            }
            if arrRegistrationFields[i].isKindOfClass(NumericTextTableViewCell){
                let cell = arrRegistrationFields[i] as! NumericTextTableViewCell
                dict["phone_number"] = cell.tf?.text
            }
            if arrRegistrationFields[i].isKindOfClass(EmailTxtTableViewCell){
                let cell = arrRegistrationFields[i] as! EmailTxtTableViewCell
                dict["email"] = cell.tf?.text
            }
            if arrRegistrationFields[i].isKindOfClass(PickerTextfildTableViewCell){
                let cell = arrRegistrationFields[i] as! PickerTextfildTableViewCell
                dict["date_of_birth"] = cell.tfDatePicker?.text
            }
            let udidDict : Dictionary<String,AnyObject> = ["DEVICE_ID":Device.udid]
            let udidArray: Array<Dictionary<String,AnyObject>> = [udidDict]
            dict["deviceRegistration"] =  udidArray
        }
        return dict
    }
    
    func checkTextFieldContentSpecialChar(str:String)->Bool{
        let characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "~!@#$%^&*()_-+={}|\\;:'\",.<>*/")
        if (str.rangeOfCharacterFromSet(characterSet) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func acceptPolicy(obj:ImportantInformationView){
        var dict = self.getAllValuesFromTxtFild()
        let objAPI = API()
        if(changePhoneNumber == false)
        {
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            objAnimView!.frame = self.view.frame
            objAnimView?.animate()
            self.view.addSubview(objAnimView!)
            objAPI.delegate = self
            objAPI.registerTheUserWithTitle(dict,apiName: "Customers")
            return
        }
        else {
            if(objAPI.getValueFromKeychainOfKey("myMobile") as! String == dict["phone_number"] as! String)
            {
                objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
                objAnimView!.frame = self.view.frame
                objAnimView?.animate()
                self.view.addSubview(objAnimView!)
                objAPI.delegate = self
                objAPI.registerTheUserWithTitle(dict,apiName: "Customers")
            }
            else {
                let alert = UIAlertController(title: "Looks like you have an earlier enrolled mobile number", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    //Function checking textfield content only number or not
    func checkTextFieldContentOnlyNumber(str:String)->Bool{
        let set = NSCharacterSet.decimalDigitCharacterSet()
        if (str.rangeOfCharacterFromSet(set) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func checkTextFieldContentCharacters(str:String)->Bool{
        let set = NSCharacterSet.letterCharacterSet()
        if (str.rangeOfCharacterFromSet(set) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func checkTextFiledValidation()->Bool{
        var returnFlag = false
        self.getJSONForUI()
        var idx = 0
        for var i=0; i<arrRegistrationFields.count; i += 1 {
            var errorFLag = false
            var errorMsg = ""
            var dict = Dictionary<String, AnyObject>()
            if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                let cell = arrRegistrationFields[i] as! TitleTableViewCell
                let str = cell.tfName?.text
                
                if (self.checkTextFieldContentOnlyNumber(str!) == true){
                    errorMsg = "Name should contain alphabets only"
                    if cell.tfTitle?.text?.characters.count==0 {
                        errorMsg = "Please select a title and name should contain alphabets only"
                    }
                    errorFLag = true
                    dictForTextFieldValue["errorTitle"] = errorMsg
                }
                else if checkTextFieldContentSpecialChar(str!){
                    errorMsg = "Name should not contain special characters"
                    if cell.tfTitle?.text?.characters.count==0 {
                        errorMsg = "Please select a title and name should not contain special characters"
                    }
                    errorFLag = true
                    dictForTextFieldValue["errorTitle"] = errorMsg
                }
                else if str?.characters.count > 50{
                    errorMsg = "Wow, that’s such a long name we can’t save it"
                    errorFLag = true
                    dictForTextFieldValue["errorTitle"] = errorMsg
                }
                else if(cell.tfTitle?.text?.characters.count == 0 && cell.tfName?.text?.characters.count == 0){
                    errorMsg = "We need to know your title and name"
                    errorFLag = true
                    cell.tfTitle?.layer.borderColor = UIColor.redColor().CGColor
                    cell.tfName?.layer.borderColor = UIColor.redColor().CGColor
                    dictForTextFieldValue["errorTitle"] = errorMsg
                }
                else if cell.tfTitle?.text == ""{
                    errorMsg = "Please select a title"
                    errorFLag = true
                    dictForTextFieldValue["errorTitle"] = errorMsg
                }
                else if str==""{
                    errorMsg = "We need to know what to call you"
                    errorFLag = true
                    dictForTextFieldValue["errorTitle"] = errorMsg
                }
                else {
                    dictForTextFieldValue.removeValueForKey("errorTitle")
                }
                
                dict = arrRegistration[1] as Dictionary<String,AnyObject>
                idx = 1
            }
            
            if arrRegistrationFields[i].isKindOfClass(TxtFieldTableViewCell){
                let cell = arrRegistrationFields[i] as! TxtFieldTableViewCell
                if cell.tf?.placeholder == "Surname"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "We need to know your surname"
                        dictForTextFieldValue["errorTxt"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorTxt")
                    }
                    if(str?.characters.count>50){
                        errorMsg = "Wow, that’s such a long name we can’t save it"
                        errorFLag = true
                        dictForTextFieldValue["errorSurname"] = errorMsg
                    }
                    else if(self.checkTextFieldContentOnlyNumber(str!) == true){
                        errorMsg = "Surname should contain alphabets only"
                        errorFLag = true
                        dictForTextFieldValue["errorSurname"] = errorMsg
                    }
                    else if checkTextFieldContentSpecialChar(str!){
                        errorMsg = "Surname should not contain special characters"
                        errorFLag = true
                        dictForTextFieldValue["errorSurname"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorSurname")
                    }
                    dict = arrRegistration[3]as Dictionary<String,AnyObject>
                    idx = 3
                }
                
                if cell.tf?.placeholder == "First Address Line"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don’t forget your house number"
                        dictForTextFieldValue["errorFirstAddress"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorFirstAddress")
                    }
                    dict = arrRegistration[10]as Dictionary<String,AnyObject>
                    idx = 10
                }
                
                if cell.tf?.placeholder == "Town"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don’t forget your town"
                        dictForTextFieldValue["errorTown"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorTown")
                    }
                    dict = arrRegistration[14]as Dictionary<String,AnyObject>
                    idx = 14
                }
                
                if cell.tf?.placeholder == "County"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don’t forget your county"
                        dictForTextFieldValue["errorCounty"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorCounty")
                    }
                    dict = arrRegistration[16]as Dictionary<String,AnyObject>
                    idx = 16
                }
                
                if cell.tf?.placeholder == "Mobile number"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don't forget your mobile number"
                        dictForTextFieldValue["errorMobileValidation"] = errorMsg
                    }
                    else  if(self.checkTextFieldContentCharacters(str!) == true || self.phoneNumberValidation(str!)==false){
                        errorFLag = true
                        errorMsg = "That mobile number doesn’t look right"
                        dictForTextFieldValue["errorMobileValidation"] = errorMsg
                    }
                    else if(str?.characters.count < 10)
                    {
                        errorFLag = true
                        errorMsg = "That mobile number should be greater than 10 digits"
                        dictForTextFieldValue["errorMobileValidation"] = errorMsg
                    }
                    else if(str?.characters.count > 16)
                    {
                        errorFLag = true
                        errorMsg = "That mobile number should be of 15 digits"
                        dictForTextFieldValue["errorMobileValidation"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorMobileValidation")
                    }
                    dict = arrRegistration[19]as Dictionary<String,AnyObject>
                    idx = 19
                }
                
                if cell.tf?.placeholder == "Email"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don't forget your email address"
                        dictForTextFieldValue["errorEmail"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorEmail")
                    }
                    if str?.characters.count>0 && (self.isValidEmail(str!)==false){
                        errorFLag = true
                        errorMsg = "That email address doesn’t look right"
                        dictForTextFieldValue["errorEmailValid"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorEmailValid")
                    }
                    dict = arrRegistration[21]as Dictionary<String,AnyObject>
                    idx = 21
                }
                
            }
            
            if arrRegistrationFields[i].isKindOfClass(FindAddressTableViewCell){
                let cell = arrRegistrationFields[i] as! FindAddressTableViewCell
                let str = cell.tfPostCode?.text
                if str==""{
                    errorFLag = true
                    errorMsg = "Don’t forget your postcode"
                    dictForTextFieldValue["errorPostcode"] = errorMsg
                    dictForTextFieldValue.removeValueForKey("errorPostcodeValid")
                    dictForTextFieldValue.removeValueForKey("Postcode")
                }
                else {
                    dictForTextFieldValue.removeValueForKey("errorPostcode")
                    dictForTextFieldValue.removeValueForKey("errorPostcodeValid")
                }
                dict = arrRegistration[7]as Dictionary<String,AnyObject>
                idx = 7
            }
            
            if arrRegistrationFields[i].isKindOfClass(NumericTextTableViewCell){
                let cell = arrRegistrationFields[i] as! NumericTextTableViewCell
                let str = cell.tf?.text
                
                if str==""{
                    errorFLag = true
                    errorMsg = "Don't forget your mobile number"
                    dictForTextFieldValue["errorMobileValidation"] = errorMsg
                }
                else  if(self.checkTextFieldContentCharacters(str!) == true || self.phoneNumberValidation(str!)==false){
                    errorFLag = true
                    errorMsg = "That mobile number doesn’t look right"
                    dictForTextFieldValue["errorMobileValidation"] = errorMsg
                }
                else if(str?.characters.count < 10)
                {
                    errorFLag = true
                    errorMsg = "That mobile number should be greater than 10 digits"
                    dictForTextFieldValue["errorMobileValidation"] = errorMsg
                }
                else if(str?.characters.count > 16)
                {
                    errorFLag = true
                    errorMsg = "That mobile number should be of 15 digits"
                    dictForTextFieldValue["errorMobileValidation"] = errorMsg
                }
                else {
                    dictForTextFieldValue.removeValueForKey("errorMobileValidation")
                }
                
                dict = arrRegistration[19]as Dictionary<String,AnyObject>
                idx = 19
                
            }
            if arrRegistrationFields[i].isKindOfClass(EmailTxtTableViewCell){
                let cell = arrRegistrationFields[i] as! EmailTxtTableViewCell
                let str = cell.tf?.text
                if str==""{
                    errorFLag = true
                    errorMsg = "Don't forget your email address"
                    dictForTextFieldValue["errorEmail"] = errorMsg
                }
                else {
                    dictForTextFieldValue.removeValueForKey("errorEmail")
                }
                
                if str?.characters.count>0 && (self.isValidEmail(str!)==false){
                    errorFLag = true
                    errorMsg = "That email address doesn’t look right"
                    dictForTextFieldValue["errorEmailValid"] = errorMsg
                }
                else {
                    dictForTextFieldValue.removeValueForKey("errorEmailValid")
                }
                dict = arrRegistration[21]as Dictionary<String,AnyObject>
                idx = 21
            }
            
            
            if arrRegistrationFields[i].isKindOfClass(PickerTextfildTableViewCell){
                let cell = arrRegistrationFields[i] as! PickerTextfildTableViewCell
                let str = cell.tfDatePicker?.text
                if str==""{
                    errorFLag = true
                    errorMsg = "We need to know your date of birth"
                    dictForTextFieldValue["errorDOB"] = errorMsg
                }
                else {
                    dictForTextFieldValue.removeValueForKey("errorDOB")
                }
                dict = arrRegistration[5]as Dictionary<String,AnyObject>
                idx = 5
            }
            
            if(errorFLag == true){
                returnFlag = true
                var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let lableDict = metadataDict["lable"]!.mutableCopy()
                
                lableDict.setValue("Yes", forKey: "isErrorShow")
                if errorMsg.characters.count>0{
                    lableDict.setValue(errorMsg, forKey: "title")
                }
                metadataDict["lable"] = lableDict
                dict["metaData"] = metadataDict
                arrRegistration[idx] = dict
            }
            
        }
        self.createCells()
        return returnFlag
    }
    
    
    
    func phoneNumberValidation(value: String) -> Bool {
        let charcter  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
        var filtered:NSString!
        let inputString:NSArray = value.componentsSeparatedByCharactersInSet(charcter)
        filtered = inputString.componentsJoinedByString("")
        return  value == filtered
    }
    
    //Function invoke for validate the email
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        var result = emailTest.evaluateWithObject(testStr)
        
        if result {
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let matches = testStr.rangeOfString(regex, options: .RegularExpressionSearch)
            if let _ = matches {
                result = true
            }
            else {
                result = false
            }
        }
        return result
    }
    
    //PostCode Verification Delegate Method
    func success(addressArray:Array<String>){
        objAnimView?.removeFromSuperview()
        self.getJSONForUI()
        var dict = arrRegistration[8] as Dictionary<String,AnyObject>
        var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
        let lableDict = metadataDict["textField1"]!.mutableCopy()
        lableDict.setValue(addressArray, forKey: "dropDownArray")
        metadataDict["textField1"] = lableDict
        dict["metaData"] = metadataDict
        arrRegistration[8] = dict
        arrAddress = addressArray
        dictForTextFieldValue.removeValueForKey("errorPostcodeValid")
        self.createCells()
    }
    func error(error:String){
        objAnimView?.removeFromSuperview()
        if(error == "That postcode doesn't look right"){
            var dict = arrRegistration[7] as Dictionary<String,AnyObject>
            var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
            let lableDict = metadataDict["lable"]!.mutableCopy()
            lableDict.setValue("Yes", forKey: "isErrorShow")
            lableDict.setValue(error, forKey: "title")
            metadataDict["lable"] = lableDict
            dict["metaData"] = metadataDict
            dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right"
            arrRegistration[7] = dict
            self.createCells()
        }
        else {
            let alert = UIAlertController(title: error, message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func successResponseForRegistrationAPI(objResponse:Dictionary<String,AnyObject>){
        
    }
    func errorResponseForRegistrationAPI(error:String){
        
    }
    
    
    @IBAction func addProfilePictureButtonPressed(sender: AnyObject) {
        
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
    
    //Go to Payment screen
    
    
    @IBAction func paymentButtonPressed(sender: UIButton) {
        
        let individualFlag = NSUserDefaults.standardUserDefaults().valueForKey("individualPlan") as! NSNumber
        let groupFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupPlan") as! NSNumber
        let groupMemberFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupMemberPlan") as! NSNumber
        
        if(individualFlag == 1 || groupFlag == 1 || groupMemberFlag == 1)
        {
            let objSavedCardView = SASaveCardViewController()
            objSavedCardView.isFromEditUserInfo = true
            self.navigationController?.pushViewController(objSavedCardView, animated: true)
        }else {
            let alert = UIAlertView(title: "Alert", message: "Please create saving plan first", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    // MARK: - GetUserInfoDelegate
    func successResponseForGetUserInfoAPI(objResponse: Dictionary<String, AnyObject>) {
        if let message = objResponse["message"] as? String {
            if(message == "Party Found")  {
                
                userInfoDict = objResponse["party"] as! Dictionary<String,AnyObject>
                //Get Registration UI Json data
                
                if let urlString = userInfoDict["imageURL"] as? String
                {
                    let url = NSURL(string:urlString)
                    let request: NSURLRequest = NSURLRequest(URL: url!)
                    if(urlString != "")
                    {
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                            if(data?.length > 0)
                            {
                                let image = UIImage(data: data!)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.addProfilePictureButton.setImage(image, forState: .Normal)
                                    self.addProfilePictureButton.layer.cornerRadius = self.addProfilePictureButton.frame.size.height/2.0
                                    self.addProfilePictureButton.clipsToBounds = true
                                    self.spinner.stopAnimating()
                                    self.spinner.hidden = true
                                })
                            }
                            else {
                                self.spinner.stopAnimating()
                                self.spinner.hidden = true
                            }
                        })
                    }
                    else{
                        self.spinner.stopAnimating()
                        self.spinner.hidden = true
                    }
                }
                else
                {
                    self.spinner.stopAnimating()
                    self.spinner.hidden = true
                }
                
                
                self.getJSONForUI()
                //Setup Registration UI
                self.createCells()
                
                
            }
            else {
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        objAnimView!.removeFromSuperview()
    }
    
    func errorResponseForGetUserInfoAPI(error: String) {
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView!.removeFromSuperview()
    }
    
    func successResponseForUpdateUserInfoAPI(objResponse: Dictionary<String, AnyObject>) {
        objAnimView?.removeFromSuperview()
        if let message = objResponse["message"] as? String
        {
            if(message == "UserData Updated Successfully")
            {
                let alert = UIAlertView(title: "Alert", message: "Personal details updated", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
                self.createCells()
            }
            else {
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else if let message = objResponse["message"] as? String {
            let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else if let message = objResponse["internalMessage"] as? String {
            let alert = UIAlertView(title: "Alert", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func errorResponseForUpdateUserInfoAPI(error: String) {
        objAnimView?.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
}
