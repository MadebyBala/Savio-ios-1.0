//
//  DropDownCellTableViewCell.swift
//  DropDown
//
//  Created by Kevin Hirsch on 28/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

internal final class DropDownCell: UITableViewCell {
	
	//MARK: - Properties
	static let Nib = UINib(nibName: "DropDownCell", bundle: NSBundle(forClass: DropDownCell.self))
	
	//UI
	@IBOutlet weak var optionLabel: UILabel!
	
	var selectedBackgroundColor: UIColor?

}

//MARK: - UI

internal extension DropDownCell {
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		backgroundColor = UIColor.clearColor()
//        optionLabel?.layer.cornerRadius = 2.0
//        optionLabel?.layer.masksToBounds = true
//        optionLabel?.layer.borderWidth=1.0
//        optionLabel?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue:120/256.0, alpha: 1.0).CGColor;
	}
	
	override var selected: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override var highlighted: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override func setHighlighted(highlighted: Bool, animated: Bool) {
		setSelected(highlighted, animated: animated)
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		let executeSelection: () -> Void = { [unowned self] in
			if let selectedBackgroundColor = self.selectedBackgroundColor {
				if selected {
					self.backgroundColor = selectedBackgroundColor
                    self.optionLabel.textColor = UIColor.whiteColor()
				} else {
					self.backgroundColor = UIColor.clearColor()
                    self.optionLabel.textColor = UIColor.blackColor()
				}
			}
		}
		
		if animated {
			UIView.animateWithDuration(0.3, animations: {
				executeSelection()
			})
		} else {
			executeSelection()
		}
	}
	
}