//
//  ShareViewController.swift
//  Share
//
//  Created by Mangesh on 03/06/16.
//  Copyright © 2016 Mangesh  Tekale. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController,UITextFieldDelegate,ShareExtensionDelegate {
    
    @IBOutlet var shareView: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet var lblImagePagingCount: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var bgView: UIView!
    
    var spinner =  UIActivityIndicatorView()
    var currentImagePosition: Int = 0;
    var dictGlobal : Dictionary  <String,AnyObject> = [:]
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
    }
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        priceTextField.resignFirstResponder()
        let objAPI = API()
        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.extension-demo")!
        
        if  let data = defaults.valueForKey("myPasscode") as? NSData
        {
            if((NSKeyedUnarchiver.unarchiveObjectWithData(data) as! String) == "")
            {
                let alert = UIAlertController(title: "Warning", message: "Please login to Savio first", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
                { action -> Void in
                    self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
                    })
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                if self.textView.text.characters.count == 0 && self.priceTextField.text?.characters.count == 0 || self.imageView.image == nil {
                    let alert = UIAlertController(title: "Warning", message: "Looks like required content is not scraped properly, please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else if self.textView.text.characters.count == 0 {
                    let alert = UIAlertController(title: "Warning", message: "Please enter title for product", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else if self.priceTextField.text!.characters.count == 0 {
                    
                    let alert = UIAlertController(title: "Warning", message: "Please enter price for product", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
               else if((priceTextField.text! as NSString).floatValue > 3000)
                {
                    let alert = UIAlertController(title: "Warning", message: "Please enter cost less than £ 3000", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                else {
                    var text = priceTextField.text
                    text = text?.stringByReplacingOccurrencesOfString(",", withString: "")
                    text = text?.stringByReplacingOccurrencesOfString("£", withString: "")
                    print(text)
                    if(Float(text!) < 3000)
                    {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        self.spinner.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, 200)
                        self.spinner.hidesWhenStopped = true
                        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                        self.view.addSubview(self.spinner)
                        self.spinner.startAnimating()
                        var dict : Dictionary<String,AnyObject> = [:]
                        
                        if(self.imageView.image != nil)
                        {
                        let imageData:NSData = UIImageJPEGRepresentation(self.imageView.image!, 1.0)!
                        let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                        var newDict : Dictionary<String,AnyObject> = [:]
                        newDict["imageName.jpg"] = base64String
                        dict["IMAGEURL"] = newDict
                        }
                        let data = defaults.valueForKey("userInfo") as! NSData
                        let userDict = NSKeyedUnarchiver.unarchiveObjectWithData(data)
                        dict["TITLE"] = self.textView.text
                        dict["AMOUNT"] = self.priceTextField.text?.stringByReplacingOccurrencesOfString("£", withString: "")
                        dict["PARTYID"] = userDict!["partyId"]
                        dict["SHAREDSAVINGPLANID"] = ""
                        objAPI.shareExtensionDelegate = self
                        objAPI.sendWishList(dict)
                        
                    });
                    }
                    else {
                        let alert = UIAlertController(title: "Warning", message: "Please pick up item which cost less than £ 3000", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                
            }
        }
        else {
            spinner.stopAnimating()
            spinner.hidden = true
            let alert = UIAlertController(title: "You’re not logged into Savio", message: "Open the app and login or register before adding wish list items.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    //UITextfieldDelegate method
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if (newLength > 4) {
            return false;
        }
        return true;
    }
    
    @IBAction func leftBtnPressed(sender: AnyObject) {
        currentImagePosition -= 1;
        if currentImagePosition < 0 {
            currentImagePosition += 1;
        } else {
            self.showImage(currentImagePosition)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if(UIScreen.mainScreen().bounds.size.height == 480)
        {
            //UIViewAnimation for moving screen little bit up
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            self.view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y-30), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
        }
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if(UIScreen.mainScreen().bounds.size.height == 480)
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            self.view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y+30), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
        }
        
        return true
    }
    
    @IBAction func rightButtonPressed(sender: AnyObject) {
        let imgString = self.dictGlobal["image"] as! String
        let arrayImgUrl:  Array? = imgString.componentsSeparatedByString("#~@")   // #~@ taken from ShareExtensio.js file
        currentImagePosition += 1;
        if currentImagePosition >= arrayImgUrl?.count {
            currentImagePosition -= 1
        }
        else {
            self.showImage(currentImagePosition)
        }
    }
    //UIView life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for item: AnyObject in (self.extensionContext?.inputItems)! {
            let inputItem = item as! NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.extension-demo")!
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) -> Void in
                        if let resultDict = result as? NSDictionary {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.dictGlobal = resultDict[NSExtensionJavaScriptPreprocessingResultsKey] as! [String : AnyObject]
                                defaults.setObject(self.dictGlobal, forKey: "ScrapingResult")
                                self.textView.text = self.dictGlobal["title"] as! String
                                self.priceTextField.text = self.dictGlobal["price"] as? String
                            });
                            self.showImage(self.currentImagePosition)
                            
                        }
                        else {
                            print("no dictionary found")
                        }
                    })
                }
                else{
                   self.dictGlobal = defaults.valueForKey("ScrapingResult") as! Dictionary<String,AnyObject>
                    dispatch_async(dispatch_get_main_queue(), {
                        self.textView.text = self.dictGlobal["title"] as! String
                        self.priceTextField.text = self.dictGlobal["price"] as? String
                    });
                    self.showImage(self.currentImagePosition)
                }
            }
        }
        
        var customToolBar : UIToolbar?
        customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        customToolBar!.items = [acceptButton]
        
        bgView.layer.cornerRadius = 5
        bgView.layer.masksToBounds = true
        priceTextField.inputAccessoryView = customToolBar
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    func doneBarButtonPressed() {
        priceTextField.resignFirstResponder()
        if(UIScreen.mainScreen().bounds.size.height == 480)
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            self.view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y+30), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
        }
        
        if((priceTextField.text! as NSString).floatValue > 3000)
        {
            let alert = UIAlertController(title: "Warning", message: "Please enter cost less than £ 3000", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func showImage(idx: Int)  {
        dispatch_async(dispatch_get_main_queue(), {
            let imgString = self.dictGlobal["image"] as! String
            let arrayImgUrl:  Array? = imgString.componentsSeparatedByString("#~@")   // #~@ taken from ShareExtensio.js file
            
            var imgURLString: String? = arrayImgUrl![idx] as String
            imgURLString = imgURLString?.stringByReplacingOccurrencesOfString("'", withString: "")
            let imgURL: NSURL? = NSURL.init(string: imgURLString!)
            let imgData:  NSData? = NSData.init(contentsOfURL: imgURL!)
            if imgData != nil {
                self.imageView.image = UIImage(data: imgData!)
            }
            self.lblImagePagingCount.text = String(format: "%d / %d", arguments:[idx+1, (arrayImgUrl?.count)!])
        });
    }
    
    func successResponseForShareExtensionAPI(objResponse: Dictionary<String, AnyObject>) {
        spinner.stopAnimating()
        spinner.hidden = true
        
        let alert = UIAlertController(title: "Success", message: "Item successfully added to wishlist", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
        { action -> Void in
            self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
            
            })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func errorResponseForShareExtensionAPI(error: String) {
        spinner.stopAnimating()
        spinner.hidden = true
        if(error == "No network found")
        {
            let alert = UIAlertController(title: "Connection problem", message: "Savio needs the internet to Save wish list items. Check your data connection and try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
            { action -> Void in
                self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
                })
            self.presentViewController(alert, animated: true, completion: nil)
        }else {
            let alert = UIAlertController(title: "Warning", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
            { action -> Void in
                self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
                })
            self.presentViewController(alert, animated: true, completion: nil)

        }
       
    }
}
