//
//  PromoCollectionCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PromoCollectionCell: UICollectionViewCell {
    
    @IBOutlet var coupon_description: UILabel!
    @IBOutlet var branch_banner: UIImageView!
    @IBOutlet var heart: UIImageView!
    @IBOutlet var likes: UILabel!
    @IBOutlet var heartView: UIView!
    
    var viewController: UIViewController?
    
    var couponId:Int!
    
    func loadItem(coupon:Coupon, viewController: UIViewController) {
        coupon_description.text = coupon.couponDescription
        
        let gesture = UITapGestureRecognizer(target: self, action: "likeCoupon:")
        heartView.addGestureRecognizer(gesture)
        
        self.couponId = coupon.id
        
        self.likes.text = String(coupon.total_likes)
        
        self.viewController = viewController
        
        if(coupon.user_like == 1){
            self.heart.tintColor = Utilities.dopColor
        }else{
            self.heart.tintColor = UIColor.lightGrayColor()
        }
    }
    func likeCoupon(sender:UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "coupon_id" : String(stringInterpolationSegment: couponId),
            "date" : "2015-01-01"]
        
        CouponController.likeCouponWithSuccess(params){ (couponsData) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                let json = JSON(data: couponsData)
                if(self.heart.tintColor == UIColor.lightGrayColor()){
                    self.heart.tintColor = Utilities.dopColor
                    let totalLikes = (self.likes.text!.toInt())!+1
                    self.likes.text = String(stringInterpolationSegment: totalLikes)
                }else{
                    self.heart.tintColor = UIColor.lightGrayColor()
                    let totalLikes = (self.likes.text!.toInt())!-1
                    self.likes.text = String(stringInterpolationSegment: totalLikes)
                }

                println(json)
            });
        }
    }
    
}
