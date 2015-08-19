//
//  PromoCollectionCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Social
import FBSDKShareKit

class PromoCollectionCell: UICollectionViewCell {
    
    @IBOutlet var coupon_description: UILabel!
    @IBOutlet var branch_banner: UIImageView!
    @IBOutlet var heart: UIImageView!
    @IBOutlet var likes: UILabel!
    @IBOutlet var heartView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    
    var viewController: UIViewController?
    
    var couponId: Int!
    
    var coupon:Coupon!
    
    func loadItem(coupon:Coupon, viewController: UIViewController) {
        coupon_description.text = coupon.couponDescription
        
        var rawString = String.fontAwesomeString("fa-facebook")
        var stringAttributed = NSMutableAttributedString(string: rawString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 1)!])
        stringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("FontAwesome", fontSize: 15), range: NSRange(location: 0,length: 1))
        
        self.shareButton.titleLabel?.textAlignment = .Center
        self.shareButton.titleLabel?.numberOfLines = 1
        self.shareButton.setAttributedTitle(stringAttributed, forState: UIControlState.Normal)
        
        let gesture = UITapGestureRecognizer(target: self, action: "likeCoupon:")
        heartView.addGestureRecognizer(gesture)
        
        self.coupon = coupon
                
        self.likes.text = String(coupon.total_likes)
        
        self.viewController = viewController
        
        if(coupon.user_like == 1) {
            self.heart.tintColor = Utilities.dopColor
        } else {
            self.heart.tintColor = UIColor.lightGrayColor()
        }
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
    
    
    @IBAction func shareCoupon(sender: UIButton) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://www.allan-glez.com/")
        content.contentTitle = "Mira comparto desde dop para el mundo"
        content.contentDescription = self.coupon_description?.text
        content.imageURL = NSURL(string: "http://45.55.7.118//branches/images/local/dop_logo.png")
        
        FBSDKShareDialog.showFromViewController(self.viewController, withContent: content, delegate: nil)
    }

    func setCouponLike() {
        self.heart.tintColor = Utilities.dopColor
        let totalLikes = (self.likes.text!.toInt())! + 1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon.setUserLike(1, total_likes: totalLikes)
    }

    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGrayColor()
        let totalLikes = (self.likes.text!.toInt())! - 1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon.setUserLike(0, total_likes: totalLikes)
    }

}