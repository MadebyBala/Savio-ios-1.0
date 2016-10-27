//
//  SAGroupProgressViewController.swift
//  Savio
//
//  Created by Maheshwari on 06/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAGroupProgressViewController: UIViewController,PiechartDelegate,GetUsersPlanDelegate {
    
    @IBOutlet weak var groupMembersLabel: UILabel!
    @IBOutlet weak var topButtonView: UIView!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var contentVwHt: NSLayoutConstraint!
    @IBOutlet weak var tblHt: NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var horizontalScrollView: UIScrollView!
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pagecontrol: UIPageControl!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var participantsArr : Array<Dictionary<String,AnyObject>> = []
    var  pieChartSliceArray: Array<Piechart.Slice> = []
    var chartValues : Array<Dictionary<String,AnyObject>> = [];
    var savingPlanDetailsDict : Dictionary<String,AnyObject> =  [:]
    var piechart : Piechart?
    var planTitle = ""
    var totalAmount : Int = 0
    var paidAmount : Float = 0.0
    var ht:CGFloat = 0.0
    var timeSince = [0]
    var dateDiff = 0
    let spinner =  UIActivityIndicatorView()
    var objAnimView = ImageViewAnimation()
    var planEnddate = NSDate()
    let chartColors = [
        UIColor(red:237/255,green:182/255,blue:242/255,alpha:1),
        UIColor(red:181/255,green:235/255,blue:157/255,alpha:1),
        UIColor(red:247/255,green:184/255,blue:183/255,alpha:1),
        UIColor(red:118/255,green:229/255,blue:224/255,alpha:1),
        UIColor(red:238/255,green:234/255,blue:108/255,alpha:1),
        UIColor(red:170/255,green:234/255,blue:184/255,alpha:1),
        UIColor(red:193/255,green:198/255,blue:227/255,alpha:1),
        UIColor(red:246/255,green:197/255,blue:124/255,alpha:1),
        UIColor(red:234/255,green:235/255,blue:237/255,alpha:1)
    ];
    
    let topLabelColors = [
        UIColor(red:231/255,green:177/255,blue:235/255,alpha:1),
        UIColor(red:156/255,green:208/255,blue:133/255,alpha:1),
        UIColor(red:244/255,green:177/255,blue:176/255,alpha:1),
        UIColor(red:87/255,green:221/255,blue:215/255,alpha:1),
        UIColor(red:237/255,green:185/255,blue:82/255,alpha:1),
        UIColor(red:159/255,green:223/255,blue:181/255,alpha:1),
        UIColor(red:180/255,green:178/255,blue:209/255,alpha:1),
        UIColor(red:245/255,green:189/255,blue:104/255,alpha:1)
    ];
    var  prevIndxArr: Array<Int> = []

    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        savingPlanTitleLabel.hidden = true
        self.setUPNavigation()
      
        //Create obj of ImageViewAnimation to show user while  uploading/downloading something
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        
        //Create object of API class to call the GETSavingPlanDelegate methods.
        let objAPI = API()
        objAPI.getSavingPlanDelegate = self
        
        let groupFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupPlan") as! NSNumber
        let groupMemberFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupMemberPlan") as! NSNumber
        if let usersPlan = NSUserDefaults.standardUserDefaults().valueForKey("UsersPlan") as? String
        {
            if(groupFlag == 1 && usersPlan == "G")
            {
                objAPI.getUsersSavingPlan("g")
            }
            else if(groupMemberFlag == 1  && usersPlan == "GM")
            {
                objAPI.getUsersSavingPlan("gm")
            }

        }
        else {
        if(groupFlag == 1 )
        {
            objAPI.getUsersSavingPlan("g")
        }
        else if(groupMemberFlag == 1)
        {
            objAPI.getUsersSavingPlan("gm")
        }
        }
        self.view.bringSubviewToFront(topButtonView)
    }
 
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
    }
    
    //set the UI for Group progress view
    func setUpView(){
        savingPlanTitleLabel.hidden = false
        //create attribute text to savingPlanTitleLabel
        planTitle = String(format: "Our %@ plan",savingPlanDetailsDict["title"] as! String)
        let attrText = NSMutableAttributedString(string: planTitle)
        attrText.addAttribute(NSFontAttributeName,
                              value: UIFont(
                                name: kMediumFont,
                                size: 16.0)!,
                              range: NSRange(
                                location: 4,
                                length: (savingPlanDetailsDict["title"] as! String).characters.count))
        
        savingPlanTitleLabel.attributedText = attrText
        //get the total amount of plan from the Dictionary
        if let amount = savingPlanDetailsDict["amount"] as? NSNumber
        {
            totalAmount = amount.integerValue
        }
        
        //get the total paid amount of plan from the Dictionary
        if let totalPaidAmount = savingPlanDetailsDict["totalPaidAmount"] as? NSNumber
        {
            paidAmount = totalPaidAmount.floatValue
        }
        
        horizontalScrollView.contentSize = CGSizeMake(3 * UIScreen.mainScreen().bounds.size.width, 0)
        //Set page control pages
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        groupMembersLabel.text = String(format:"Group members (%d)",participantsArr.count)
        
        for(var i=0; i<participantsArr.count; i++)
        {
            var error = Piechart.Slice()
            error.value = 1
            error.color = chartColors[i]
            error.text = "Success"
            pieChartSliceArray.append(error)
        }
        
        if(pieChartSliceArray.count <= 8)
        {
            var error = Piechart.Slice()
            error.value = 360.0 - CGFloat(pieChartSliceArray.count)
            error.color = UIColor(red:234/255,green:235/255,blue:237/255,alpha:1)
            error.text = "Error"
            pieChartSliceArray.append(error)
            
        }
        
        for i in 0 ..< 3
        {
             //load the CircularProgress.xib to create progress view
            let circularProgress = NSBundle.mainBundle().loadNibNamed("GroupCircularProgressView", owner: self, options: nil)[0] as! UIView
            circularProgress.frame = CGRectMake(CGFloat(i) * UIScreen.mainScreen().bounds.size.width,0,  horizontalScrollView.frame.size.width, horizontalScrollView.frame.size.height)
 
            //customization of KDCircularProgress
            let circularView = circularProgress.viewWithTag(1) as! KDCircularProgress
            circularView.startAngle = -90 //Set the start angle of circularView
            circularView.roundedCorners = true
            circularView.lerpColorMode = true
            circularView.angle = Double((paidAmount * 360)/Float(totalAmount))
            
            let labelOne = circularProgress.viewWithTag(4) as! UILabel
            let labelTwo = circularProgress.viewWithTag(5) as! UILabel
            let labelThree = circularProgress.viewWithTag(6) as! UILabel
            let labelFour = circularProgress.viewWithTag(7) as! UILabel
            let labelFive = circularProgress.viewWithTag(8) as! UILabel
            let labelSix = circularProgress.viewWithTag(9) as! UILabel

            if(i == 0)
            {
                labelOne.hidden = true
                labelTwo.hidden = true
                labelThree.hidden = true
                labelFour.hidden = true
                labelFive.hidden = true
                circularView.hidden = true
                
                //calculate the time difference between plan end date and todays date
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                planEnddate = dateFormatter.dateFromString(savingPlanDetailsDict["planEndDate"] as! String)!
                
                //set the pie chart to show individual progress of each user
                piechart = Piechart()
                let imgView = UIImageView()
                piechart!.frame = CGRectMake(0,0, horizontalScrollView.frame.width, horizontalScrollView.frame.height)
                
                if(UIScreen.mainScreen().bounds.width == 320)
                {
                    piechart?.radius.outer = horizontalScrollView.frame.width - 185
                    piechart?.radius.inner = horizontalScrollView.frame.width - 210
                    imgView.frame = CGRectMake(70,83,182,182)
                    
                }
                else if(UIScreen.mainScreen().bounds.width == 375) {
                    piechart?.radius.outer = horizontalScrollView.frame.width - 227
                    piechart?.radius.inner = horizontalScrollView.frame.width - 255
                    imgView.frame = CGRectMake(85,72,205,205)
                }
                else if(UIScreen.mainScreen().bounds.width == 414) {
                    piechart?.radius.outer = horizontalScrollView.frame.width - 250
                    piechart?.radius.inner = horizontalScrollView.frame.width - 275
                    imgView.frame = CGRectMake(87,53,240,240)
                }
                
                spinner.center = CGPointMake(imgView.frame.size.width/2, imgView.frame.size.height/2)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                imgView.addSubview(spinner)
                spinner.startAnimating()
          
                piechart!.delegate = self
                piechart?.backgroundColor = UIColor.clearColor()
                piechart!.slices = pieChartSliceArray
                circularProgress.addSubview(piechart!)
                
                imgView.layer.cornerRadius = imgView.frame.size.height / 2
                imgView.clipsToBounds = true
                imgView.contentMode = UIViewContentMode.ScaleAspectFill
              
               //Check if plan has image
                if let url = NSURL(string:(savingPlanDetailsDict["image"] as? String)!)
                {
                    //load image from URL
                    let request: NSURLRequest = NSURLRequest(URL: url)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                        if(data != nil && data!.length>0)
                        {
                            let image = UIImage(data: data!)
                            dispatch_async(dispatch_get_main_queue(), {
                                //Remove the spinner after image loads
                                imgView.image = image
                                self.spinner.stopAnimating()
                                self.spinner.hidden = true
                            })
                        }
                        else {
                            //Remove the spinner if image is not present
                            self.spinner.stopAnimating()
                            self.spinner.hidden = true
                        }
                })
                }
                piechart!.addSubview(imgView)
            }
            else if(i == 1) {
                labelOne.hidden = true
                labelTwo.hidden = true
                labelThree.hidden = true
                labelFive.hidden = false
                labelFour.hidden = false
                labelSix.hidden = false
                labelFour.text = String(format: "£ %0.2f saved",paidAmount)
                circularView.hidden = false
                
                let userDict = participantsArr[0]
                
                //Check if savingPlanTransactionList is present
                if let transactionArray = userDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
                {
                    for i in 0 ..< transactionArray.count {
                        let transactionDict = transactionArray[i]
                        paidAmount = paidAmount + Float((transactionDict["amount"] as? NSNumber)!)
                    }
                }
                
                let text = String(format: "%d",Int(paidAmount * 100)/totalAmount)
             
                let attributes: Dictionary = [NSFontAttributeName:UIFont(name: kMediumFont, size: 45)!]
                let attString:NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: attributes)
                let fontSuper:UIFont? = UIFont(name: kMediumFont, size:25)
                let superscript = NSMutableAttributedString(string: "%", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:15])
                attString.appendAttributedString(superscript)
                labelSix.attributedText = attString
                
                //calculate the time difference between todays date and plan end date
                timeSince = self.timeBetween(NSDate(), endDate: planEnddate)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let timeDifference : NSTimeInterval = planEnddate.timeIntervalSinceDate(NSDate())
                dateDiff = Int(timeDifference/3600)
                if(savingPlanDetailsDict["payType"] as! String == "Month")
                {
                    if((dateDiff/168)/4 == 1)
                    {
                        labelFive.text = String(format :"%d month to go",(dateDiff/168)/4)
                    }
                    else
                    {
                        labelFive.text = String(format :"%d months to go",(dateDiff/168)/4)
                    }
                    
                }
                else
                {
                    if((dateDiff/168) == 1)
                    {
                        labelFive.text = String(format :"%d week to go",dateDiff/168)
                    }
                    else
                    {
                        labelFive.text = String(format :"%d weeks to go",dateDiff/168)
                    }
                }
            }
            else
            {
                labelOne.hidden = false
                labelTwo.hidden = false
                labelTwo.text = " You saved"
                labelThree.hidden = false
                labelFour.hidden = true
                labelFive.hidden = true
                labelSix.hidden = true
                let text = String(format: "%d",paidAmount)
                let attributes: Dictionary = [NSFontAttributeName:UIFont(name: kMediumFont, size: 45)!]
                let attString:NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: attributes)
                let fontSuper:UIFont? = UIFont(name: kMediumFont, size:25)
                let superscript = NSMutableAttributedString(string: "£ ", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:15])
                superscript.appendAttributedString(attString)
                labelThree.attributedText = superscript
                
                let userDict = participantsArr[0]
                //Check if savingPlanTransactionList array is present
                if let transactionArray = userDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
                {
                    for i in 0 ..< transactionArray.count {
                        let transactionDict = transactionArray[i]
                        paidAmount = paidAmount + Float((transactionDict["amount"] as? NSNumber)!)
                    }
                }
                labelOne.text = String(format:"%d%% of your part",Int(paidAmount * 100)/totalAmount)
                circularView.hidden = false
            }
            horizontalScrollView.addSubview(circularProgress)
        }
        
        //customization of plan button as per the psd
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.TopRight, .TopLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.CGPath
        self.planButton?.layer.mask = maskLayer
        self.view.bringSubviewToFront(tblView)
        tblView.layer.zPosition = 1
        self.view.bringSubviewToFront(toolBarView)
    }
    
    func timeBetween(startDate: NSDate, endDate: NSDate) -> [Int]
    {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Day, .Month, .Year], fromDate: startDate, toDate: endDate, options: [])
        
        return [components.day, components.hour, components.minute]
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
    
    //Goto stats tab
    func statsButtonPressed(btn:UIButton)
    {
        let obj = SAStatViewController()
        if let itemTitle = savingPlanDetailsDict["title"] as? String
        {
        obj.itemTitle = itemTitle
        obj.planType = "Group"
        obj.cost =  String(format:"%@",savingPlanDetailsDict["amount"] as! NSNumber)
        obj.endDate = savingPlanDetailsDict["planEndDate"] as! String
        }
        self.navigationController?.pushViewController(obj, animated: false)
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
        
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }
    
    //UIPagecontrol method
    @IBAction func changePage(sender: AnyObject) {
        var newFrame = horizontalScrollView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        horizontalScrollView!.scrollRectToVisible(newFrame, animated: true)
    }
    
    //Go to SAOffersViewController
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
    
    //Go to SASpendViewController
    @IBAction func spendButtonPressed(sender: AnyObject) {
        
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        self.navigationController?.pushViewController(objPlan, animated: false)
    }
    
    //MARK: TableView Delegate and Datasource methods
    
    //This is UITableViewDataSource method used to return the number of sections in table view.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    //This is UITableViewDataSource method used to return the number of rows in each section in table view.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return participantsArr.count;
    }
    
    //This is UITableViewDataSource method used to create custom cell from GroupProgressTableViewCell.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellId = "CellId"
        var cell: GroupProgressTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId) as? GroupProgressTableViewCell
        
        if cell == nil {
            var nibs: Array! =  NSBundle.mainBundle().loadNibNamed("GroupProgressTableViewCell", owner: self, options: nil)
            cell = nibs[0] as? GroupProgressTableViewCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        cell?.saveProgress.progressColors = [chartColors[indexPath.row]]
        cell?.planView.backgroundColor = chartColors[indexPath.row]
        cell?.topVw.backgroundColor = chartColors[indexPath.row]
        cell?.makeImpulseSavingButton.addTarget(self, action: Selector("impulseSavingButtonPressed:"), forControlEvents: .TouchUpInside)
        
        let cellDict = participantsArr[indexPath.row]
        //Adjust the Constraint constant for ecpand and collapse of UITableViewCell
        if prevIndxArr.count > 0 {
            for i in 0 ..< prevIndxArr.count {
                
                if prevIndxArr[i] == indexPath.row {
                    cell?.topVwHt.constant = 22.0
                    cell?.topSpaceProfilePic.constant = 0
                    if indexPath.row == 0{
                        ht = 220.0
                    }else {
                        ht = 160.0
                    }
                    break
                }
                else {
                    cell?.topVwHt.constant = 50.0
                    cell?.topSpaceProfilePic.constant = -3
                }
            }
        }
        else {
            ht = 50.0
            cell?.topVwHt.constant = 50.0
            cell?.topSpaceProfilePic.constant = -3
        }
        
        cell?.topShadowView.backgroundColor = topLabelColors[indexPath.row]
        tblHt.constant = CGFloat(participantsArr.count * 50) + ht
        var diff : CGFloat = 0.0
        //Check if savingPlanTransactionList array is present
        if let transactionArray = cellDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
        {
            for i in 0 ..< transactionArray.count {
                let transactionDict = transactionArray[i]
                paidAmount = paidAmount + Float((transactionDict["amount"] as? NSNumber)!)
                cell?.savedAmountLabel.text = String(format: "£%d",paidAmount)
                cell?.saveProgress.angle = Double((paidAmount * 360)/Float(totalAmount))
                cell?.remainingAmountLabel.text = String(format: "£%d",totalAmount - Int(paidAmount))
                cell?.remainingProgress.angle = Double(((totalAmount - Int(paidAmount)) * 360)/Int(totalAmount))
                
            }
        }
        else  {
            cell?.savedAmountLabel.text = "£0"
            cell?.saveProgress.angle = 0
        
            if(savingPlanDetailsDict["payType"] as! String == "Month")
            {
                diff = (CGFloat(dateDiff)/168)/4
                cell?.remainingAmountLabel.text = String(format: "£%0.0f",round(CGFloat(totalAmount/participantsArr.count)/diff * diff))
            }
            else
            {
                 diff = (CGFloat(dateDiff)/168)
                cell?.remainingAmountLabel.text = String(format: "£%0.0f",round(CGFloat(totalAmount/participantsArr.count)/diff * diff))
            }
            cell?.remainingProgress.angle = 360
        }
        
        //Check if user has Group/Individual plan
        if(cellDict["memberType"] as! String == "Owner")
        {
            cell?.nameLabel.text = String(format:"%@ (organiser)",(cellDict["partyName"] as? String)!)
        }
        else {
            cell?.nameLabel.text = cellDict["partyName"] as? String
        }
        
 
        cell?.payTypeLabel.text = String(format: "per %@",savingPlanDetailsDict["payType"] as! String).lowercaseString
        if(savingPlanDetailsDict["payType"] as! String == "Month")
        {
                   cell?.cellTotalAmountLabel.text = String(format: "£%0.0f",round(CGFloat(totalAmount/participantsArr.count)/diff * diff))
        }
        else {
                   cell?.cellTotalAmountLabel.text = String(format: "£%0.0f",round(CGFloat(totalAmount/participantsArr.count)/diff * diff))
        }
        
        let spinner =  UIActivityIndicatorView()
        spinner.center = CGPointMake((cell?.userProfile.frame.width)!/2, (cell?.userProfile.frame.height)!/2)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        cell?.userProfile.addSubview(spinner)
        cell?.userProfile.layer.cornerRadius = (cell?.userProfile.frame.width)! / 2
        cell?.userProfile.clipsToBounds = true
        
        if let urlString = cellDict["partyImageUrl"] as? String
        {
            let url = NSURL(string:urlString)
            let request: NSURLRequest = NSURLRequest(URL: url!)
            
            if(urlString != "")
            {
                spinner.startAnimating()
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                    if data?.length > 0
                    {
                        let image = UIImage(data: data!)
                        dispatch_async(dispatch_get_main_queue(), {
                            cell?.userProfile.image = image
                            
                            spinner.hidden = true
                            spinner.stopAnimating()
                        })
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), {
                            spinner.hidden = true
                            spinner.stopAnimating()
                        })
                    }
                })
            }
        }
        
        contentVwHt.constant = tblView.frame.origin.y + tblHt.constant
        return cell!
    }
    
    //Used to expand the individual progress  of selected user
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        ht = 0
        dispatch_async(dispatch_get_main_queue()){
            let selectedCell:GroupProgressTableViewCell? = tableView.cellForRowAtIndexPath(indexPath)as? GroupProgressTableViewCell
            selectedCell?.topVwHt.constant = 22.0
            selectedCell?.topSpaceProfilePic.constant = 0
            var isVisible = false
            if self.prevIndxArr.count > 0{
                for i in 0 ..< self.prevIndxArr.count {
                    let obj = self.prevIndxArr[i] as Int
                    if obj == indexPath.row {
                        isVisible = true
                        selectedCell?.topVwHt.constant = 50.0
                        selectedCell?.topSpaceProfilePic.constant = -3
                        self.prevIndxArr.removeAtIndex(i)
                        break
                    }
                }
                if(isVisible == false){
                    self.prevIndxArr.removeAll()
                    self.prevIndxArr.append(indexPath.row)
                }
            }
            else {
                selectedCell?.topVwHt.constant = 50.0
                selectedCell?.topSpaceProfilePic.constant = -3
                self.prevIndxArr.append(indexPath.row)
            }
            self.piechart!.click(indexPath.row)
            self.tblView.reloadData()
        }
    }
    
    //Used to collapse the individual progress  of selected user
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:GroupProgressTableViewCell? = tableView.cellForRowAtIndexPath(indexPath)as? GroupProgressTableViewCell
        selectedCell?.topVwHt.constant = 50.0
        selectedCell?.topSpaceProfilePic.constant = -3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if prevIndxArr.count > 0 {
            for i in 0 ..< prevIndxArr.count {
                if prevIndxArr[i] == indexPath.row {
                    if indexPath.row == 0 {
                        return 220
                    }
                    else {
                        return 160.0
                    }
                }
            }
        }
        return 50.0
    }
    
    func impulseSavingButtonPressed(sender:UIButton)
    {
        let objImpulseSave = SAImpulseSavingViewController()
        self.navigationController?.pushViewController(objImpulseSave, animated: true)
    }
    

    //PiechartDelegate methods
    func setSubtitle(total: CGFloat, slice: Piechart.Slice) -> String {
        return "\(Int(slice.value / total * 100))% \(slice.text)"
    }
    
    func setInfo(total: CGFloat, slice: Piechart.Slice) -> String {
        return "\(Int(slice.value))/\(Int(total))"
    }
    
    //Check if dictionary contains NULL values
    func checkNullDataFromDict(dict:Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject> {
        var replaceDict: Dictionary<String,AnyObject> = dict
        let blank = ""
        for key:String in Array(dict.keys) {
            let ob = dict[key]! as? AnyObject
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
    
     //get users plan delegate methods
    func successResponseForGetUsersPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        var memberTypeArray : Array<String> = []
        if let message = objResponse["message"] as? String
        {
            if(message == "Success")
            {
                savingPlanDetailsDict = self.checkNullDataFromDict(objResponse["partySavingPlan"] as! Dictionary<String,AnyObject>)
                if objResponse["partySavingPlanMembers"] is NSNull
                {
                    
                }
                else
                {
                    participantsArr = objResponse["partySavingPlanMembers"] as! Array<Dictionary<String,AnyObject>>
                }
                var userDict : Dictionary<String,AnyObject> = [:]
                userDict["partyName"] = objResponse["partyName"]
                userDict["partyImageUrl"] = objResponse["partyImageUrl"]
                userDict["savingPlanTransactionList"] = objResponse["savingPlanTransactionList"]
                for(var i=0; i<participantsArr.count; i += 1)
                {
                    let memberTypeDict = participantsArr[i] as Dictionary<String,AnyObject>
                    memberTypeArray.append(memberTypeDict["memberType"] as! String)
                }
                
                if memberTypeArray.contains("Owner")
                {
                    userDict["memberType"] = "Member"
                }
                else {
                    userDict["memberType"] = "Owner"
                }
                participantsArr.append(userDict)
                participantsArr = participantsArr.reverse()
                self.setUpView()
                self.tblView.reloadData()
            }
            else
            {
                pageControl.hidden = true
                groupMembersLabel.hidden = true
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else
        {
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
