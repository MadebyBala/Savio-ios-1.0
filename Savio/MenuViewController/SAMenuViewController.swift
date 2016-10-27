//
//  SAMenuViewController.swift
//  Savio
//
//  Created by Prashant on 20/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var menuTable: UITableView?
    var arrMenu: Array<Dictionary<String,AnyObject>> = []
    var isFromSummary = false
    
    // MARK: - ViewController life cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup Menu as per plan created
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("methodOfReceivedNotification:"), name:"NotificationIdentifier", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("methodForSelectRowAtIndexPath:"), name:"SelectRowIdentifier", object: nil)
        //Set up UI for Menu
        self.setUpUI()
    }
    
    //Function invoke when NotificationIdentifier notification brodcast
    func methodOfReceivedNotification(notification: NSNotification){
        //Take Action on Notification
        arrMenu.removeAll()
        self.setUpUI()
        menuTable?.reloadData()
    }
    
    func methodForSelectRowAtIndexPath(notification: NSNotification)
    {
         if let indxPath = NSUserDefaults.standardUserDefaults().valueForKey("SelectedIndexPath") as? Int
         {
          self.deSelectRow(NSIndexPath(forRow: indxPath,inSection: 0))
        }
        isFromSummary = true
        self.selectRow(NSIndexPath(forRow: 1,inSection: 0))
    }
    
    //Function invoking for setup the UI
    func setUpUI() {
        //Create Menu's JSON file URL
        let fileUrl: NSURL = NSBundle.mainBundle().URLForResource("Menu", withExtension: "json")!
        //Getting FileData
        let jsonData: NSData = NSData(contentsOfURL: fileUrl)!
        //Parsing Json file data
        let arr: NSArray = (try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as! NSArray
        //setting individual, group and group member plan's flag
        let individualFlag = NSUserDefaults.standardUserDefaults().valueForKey("individualPlan") as! NSNumber
        let groupFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupPlan") as! NSNumber
        let groupMemberFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupMemberPlan") as! NSNumber
        
        //Set up number of menu as per plan created
        for i in 0 ..< arr.count {
            var dict = arr[i] as! Dictionary<String,AnyObject>
            if dict["className"]!.isEqualToString("SAProgressViewController") {
                dict["showInMenu"] = "No"
                if (individualFlag == 1 || groupFlag == 1 || groupMemberFlag == 1){
                    dict["showInMenu"] = "Yes"
                    arrMenu.append(dict)
                }
            }
            else if dict["className"]!.isEqualToString("SASavingPlanViewController") {
                dict["showInMenu"] = "No"
                if(individualFlag == 1){
                    dict["showInMenu"] = "Yes"
                    arrMenu.append(dict)
                }
            }
             else if dict["className"]!.isEqualToString("SASwitchViewController") {
                dict["showInMenu"] = "No"
                if (individualFlag == 1 && groupMemberFlag == 1) || (groupFlag == 1 && groupMemberFlag == 1){
                    dict["showInMenu"] = "Yes"
                    arrMenu.append(dict)
                }
            }
            else {
                arrMenu.append(dict)
            }
        }
    }
    
    func selectRow(indexPath:NSIndexPath)
    {
        self.tableView(self.menuTable!, didSelectRowAtIndexPath:indexPath)
        self.menuTable?.reloadData()
        isFromSummary = false
    }
    
    func deSelectRow(indexPath:NSIndexPath)
    {
        let indxPath = NSUserDefaults.standardUserDefaults().valueForKey("SelectedIndexPath") as? Int
        self.tableView(self.menuTable!, didDeselectRowAtIndexPath: NSIndexPath(forRow: indxPath!,inSection:0))
        self.menuTable?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Tableview datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMenu.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Create reusable custom cell from MenuTableViewCell.xib
        let cellIdentifier:String = "CustomFields"
        var cell:MenuTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? MenuTableViewCell
        
        if (cell == nil) {
            var nibs: Array! =  NSBundle.mainBundle().loadNibNamed("MenuTableViewCell", owner: self, options: nil)
            cell = nibs[0] as? MenuTableViewCell
        }
        //got individual menu's info
        let dict =  self.arrMenu[indexPath.row]
        //Showing Menu title
        cell?.title?.text =  dict["title"] as? String
        //Showing menu icon
        let imageName =  dict["image"] as! String
        let imageIcon = UIImage(named: imageName)//?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell?.icon?.image = imageIcon
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dict =  self.arrMenu[indexPath.row]
        
        let selectedCell:MenuTableViewCell? = menuTable!.cellForRowAtIndexPath(indexPath)as? MenuTableViewCell
        //Changing background color of selected row
        selectedCell!.contentView.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        let imageName =  dict["activeImage"] as! String
        let imageIcon = UIImage(named: imageName)
        selectedCell?.icon?.image = imageIcon

        let className: String = dict["className"] as! String
        
        NSUserDefaults.standardUserDefaults().setObject(indexPath.row, forKey: "SelectedIndexPath")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        //Brodcast the notification for navigating flow
        if(isFromSummary == false)
        {
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: className)
        }
        
    }
    
    // Just set it back in deselect
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indxPath = NSUserDefaults.standardUserDefaults().valueForKey("SelectedIndexPath") as? Int
        self.menuTable?.deselectRowAtIndexPath(NSIndexPath(forRow: indxPath!,inSection:0), animated: true)
        
        
        let selectedCell:MenuTableViewCell? = menuTable!.cellForRowAtIndexPath(indexPath)as? MenuTableViewCell
        selectedCell!.contentView.backgroundColor = UIColor.whiteColor()
        let dict =  self.arrMenu[indexPath.row]
        let imageName =  dict["image"] as! String
        let imageIcon = UIImage(named: imageName)
        selectedCell?.icon?.image = imageIcon
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
