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

class PromoCollectionCell: UICollectionViewCell, FBSDKSharingDelegate {
    
    @IBOutlet var coupon_description: UILabel!
    @IBOutlet var branch_banner: UIImageView!
    @IBOutlet var heart: UIImageView!
    @IBOutlet var likes: UILabel!
    @IBOutlet var heartView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var take_coupon_btn: UIButton!
    
    var viewController: UIViewController?
    var coordinate: CLLocationCoordinate2D?
    var coupon_id: Int!
    var coupon:Coupon!
    var branch_id: Int!
    
    func loadItem(coupon:Coupon, viewController: UIViewController) {
        coupon_description.text = coupon.couponDescription
        self.branch_id = coupon.branch_id
        self.coupon_id = coupon.id
        self.shareButton.setBackgroundImage(UIImage(named: "share-icon"), forState: UIControlState.Normal)
        let gesture = UITapGestureRecognizer(target: self, action: "likeCoupon:")
        heartView.addGestureRecognizer(gesture)
        self.coupon = coupon
        self.likes.text = String(coupon.total_likes)
        self.viewController = viewController
        if coupon.user_like == 1 {
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
    
    
    @IBAction func shareCoupon(sender: UIButton) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://www.allan-glez.com/")
        content.contentTitle = coupon.name
        content.contentDescription = self.coupon_description?.text
        content.imageURL = NSURL(string: "\(Utilities.dopImagesURL)\(coupon.company_id)/\(coupon.logo)")
        
        FBSDKShareDialog.showFromViewController(self.viewController, withContent: content, delegate: self)
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print(error.description)
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print(results)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("cancel")
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
    
    @IBAction func take_coupon(sender: UIButton) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let folioDate = dateFormatter.stringFromDate(NSDate())
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let date = dateFormatter.stringFromDate(NSDate())
        
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon_id,
            "branch_id": self.branch_id,
            "taken_date" : date,
            "folio_date": folioDate,
            "latitude": coordinate?.latitude ?? 0,
            "longitude": coordinate?.longitude ?? 0]
        
        
        CouponController.takeCouponWithSuccess(params,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: couponsData)
                    print(json)
                    
                    UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        self.take_coupon_btn.alpha = 0.45
                        }, completion: { (Bool) in
                            UIView.animateWithDuration(0.7, animations: { () -> Void in
                                self.take_coupon_btn.setImage(UIImage(named: "take-coupon"), forState: UIControlState.Normal)
                                self.take_coupon_btn.alpha = 1
                            })
                    })
                })

            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    print(error)
                })
            }
        )
        
        print(date)
    }
//

}