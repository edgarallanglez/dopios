//
//  TrendingCoupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 23/09/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TrendingCoupon: UIView {
    
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var logo: UIImageView!
    @IBOutlet var likes: UILabel!
    
    var viewController: UIViewController?
    var coupon:Coupon!
    
    func loadItem(coupon:Coupon, viewController: UIViewController) {
        //coupon_description.text = coupon.couponDescription
        
      /*  self.shareButton.setBackgroundImage(UIImage(named: "share-icon"), forState: UIControlState.Normal)
        let gesture = UITapGestureRecognizer(target: self, action: "likeCoupon:")
        heartView.addGestureRecognizer(gesture)
        self.coupon = coupon
        self.likes.text = String(coupon.total_likes)
        self.viewController = viewController
        if coupon.user_like == 1 {
            self.heart.tintColor = Utilities.dopColor
        } else {
            self.heart.tintColor = UIColor.lightGrayColor()
        }*/
    }
    
    init(height: Int) {
        print("AHLO")
        
        
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: height))
        
        
        logo.userInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: "tapCoupon:")
        
        self.addGestureRecognizer(gesture)
        
        
        self.userInteractionEnabled = true
        
    }
    
    
    func tapCoupon(sender:UITapGestureRecognizer){
        self.viewController!.performSegueWithIdentifier("couponDetail", sender: self)
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func move(x: CGFloat, y: CGFloat){
        self.frame.origin = CGPointMake(x, y)
    }
    
}

