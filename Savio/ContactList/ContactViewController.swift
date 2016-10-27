//
//  ContactViewController.swift
//  Savio
//
//  Created by Prashant on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

//----------Custom protocol for add or skip contact-----------------------
protocol SAContactViewDelegate {
    
    func addedContact(contactDict:Dictionary<String,AnyObject>)
    func skipContact()
}
//------------------------------------------------------------------------

class ContactViewController: UIViewController {
    
    var contactDict: Dictionary<String,AnyObject> = [:] //Dictionary for holding contact info
    var delegate : SAContactViewDelegate?
    
     //MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableView Delegate and Datasource method
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //by default 2 rows visible
        var count = 2
        //if mobile number and email id both available then 3 rows visible
        if (contactDict["mobileNum"] != nil && contactDict["email"] != nil) {
            count = 3
        }
        return count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if indexPath.row == 0{
            let cellID: String = "CellID"
            //create reusable custom cell from ContactProfileTableViewCell.xib to show user info
            var cell: ContactProfileTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellID) as? ContactProfileTableViewCell
            if cell == nil {
                var nib :Array! = NSBundle.mainBundle().loadNibNamed("ContactProfileTableViewCell", owner: nil, options: nil)
                cell = nib[0] as? ContactProfileTableViewCell
            }
            //Showing contact image
            cell?.personImage?.image = contactDict["imageData"] as? UIImage
            //Showing name
            if let name = contactDict["name"] as? String{
                if let lastName = contactDict["lastName"] as? String{
                    cell?.name?.text = String(format: "%@ %@", name, lastName)
                }
            }
            return cell!
        }
        else {
            //create reusable custom cell from ContactTableViewCell.xib to show user contact
            let cellID: String = "ContactCell"
            var cell: ContactTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellID) as? ContactTableViewCell
            if cell == nil {
                var nib :Array! = NSBundle.mainBundle().loadNibNamed("ContactTableViewCell", owner: nil, options: nil)
                cell = nib[0] as? ContactTableViewCell
            }
            
            //setting up invite button
            cell?.inviteBtn?.tag = indexPath.row
            cell?.inviteBtn?.addTarget(self, action: Selector("clickOnInviteButton:"), forControlEvents: UIControlEvents.TouchUpInside)
            if indexPath.row == 1 {
                //mobile number avalable then showing in contact list
                if let mobileNum: String = contactDict["mobileNum"] as? String {
                    cell?.headerLbl?.text = "mobile"
                    cell?.detailLable?.text = mobileNum
                }
                else {
                    //showing email id if mobile num not present
                    if let emailStr: String = contactDict["email"] as? String {
                        cell?.headerLbl?.text = "email"
                        cell?.detailLable?.text = emailStr
                    }
                }
            }
            if indexPath.row == 2 {
                //Showing email id from contact
                if let emailStr: String = contactDict["email"] as? String {
                    cell?.headerLbl?.text = "email"
                    cell?.detailLable?.text = emailStr
                }
            }
            return cell!
        }
    }
    //set row height
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80.0
        }
        else {
            return 77.0
        }
    }
    
    //function invoke when user tapped on invite button from cell
    func clickOnInviteButton(sender:UIButton){
        var text: String = ""
        var name : String = ""
        var mobileArray : Array<String> = [] // holding available mobile number
        var emailArray : Array<String> = [] // holding available mobile number
        var nameArray : Array<String> = []
        
        //Validating if user alredy select for invitation
        if let contactArray = NSUserDefaults.standardUserDefaults().objectForKey("InviteGroupArray") as? Array<Dictionary<String,AnyObject>>
        {
            for i in 0 ..< contactArray.count {
                var dict = contactArray[i] as Dictionary<String,AnyObject>
                if let phone = dict["mobile_number"] as? String
                {
                    mobileArray.append(String(format:"+44%@",phone))
                }
                if let email = dict["email"] as? String
                {
                    emailArray.append(email)
                }
                if let first_name = dict["first_name"] as? String
                {
                    nameArray.append(first_name)
                }
            }
        }
        //get all contact detail for invitation
        var dict : Dictionary<String,AnyObject> = [:]
        if sender.tag == 1 {
            if let mobileNum: String = contactDict["mobileNum"] as? String {
                dict["mobile_number"] = String(format:"+44%@",mobileNum)
                dict["email_id"] = ""
                 dict["NOMID"] = "4"
                text = mobileNum
            }
            else {
                if let emailStr: String = contactDict["email"] as? String {
                    dict["email_id"] = emailStr
                    dict["mobile_number"] = ""
                    dict["NOMID"] = "6"
                    text = emailStr
                }
            }
        }
        else {
            if let emailStr: String = contactDict["email"] as? String {
                dict["email_id"] = emailStr
                dict["mobile_number"] = ""
                dict["NOMID"] = "6"
                text = emailStr
            }
        }
        if let firstName = contactDict["name"] as? String
        {
            dict["first_name"] = String(format: "%@", firstName)
            name = String(format: "%@", contactDict["name"] as! String)
        }
        
        if let lastName = contactDict["lastName"] as? String
        {
            dict["first_name"] = String(format: "%@ %@", contactDict["name"] as! String, lastName)
            name = String(format: "%@ %@", contactDict["name"] as! String, contactDict["lastName"] as! String)
        }
  
        if(mobileArray.count > 0 || emailArray.count > 0)
        {
            //checking is contact alredy selected
            if(mobileArray.contains(text) || nameArray.contains(name))
            {
                let alert = UIAlertView(title: "Alert", message: "You have already invited this contact", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else if(emailArray.contains(text) || nameArray.contains(name)) {
                let alert = UIAlertView(title: "Alert", message: "You have already invited this contact", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else {
                //not selected then select contact for invitation
                delegate?.addedContact(dict)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        else {
            delegate?.addedContact(dict)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}