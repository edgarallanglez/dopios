//
//  PromoCollectionCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Social
import FBSDKLoginKit
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
        //self.shareButton.setBackgroundImage(UIImage(named: "share-icon"), forState: UIControlState.Normal)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PromoCollectionCell.likeCoupon(_:)))
        heartView.addGestureRecognizer(gesture)
        self.coupon = coupon
        self.likes.text = String(coupon.total_likes)
        self.viewController = viewController
        if coupon.user_like == true {
            self.heart.tintColor = Utilities.dopColor
        } else {
            self.heart.tintColor = UIColor.lightGrayColor()
        }

        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(PromoCollectionCell.updateLikeAndTaken(_:)),
            name: "takenOrLikeStatus",
            object: nil)
    }
    @IBAction func share(sender: AnyObject) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "https://www.halleydevs.io")
        content.contentTitle = self.coupon.name
        content.imageURL = NSURL(string: "\(Utilities.dopImagesURL)\(self.coupon.company_id)/\(self.coupon.logo)")
        content.contentDescription = self.coupon_description?.text
        FBSDKShareDialog.showFromViewController(self.viewController, withContent: content, delegate: self)
        
        
        /*let dialog: FBSDKShareDialog = FBSDKShareDialog()
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "fbauth2://")!) {
            dialog.mode = FBSDKShareDialogMode.Native
        }else{
            dialog.mode = FBSDKShareDialogMode.Native
        }
        dialog.shareContent = content
        dialog.delegate = self
        dialog.fromViewController = self.viewController
        dialog.show()*/
        
    }
    
    
    func likeCoupon(sender: UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "coupon_id" : String(stringInterpolationSegment: coupon.id),
            "date" : "2015-01-01"]
        
        var liked: Bool
        
        if  self.heart.tintColor == UIColor.lightGrayColor() {
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
        content.contentURL = NSURL(string: "https://www.inmoon.com.mx")
        content.contentTitle = self.coupon.name
        content.contentDescription = self.coupon_description?.text
        content.imageURL = NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Facebook_Headquarters_Menlo_Park.jpg/2880px-Facebook_Headquarters_Menlo_Park.jpg") //NSURL(string: "\(Utilities.dopImagesURL)\(self.coupon.company_id)/\(self.coupon.logo)")
        
                let dialog: FBSDKShareDialog = FBSDKShareDialog()
        //        dialog.mode = FBSDKShareDialogModeShareSheet
        dialog.mode = FBSDKShareDialogMode.Browser
        FBSDKShareDialog.showFromViewController(self.viewController, withContent: content, delegate: self)
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print(error.description)
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print(results)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("cancel share")
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
        self.coupon.setUserLike(true, total_likes: totalLikes)

    }

    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGrayColor()
        let totalLikes = (Int(self.likes.text!))! - 1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon.setUserLike(false, total_likes: totalLikes)
        
    }
    
    func setCouponTaken() {
        self.take_coupon_btn.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.take_coupon_btn.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        self.take_coupon_btn.tintColor = Utilities.dopColor
        self.coupon.taken = true
        //self.coupon.setTakenCoupons(true, available: self.coupon.available-1)
        self.coupon.available -= 1
        
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "status": true,
            "type": "take"]
        NSNotificationCenter.defaultCenter().postNotificationName("takenOrLikeStatus", object: params)
    }
    
    func removeCouponTaken() {
        self.take_coupon_btn.tintColor = UIColor.darkGrayColor()
        self.coupon.taken = false
        //self.coupon.setTakenCoupons(false, available: self.coupon.available+1)
        self.coupon.available += 1
        
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "status": false,
            "type": "take"]
        NSNotificationCenter.defaultCenter().postNotificationName("takenOrLikeStatus", object: params)
    }
    
    func setCouponTakenNotification() {
        self.take_coupon_btn.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.8,
                                   delay: 0,
                                   usingSpringWithDamping: 0.2,
                                   initialSpringVelocity: 6.0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    self.take_coupon_btn.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        self.take_coupon_btn.tintColor = Utilities.dopColor
        self.coupon.taken = true
    }
    
    func removeCouponTakenNotification() {
        self.take_coupon_btn.tintColor = UIColor.darkGrayColor()
        self.coupon.taken = false
    }
    
    @IBAction func setTakeCoupon(sender: UIButton) {
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "branch_id": self.coupon.branch_id,
            "latitude": User.coordinate.latitude ?? 0,
            "longitude": User.coordinate.longitude ?? 0 ]
        
        var taken: Bool
        
        
        if self.take_coupon_btn.tintColor == UIColor.darkGrayColor() {
            self.setCouponTaken()
            taken = true
        } else {
            self.removeCouponTaken()
            taken = false
        }
        
        
        CouponController.takeCouponWithSuccess(params,
            success: { (data) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: data)
                    print(json)
                    
                })
                
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if taken { self.removeCouponTaken() }
                    else { self.setCouponTaken() }
                })
            }
        )

    }
    
    func setTakeButtonState(state: Bool) {
        if state { self.take_coupon_btn.tintColor = Utilities.dopColor }
        else { self.take_coupon_btn.tintColor = UIColor.darkGrayColor() }
    }
    
    func updateLikeAndTaken(notification:NSNotification){
        
        let object = notification.object as! [String: AnyObject]
        
        let type = object["type"] as! String
        let status = object["status"] as! Bool
        let coupon_id = object["coupon_id"] as! Int
        
        if(coupon_id == self.coupon.id){
            if(status == false){
                if(type == "take"){
                    self.removeCouponTakenNotification()
                }else{
                    self.removeCouponLike()
                }
            }else{
                if(type == "take"){
                    self.setCouponTakenNotification()
                }else{
                    self.setCouponLike()
                }
            }
        }
    }
    func refreshAvailable(notification:NSNotification){
        print("Available refresh!")
        let object = notification.object as! Int
        
        self.coupon.available = object;
        
    }
    
   

}
