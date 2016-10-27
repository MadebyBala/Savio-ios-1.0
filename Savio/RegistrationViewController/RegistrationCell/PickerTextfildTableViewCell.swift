//
//  PickerTextfildTableViewCell.swift
//  Savio
//
//  Created by Prashant Mali on 21/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol PickerTxtFieldTableViewCellDelegate {
    func selectedDate(txtFldCell:PickerTextfildTableViewCell)
//    func cancleToSelectDate(txtFldCell:PickerTextfildTableViewCell)
}

class PickerTextfildTableViewCell: UITableViewCell,UITextFieldDelegate{

    @IBOutlet weak var tfDatePicker: UITextField!
    weak var tblView: UITableView?
    var previousDate: String?

    @IBOutlet weak var toolBarInput: UIToolbar?
    
    var datePickerView:UIDatePicker = UIDatePicker()

    var delegate: PickerTxtFieldTableViewCellDelegate?


    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tfDatePicker.inputAccessoryView = toolBarInput
        previousDate = tfDatePicker.text!
        
        tfDatePicker?.layer.cornerRadius = 2.0
        tfDatePicker?.layer.masksToBounds = true
        tfDatePicker?.layer.borderWidth=1.0
        tfDatePicker?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;

        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectDate(sender: UITextField) {
        previousDate = tfDatePicker.text
        
        //        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        sender.inputView = datePickerView
        //        datePickerView.maximumDate=NSDate()
        
        
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.year = -18
        let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        datePickerView.maximumDate = minDate
        
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        //               datePickerView.selectRow(0!, inComponent: 0, animated: false)
        
    }
    
    func setDateToTextField(){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        tfDatePicker.text = dateFormatter.stringFromDate(datePickerView.date)
        previousDate = tfDatePicker.text!
        delegate?.selectedDate(self)


    }

    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        tfDatePicker.text = dateFormatter.stringFromDate(datePickerView.date)
       self.setDateToTextField()
    }
    
    @IBAction func toolBarDoneBtnClicked(){
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
       let todayDate = dateFormatter.stringFromDate(NSDate())
        
        let pickrDate = dateFormatter.stringFromDate(datePickerView.date)
        
        if todayDate == pickrDate{
            let allarme = UIAlertView(title: "Warning", message: "Birthdate should not be today's date", delegate: nil, cancelButtonTitle: "Ok")
            allarme.show()
        }else {
        self.setDateToTextField()
        tfDatePicker.resignFirstResponder()
        previousDate = tfDatePicker.text!
        delegate?.selectedDate(self)
        }
        
    }
    
    @IBAction func toolBarCancleBtnClicked(){
        tfDatePicker.resignFirstResponder()
        previousDate = tfDatePicker.text!
        delegate?.selectedDate(self)

//        delegate?.cancleToSelectDate(self)
    }

}








































































