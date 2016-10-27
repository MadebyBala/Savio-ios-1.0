//
//  AppDelegate.swift
//  Savio
//
//  Created by Prashant on 16/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//savio123 - exposrt certificate P12 CertificatesAPNS

import UIKit
import Fabric
import Crashlytics



struct Device {
    static var udid = UIDevice.currentDevice().identifierForVendor!.UUIDString
}

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var objSANav: UINavigationController?
    var objSAWelcomViewController: SAWelcomeViewController?
    var objEnterYourPinViewController: SAEnterYourPINViewController?
    var objRegisterViewController: SARegistrationScreenOneViewController?
    var objCreateViewController: CreatePINViewController?
    
    
    //Set up the window and UINavigationViewController
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Import the library for finding crashesr
        
        Stripe.setDefaultPublishableKey("pk_test_dfQyZuLy5OiRc24IspyuEhdD")
        
        Fabric.with([Crashlytics.self])
        registerForPushNotifications(application)
        
        
        // Check if launched from notification
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
            // Do the stuff after geting Notification when app is not running mode
        }
        
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        //Set the status bar color
        self.setStatusBarBackgroundColor(UIColor.blackColor())
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        //Check if keychain has encrypted pin value.
        let objApi = API()
//                objApi.deleteKeychainValue("savingPlanDict")
//                objApi.deleteKeychainValue("saveCardArray")
        //Check if passcode is stored into keychain.
        if let passcode = objApi.getValueFromKeychainOfKey("myPasscode") as? String
        {
            //If passcode is empty go to SARegistrationViewController.
            if(passcode != "")
            {
                //Check if userInfo is stored into keychain.
                if let userInfoDict = objApi.getValueFromKeychainOfKey("userInfo") as? Dictionary<String,AnyObject>
                {
                    let udidDict = userInfoDict["deviceRegistration"] as! Array<Dictionary<String,AnyObject>>
                    let udidArray = udidDict[0]
                    //Check if current deviceID is present in keychain.
                    if(udidArray["DEVICE_ID"] as! String  == Device.udid)
                    {
                        //else Go to SAEnterYourPINViewController
                        objEnterYourPinViewController = SAEnterYourPINViewController()
                        //Set SAEnterYourPINViewController as rootViewController of UINavigationViewController
                        objSANav = UINavigationController(rootViewController: objEnterYourPinViewController!)
                        window?.rootViewController = objSANav
                    }
                    else {
                        //If no then Go to SAWelcomViewController
                        objSAWelcomViewController = SAWelcomeViewController()
                        //Set SAWelcomViewController as rootViewController of UINavigationViewController
                        objSANav = UINavigationController(rootViewController: objSAWelcomViewController!)
                        window?.rootViewController = objSANav
                    }
                }
                else {
                    //If no then Go to SAWelcomViewController
                    objSAWelcomViewController = SAWelcomeViewController()
                    //Set SAWelcomViewController as rootViewController of UINavigationViewController
                    objSANav = UINavigationController(rootViewController: objSAWelcomViewController!)
                    window?.rootViewController = objSANav
                    
                }
            }
            else  {
                //If no then Go to SARegistrationScreenOneViewController
                objRegisterViewController = SARegistrationScreenOneViewController()
                //Set SAWelcomViewController as rootViewController of UINavigationViewController
                objSANav = UINavigationController(rootViewController: objRegisterViewController!)
                window?.rootViewController = objSANav
                
            }
        }
        else {
            //If no then Go to SAWelcomViewController
            objSAWelcomViewController = SAWelcomeViewController()
            //Set SAWelcomViewController as rootViewController of UINavigationViewController
            objSANav = UINavigationController(rootViewController: objSAWelcomViewController!)
            window?.rootViewController = objSANav
            
        }
        //Customize the UINavigationBar
        objSANav!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "GothamRounded-Medium", size: 20)!]
        objSANav?.navigationBarHidden = true
        window?.makeKeyAndVisible()
        return true
    }
    
    //Set statusBarBackgrounColor
    func setStatusBarBackgroundColor(color: UIColor) {
        guard  let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else {
            return
        }
        
        statusBar.backgroundColor = color
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //Register device for APNS.
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    //Delegate method to verfy if the user accepts or denys the APNS.
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    //Delegate method invoke when APNS is successfully registered, and provide deviceToken.
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
 
        NSUserDefaults.standardUserDefaults().setObject(tokenString, forKey: "APNSTOKEN")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    //Delegate method invoke when the APNS registration is failed
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
    }
    
    // MARK: Handle notifications
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        //--------------For Future Use---------------//
        /*
         let aps = userInfo["aps"] as! [String: AnyObject]
         if let contentAvaiable = aps["content-available"] as? NSString where contentAvaiable.integerValue == 1 {
         // Refresh App with new Content
         
         } else  {
         
         }
         */
        
        if ( application.applicationState == UIApplicationState.Inactive || application.applicationState == UIApplicationState.Background  )
        {
            //opened from a push notification when the app was on background
            var badgeCount = UIApplication.sharedApplication().applicationIconBadgeNumber
            badgeCount = badgeCount - 1
            UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
        }
        if(application.applicationState == UIApplicationState.Active) {
            let dict = userInfo["aps"] as! Dictionary<String,AnyObject>
            let apnsDict = dict["alert"]  as! Dictionary<String,AnyObject>
            //Show the view with the content of the push
            completionHandler(UIBackgroundFetchResult.NewData);
            //Show notification in banner view
            TWMessageBarManager.sharedInstance().showMessageWithTitle(apnsDict["title"] as? String, description: apnsDict["body"] as? String, type: TWMessageBarMessageType.Info)
            //Change apps badge count
            UIApplication.sharedApplication().applicationIconBadgeNumber = Int(dict["badge"] as! NSNumber)
            
        } else if (application.applicationState == UIApplicationState.Background) {
            //Refresh the local model
            completionHandler(UIBackgroundFetchResult.NewData);
            
        } else {
            //Show an in-app banner
            completionHandler(UIBackgroundFetchResult.NewData);
        }
    }
}

