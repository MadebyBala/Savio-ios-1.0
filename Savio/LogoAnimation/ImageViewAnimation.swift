//
//  ImageViewAnimation.swift
//  PostalCodeVerification-Demo
//
//  Created by Maheshwari on 18/05/16.
//  Copyright © 2016 Maheshwari. All rights reserved.
//

import UIKit

protocol ImageViewAnimationProtocol {
    
    func endAnimation()
}
class ImageViewAnimation: UIView {
    
    @IBOutlet  var animationImageView: UIImageView?
    var imageArray : [UIImage] = []
    var delegate : ImageViewAnimationProtocol?
    
     func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
    func animate() {
        //adding image names to array
        for i in 1 ..< 9
        {
            imageArray.append(UIImage(named:String(format: "%d.png",i))!)
        }
       
        //UIImageview animation
        animationImageView!.animationImages = imageArray
        animationImageView!.animationDuration = 1
        animationImageView!.animationRepeatCount = 0
        animationImageView!.startAnimating()
    }
    
    
}
