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
    
    @IBOutlet var heartView: UIView!
    @IBOutlet var heart: UIImageView!
    var viewController: UIViewController?
    var coupon:Coupon!
    
    func loadItem(coupon:Coupon, viewController: UIViewController) {
        //coupon_description.text = coupon.couponDescription
        
      /*  self.shareButton.setBackgroundImage(UIImage(named: "share-icon"), forState: UIControlState.Normal)*/
        let gesture = UITapGestureRecognizer(target: self, action: "likeCoupon:")
        let coupon_gesture = UITapGestureRecognizer(target: self, action: "tapCoupon:")
        
        heartView.addGestureRecognizer(gesture)
        self.addGestureRecognizer(coupon_gesture)
        self.coupon = coupon
        self.likes.text = String(coupon.total_likes)
        self.viewController = viewController
        if coupon.user_like == 1 {
            self.heart.tintColor = Utilities.dopColor
        } else {
            self.heart.tintColor = UIColor.lightGrayColor()
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 230))
    }
    
    func likeCoupon(sender: UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "coupon_id" : String(stringInterpolationSegment: coupon.id),
            "date" : "2015-01-01"]
        
        var liked: Bool
        
        if (self.heart.tintColor == UIColor.lightGrayColor()) {
            self.setCouponLike()
            liked = true
        } else {
            self.removeCouponLike()
            liked = false
        }
        
        CouponController.likeCouponWithSuccess(params,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: couponsData)
                    print(json)
                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if(liked == true){
                        self.removeCouponLike()
                    }else{
                        self.setCouponLike()
                    }
                })
        })
    }
    
    func setCouponLike() {
        heart.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.heart.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        self.heart.tintColor = Utilities.dopColor
        let totalLikes = (Int(self.likes.text!))! + 1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon.setUserLike(1, total_likes: totalLikes)
    }
    
    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGrayColor()
        let totalLikes = (Int(self.likes.text!))! - 1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon.setUserLike(0, total_likes: totalLikes)
    }
    
    func tapCoupon(sender:UITapGestureRecognizer){
        //self.viewController!.performSegueWithIdentifier("couponDetail", sender: self)
        let modal:ModalViewController = ModalViewController(currentView: self.viewController!, type: ModalViewControllerType.CouponDetail)
        
        dispatch_async(dispatch_get_main_queue()) {
            
            modal.willPresentCompletionHandler = { vc in
                let navigationController = vc as! SimpleModalViewController
                /*navigationController.title_label.text = self.coupon.name
                navigationController.title_label.text = navigationController.title_label.text?.uppercaseString
                navigationController.category_label.text = "Cafeteria"
                navigationController.category_label.text = navigationController.category_label.text?.uppercaseString*/
                navigationController.coupon = self.coupon
                
            }
            modal.presentAnimated(true, completionHandler: nil)
           
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setCoupon(coupon:Coupon, view:UIViewController, x:CGFloat, y:CGFloat){
        self.coupon = coupon
        self.viewController = view
        self.frame.origin = CGPointMake(x,y)
    }
    
}

