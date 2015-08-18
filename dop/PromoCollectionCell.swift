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
    
    var coupon:Coupon!
    
    func loadItem(coupon:Coupon, viewController: UIViewController) {
        coupon_description.text = coupon.couponDescription
        
        let gesture = UITapGestureRecognizer(target: self, action: "likeCoupon:")
        heartView.addGestureRecognizer(gesture)
        
        self.coupon = coupon
                
        self.likes.text = String(coupon.total_likes)
        
        self.viewController = viewController
        
        if(coupon.user_like == 1){
            self.heart.tintColor = Utilities.dopColor
        }else{
            self.heart.tintColor = UIColor.lightGrayColor()
        }
    }
    
    
    func fetchImage(retry : Bool = true, failure fail : (NSError -> ())? = nil, success succeed: (UIImage -> ())? = nil) {
    
    
    }
    
    
    
    func likeCoupon(sender:UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "coupon_id" : String(stringInterpolationSegment: coupon.id),
            "date" : "2015-01-01"]
        
        var liked:Bool;
        
        if(self.heart.tintColor == UIColor.lightGrayColor()){
            setCouponLike()
            liked = true
        }else{
            removeCouponLike()
            liked = false
        }
    
        CouponController.likeCouponWithSuccess(params,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: couponsData)
                    println(json)
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
    
    
    func setCouponLike(){
        self.heart.tintColor = Utilities.dopColor
        let totalLikes = (self.likes.text!.toInt())!+1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon.setUserLike(1,total_likes: totalLikes)

    }
    func removeCouponLike(){
        self.heart.tintColor = UIColor.lightGrayColor()
        let totalLikes = (self.likes.text!.toInt())!-1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon.setUserLike(0,total_likes: totalLikes)
    }
    
}
