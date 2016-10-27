//
//  slider.swift
//  Savio
//
//  Created by Maheshwari on 07/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class slider: UISlider {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        let rect:CGRect = CGRectMake(0, 10, UIScreen.mainScreen().bounds.width-140, 8)
        return rect
    }
}
