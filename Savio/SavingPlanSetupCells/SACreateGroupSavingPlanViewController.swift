//
//  SACreateGroupSavingPlanViewController.swift
//  Savio
//
//  Created by Maheshwari on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SACreateGroupSavingPlanViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SegmentBarChangeDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var addAPhotoLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var topBgImageView: UIImageView!
    @IBOutlet weak var scrlView: UIScrollView!
    var selectedStr = ""
    var cost : Int = 0
    var parameterDict : Dictionary<String,AnyObject> = [:]
    var dateDiff : Int = 0
    var dateString = "date"
    var isClearPressed = false
    var isDateChanged =  false
     var participantsArr: Array<String> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Savings plan setup"
        let font = UIFont(name: "GothamRounded-Book", size: 15)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font!]
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        tblView!.registerNib(UINib(nibName: "SetDayTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanSetDateIdentifier")
        tblView!.registerNib(UINib(nibName: "CreateSavingPlanTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateSavingPlanTableViewCellIdentifier")
        tblView!.registerNib(UINib(nibName: "GroupCalculationTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupCalculationCellIdentifier")
        tblView!.registerNib(UINib(nibName: "ClearButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ClearButtonIdentifier")
        
        dateDiff =  Int(parameterDict["dateDiff"] as! String)!
        
        
        cost =  Int(parameterDict["amount"] as! String)!
        participantsArr.append("one")

        participantsArr.append("two")

        participantsArr.append("three")

        participantsArr.append("four")

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
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") != nil)
        {
            let wishListArray = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? Array<Dictionary<String,AnyObject>>
            btnName.setTitle(String(format:"%d",wishListArray!.count), forState: UIControlState.Normal)
            
            if(wishListArray?.count > 0)
            {
                
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else{
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
            }
            
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        if(parameterDict["imageURL"] != nil)
        {
            let data :NSData = NSData(base64EncodedString: parameterDict["imageURL"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
            
            topBgImageView.image = UIImage(data: data)
            cameraButton.hidden = true
            addAPhotoLabel.hidden = true
            
        }
        else
        {
     
            self.cameraButton.hidden = false
            addAPhotoLabel.hidden = false
        }
       
        
    }
    
    func backButtonClicked()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func heartBtnClicked(){
        if  (NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") != nil) {
            
            let wishListArray = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? Array<Dictionary<String,AnyObject>>
            
            if wishListArray!.count>0{
                
                let objSAWishListViewController = SAWishListViewController()
                objSAWishListViewController.wishListArray = wishListArray!
                self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
            }
            else{
                let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        if(indexPath.section == 0)
        {
            
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanSetDateIdentifier", forIndexPath: indexPath) as! SetDayTableViewCell
            cell1.tblView = tblView
            cell1.view = self.view
            cell1.segmentDelegate = self
            
            if(selectedStr != "")
            {
                cell1.dayDateTextField.text = selectedStr
            }
            
            if(isClearPressed)
            {
                cell1.dayDateTextField.text = ""
            }
            
            
            
            return cell1
        }
            
        else if(indexPath.section == 1){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("GroupCalculationCellIdentifier", forIndexPath: indexPath) as! GroupCalculationTableViewCell
            if(isDateChanged)
            {
                cell1.percentageCalculationLabel.text = String(format: "You are saving for %d%% which is £%d of the total goal of %d",100/participantsArr.count,cost/participantsArr.count,cost)
                
                if(dateString == "day")
                {
                    
                    if((dateDiff/168) == 1)
                    {
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per week for %d week",(cost/participantsArr.count)/(dateDiff/168),(dateDiff/168))
                    
                    }
                    else if ((dateDiff/168) == 0)
                    {
                        cell1.calculationLabel.text = "You will need to save £0 per week for 0 week"
                    }
                    else
                    {
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per week for %d week(s)",(cost/participantsArr.count)/(dateDiff/168),(dateDiff/168))
                    }
                    
                }
                else{
                    if((dateDiff/168)/4 == 1)
                    {
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per month for %d month",((cost/participantsArr.count)/((dateDiff/168)/4)),(dateDiff/168)/4)
                    }
                    else if ((dateDiff/168)/4 == 0)
                    {
                        cell1.calculationLabel.text = "You will need to save £0 per month for 0 month"
                    }
                    else{
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per month for %d months",((cost/participantsArr.count)/((dateDiff/168)/4)),(dateDiff/168)/4)
                    }
                }
                
            }
            
            if(isClearPressed)
            {
                cell1.calculationLabel.text = ""
            }
            return cell1
            
        }
            
        else if(indexPath.section == 2){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("CreateSavingPlanTableViewCellIdentifier", forIndexPath: indexPath) as! CreateSavingPlanTableViewCell
            cell1.createSavingPlanButton.addTarget(self, action: Selector("createSavingPlanButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else if(indexPath.section == 3){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("ClearButtonIdentifier", forIndexPath: indexPath) as! ClearButtonTableViewCell
            cell1.tblView = tblView
            cell1.clearButton.addTarget(self, action: Selector("clearButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else
        {
            var cell : UITableViewCell? = tblView.dequeueReusableCellWithIdentifier("cell" as String) as UITableViewCell?
            return cell!
        }
        
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view : UIView = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.section == 0)
        {
            return 64
        }
        else if(indexPath.section == 2){
            return 65
        }
        else if(indexPath.section == 3){
            return 40
        }
            
        else if(indexPath.section == 1)
        {
            if(isDateChanged)
            {
                return 100
            }
            else
            {
                return 0
            }
            
        }
        else
        {
            return 0
        }
    }
    
    func getDateTextField(str: String) {
        selectedStr = str
        isDateChanged = true
        isClearPressed = false
        tblView.reloadData()
    }
    
    
    func segmentBarChanged(str: String) {
        if(str == "date")
        {
            dateString = "date"
        }
        else
        {
            dateString = "day"
        }
        isDateChanged = true
    }
    
    
    func createSavingPlanButtonPressed()
    {
        let alert = UIAlertView(title: "Work in progress", message: "", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func clearButtonPressed()
    {
        
        let alert = UIAlertController(title: "Aru you sure?", message: "Do you want to clear all data", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
        { action -> Void in
            
     
            self.setUpView()
            self.isDateChanged = false
            
            self.isClearPressed = true
            self.selectedStr = ""
            
            self.scrlView.contentOffset = CGPointZero
            
            self.tblView.reloadData()
            
            
            })
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
    
}
