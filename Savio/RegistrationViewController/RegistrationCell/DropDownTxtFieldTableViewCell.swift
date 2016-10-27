//
//  DropDownTxtFieldTableViewCell.swift
//  Savio
//
//  Created by Prashant Mali on 21/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
protocol DropDownTxtFieldTableViewCellDelegate {
    
    func dropDownTxtFieldCellText(dropDownTextCell:DropDownTxtFieldTableViewCell)
}

class DropDownTxtFieldTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    var delegate: DropDownTxtFieldTableViewCellDelegate?
    @IBOutlet weak var tf: UITextField?
    weak var tblView: UITableView?
    var dict: NSDictionary?
     var arr: [String] = []
     var placeHolder = String()
     var dropDown = DropDown()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tf?.layer.cornerRadius = 2.0
        tf?.layer.masksToBounds = true
        tf?.layer.borderWidth=1.0
        tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
        
//        tf!.attributedPlaceholder = NSAttributedString(string:placeHolder, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        tf?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        
        
//        let placeholder = NSAttributedString(string:"" , attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
//        tf?.attributedPlaceholder = placeholder;
        tf?.delegate = self
//        let metadataDict = dict["metaData"]
//        let lableDict = metadataDict["textField1"]!.mutableCopy()
////        lableDict.setValue(addressArray, forKey: "dropDownArray")
            }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        self.setUpDropDown()
        self.showOrDismiss()
        return false
    }
    
    func showOrDismiss(){
        if dropDown.hidden {
            dropDown.show()
        } else {
            dropDown.hide()
        }
    }

    func setUpDropDown(){
        arr.sortInPlace { sortTwoString($0, value2: $1) }
        dropDown.dataSource = arr

        dropDown.selectionAction = { [unowned self] (index, item) in
            self.tf?.text = item
            self.delegate?.dropDownTxtFieldCellText(self)
        }
        dropDown.selectionBackgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        dropDown.anchorView = tf
        dropDown.bottomOffset = CGPoint(x: 0, y:tf!.bounds.height)
    }
    
    @IBAction func clickeOnDropDownArrow(sender:UIButton){
         self.setUpDropDown()
        self.showOrDismiss()
    }
    
    
    func sortTwoString(value1: String, value2: String) -> Bool {
        // One string is alphabetically first.
        // ... True means value1 precedes value2.
        return value1 < value2;
    }
    
}
