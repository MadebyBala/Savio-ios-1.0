//
//  ContainerViewController.swift
//  Savio
//
//  Created by Prashant on 20/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

let kNotificationToggleMenuView = "ToggleCentreView"   //NotificationIdentifier for toggle menu
let kNotificationAddCentreView = "AddCentreView"       //NotificationIdentifier for menu selection

class ContainerViewController: UIViewController {
    //Create object for mnuviewcontroller
    var menuVC: UIViewController! = SAMenuViewController(nibName: "SAMenuViewController", bundle: nil)
    //Create object for showing selected menu
    var centreVC: UIViewController! =  SACreateSavingPlanViewController(nibName: "SACreateSavingPlanViewController", bundle: nil)
    var navController: UINavigationController!
    var isShowingProgress:String?
    var newView = UIView()
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let objAPI = API()
        if let userPlan = objAPI.getValueFromKeychainOfKey("savingPlanDict") as? Dictionary<String,AnyObject>
        {
            if let savedCard =  objAPI.getValueFromKeychainOfKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
            {
                self.setUpViewController()
            }
            else {
                //Go to SAPaymentFlowViewController if you did not find the saved card details
                self.centreVC = SAPaymentFlowViewController()
            }
        }
        else {
            self.setUpViewController()
        }
        //--------------Setting up navigation controller--------------------------------
        self.navController = UINavigationController(rootViewController: self.centreVC)
        self.navController.view.frame = self.view.frame
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        //        self.navController.navigationBar.hidden = true
        
        self.view.addSubview(self.menuVC!.view)
        self.view.addSubview(self.navController!.view)
        self.addChildViewController(self.navController)
        self.view.addSubview(self.navController!.view)
        //----------------------------------------------------------------------------------
        
        //------Register notfication for menu toggel and menu selection-----------------------
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addCentreView:", name: kNotificationAddCentreView, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ToggleCentreView", name: kNotificationToggleMenuView, object: nil)
        //---------------------------------------------------------------------------------------
    }
    func setUpViewController()
    {
        // Set all plan flag
        let individualFlag = NSUserDefaults.standardUserDefaults().valueForKey("individualPlan") as! NSNumber
        let groupFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupPlan") as! NSNumber
        let groupMemberFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupMemberPlan") as! NSNumber
        if let usersPlan = NSUserDefaults.standardUserDefaults().valueForKey("UsersPlan") as? String
        {
            //As per flag show the progress view of plan
            if usersPlan == "I"{
                self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
            }
            else
            {
                self.centreVC = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
            }

        }
        else {
            if individualFlag == 1 { //Individual plan
                self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
            }
            else if(groupFlag == 1 || groupMemberFlag == 1) //Group or group member plan
            {
                self.centreVC = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
            }
            else {//create saving plan if no plan exist
                self.centreVC = SACreateSavingPlanViewController(nibName: "SACreateSavingPlanViewController", bundle: nil)
            }
        }
        
   
    }
    
    //function invoke on tapping menu button.
    func ToggleCentreView() {
        var destination = self.navController.view.frame;
        if (destination.origin.x > 0) {
            destination.origin.x = 0;
            newView.removeFromSuperview()
        } else {
            destination.origin.x += 250
            newView.frame = CGRectMake(250, 40, self.navController.view.frame.width, self.navController.view.frame.height)
            newView.backgroundColor = UIColor.clearColor()
            let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 1
            tapGesture.addTarget(self, action: Selector("newViewTouched:"))
            newView.addGestureRecognizer(tapGesture)
            self.view.addSubview(newView)
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.navController.view.frame = destination
        })
    }
    
    func newViewTouched(sender:UITapGestureRecognizer)
    {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.navController.view.frame = CGRectMake(0, 0, self.navController.view.frame.width, self.navController.view.frame.height)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //Function invoke when menu item selected and kNotificationAddCentreView notification is broadcast.
    func addCentreView(notification: NSNotification) {
        let className = notification.object as! String
        //Check selected menu class and current class is same then close menu
        if (self.centreVC.nibName == className) || (self.centreVC.nibName == "SAGroupProgressViewController" && className == "SAProgressViewController") {
            self.ToggleCentreView()
            return
        }
        self.navController.view.removeFromSuperview()
        self.navController.removeFromParentViewController()
        
        //Identify selected menu class and as per class name replace viewcontroller with selected class
        switch className {
        case "SACreateSavingPlanViewController":
            self.centreVC = SACreateSavingPlanViewController(nibName: "SACreateSavingPlanViewController", bundle: nil)
            self.replaceViewController()
            
        case "SAWishListViewController":
            self.centreVC = SAWishListViewController(nibName: "SAWishListViewController", bundle: nil)
            self.replaceViewController()
            
        case "SAOfferListViewController":
            
            NSUserDefaults.standardUserDefaults().removeObjectForKey("offerList")
            
            let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92]
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            NSUserDefaults.standardUserDefaults().synchronize()
            let obj = SAOfferListViewController(nibName: "SAOfferListViewController", bundle: nil)
            obj.hideAddOfferButton = true
            self.centreVC = obj
            centreVC.hidesBottomBarWhenPushed = true
            self.replaceViewController()
            
        case "SASwitchViewController":
            self.centreVC = SASwitchViewController(nibName: "SASwitchViewController", bundle: nil)
            self.replaceViewController()
            
        case "SAProgressViewController":
            NSUserDefaults.standardUserDefaults().removeObjectForKey("offerList")
            NSUserDefaults.standardUserDefaults().synchronize()
            //Assigning all plan flag
            let individualFlag = NSUserDefaults.standardUserDefaults().valueForKey("individualPlan") as! NSNumber
            
            var usersPlanFlag = ""
            if let usersPlan = NSUserDefaults.standardUserDefaults().valueForKey("UsersPlan") as? String
            {
                usersPlanFlag = usersPlan
                //As per flag show the progress view of plan
                if individualFlag == 1 && usersPlanFlag == "I"{
                    self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
                }
                else
                {
                    self.centreVC = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
                }
                
            } else {
                usersPlanFlag = ""
                //As per flag show the progress view of plan
                if individualFlag == 1{
                    self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
                }
                else
                {
                    self.centreVC = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
                }
            }
            self.replaceViewController()
            
        case "SASavingPlanViewController":
            
            let obj = SASavingPlanViewController(nibName: "SASavingPlanViewController", bundle: nil)
            obj.isUpdatePlan = true
            let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92]
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.centreVC = obj
            self.replaceViewController()
            
        case "SASettingsViewController":
            self.centreVC = SAEditUserInfoViewController(nibName: "SAEditUserInfoViewController", bundle: nil)
            self.replaceViewController()
            
        case "SASpendViewController":
            self.centreVC = SASpendViewController(nibName: "SASpendViewController", bundle: nil)
            self.replaceViewController()
            
        case "SignOut":
            let alert = UIAlertView(title: "Alert", message: "Work in progress", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        default:
            let alert = UIAlertView(title: "Alert", message: "Your saving plan is created successfully", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    //Function invoke for replace the current menu class with selected menu class
    func replaceViewController() {
        self.navController = UINavigationController(rootViewController: self.centreVC)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.navController.view.frame = self.view.frame
        self.addChildViewController(self.navController)
        self.view.addSubview(self.navController!.view)
    }
    
}
