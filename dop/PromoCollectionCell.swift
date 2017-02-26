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
    /*!
     @abstract Sent to the delegate when the sharer encounters an error.
     @param sharer The FBSDKSharing that completed.
     @param error The error.
     */


    
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
    var coupon: Coupon!
    var branch_id: Int!
    
    func loadItem(_ coupon:Coupon, viewController: UIViewController) {
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
            self.heart.tintColor = UIColor.lightGray
        }

        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(PromoCollectionCell.updateLikeAndTaken(_:)),
            name: NSNotification.Name(rawValue: "takenOrLikeStatus"),
            object: nil)
    }
    @IBAction func share(_ sender: AnyObject) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = URL(string: "http://www.dop.life")
        content.contentTitle = self.coupon.name
        content.imageURL = URL(string: "\(Utilities.dopImagesURL)\(self.coupon.company_id)/\(self.coupon.logo)")
        content.contentDescription = self.coupon_description?.text
        
        //FBSDKShareDialog.showFromViewController(viewController, withContent: content, delegate: self)
        
        
        let dialog: FBSDKShareDialog = FBSDKShareDialog()
        
        if UIApplication.shared.canOpenURL(URL(string: "fbauth2://")!) {
            dialog.mode = FBSDKShareDialogMode.native
        }else{
            dialog.mode = FBSDKShareDialogMode.feedWeb
        }
        dialog.shareContent = content
        dialog.delegate = self
        dialog.fromViewController = self.viewController
        dialog.show()
    }
    
    
    func likeCoupon(_ sender: UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "coupon_id" : String(stringInterpolationSegment: coupon.id) as AnyObject,
            "date" : "2015-01-01" as AnyObject]
        
        var liked: Bool
        
        if  self.heart.tintColor == UIColor.lightGray {
            self.setCouponLike()
            liked = true
        } else {
            self.removeCouponLike()
            liked = false
        }
    
        CouponController.likeCouponWithSuccess(params,
            success: { (couponsData) -> Void in
                DispatchQueue.main.async(execute: {
                    let json = couponsData!
                    print(json)
                })
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    if(liked == true){
                        self.removeCouponLike()
                    }else{
                        self.setCouponLike()
                    }
                })
            })
    }
    
    @IBAction func shareCoupon(_ sender: UIButton) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = URL(string: "https://www.inmoon.com.mx")
        content.contentTitle = self.coupon.name
        content.contentDescription = self.coupon_description?.text
        content.imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Facebook_Headquarters_Menlo_Park.jpg/2880px-Facebook_Headquarters_Menlo_Park.jpg") //NSURL(string: "\(Utilities.dopImagesURL)\(self.coupon.company_id)/\(self.coupon.logo)")
        
                let dialog: FBSDKShareDialog = FBSDKShareDialog()
        //        dialog.mode = FBSDKShareDialogModeShareSheet
        dialog.mode = FBSDKShareDialogMode.browser
        FBSDKShareDialog.show(from: self.viewController, with: content, delegate: self)
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        //print(error.description)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        print(results)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("cancel share")
    }

    func setCouponLike() {
        heart.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
                self.heart.transform = CGAffineTransform.identity
        }, completion: nil)
        
        self.heart.tintColor = Utilities.dopColor
        let totalLikes = (Int(self.likes.text!))! + 1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon.setUserLike(true, total_likes: totalLikes)

    }

    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGray
        let totalLikes = (Int(self.likes.text!))! - 1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon.setUserLike(false, total_likes: totalLikes)
        
    }
    
    func setCouponTaken() {
        self.take_coupon_btn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
                self.take_coupon_btn.transform = CGAffineTransform.identity
            }, completion: nil)
        
        self.take_coupon_btn.tintColor = Utilities.dopColor
        self.coupon.taken = true
        //self.coupon.setTakenCoupons(true, available: self.coupon.available-1)
        self.coupon.available -= 1
        
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id as AnyObject,
            "status": true as AnyObject,
            "type": "take" as AnyObject]
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "takenOrLikeStatus"), object: params)
    }
    
    func removeCouponTaken() {
        self.take_coupon_btn.tintColor = UIColor.darkGray
        self.coupon.taken = false
        //self.coupon.setTakenCoupons(false, available: self.coupon.available+1)
        self.coupon.available += 1
        
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id as AnyObject,
            "status": false as AnyObject,
            "type": "take" as AnyObject]
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "takenOrLikeStatus"), object: params)
    }
    
    func setCouponTakenNotification() {
        self.take_coupon_btn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.8,
                                   delay: 0,
                                   usingSpringWithDamping: 0.2,
                                   initialSpringVelocity: 6.0,
                                   options: UIViewAnimationOptions.allowUserInteraction,
                                   animations: {
                                    self.take_coupon_btn.transform = CGAffineTransform.identity
            }, completion: nil)
        
        self.take_coupon_btn.tintColor = Utilities.dopColor
        self.coupon.taken = true
    }
    
    func removeCouponTakenNotification() {
        self.take_coupon_btn.tintColor = UIColor.darkGray
        self.coupon.taken = false
    }
    
    @IBAction func setTakeCoupon(_ sender: UIButton) {
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id as AnyObject,
            "branch_id": self.coupon.branch_id as AnyObject,
            "latitude": User.coordinate.latitude as AnyObject? ?? 0 as AnyObject,
            "longitude": User.coordinate.longitude as AnyObject? ?? 0 as AnyObject ]
        
        var taken: Bool
        
        
        if self.take_coupon_btn.tintColor == UIColor.darkGray {
            self.setCouponTaken()
            taken = true
        } else {
            self.removeCouponTaken()
            taken = false
        }
        
        
        CouponController.takeCouponWithSuccess(params,
            success: { (data) -> Void in
                DispatchQueue.main.async(execute: {
                    let json = data!
                    print(json)
                    
                })
                
            },
            
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    if taken { self.removeCouponTaken() }
                    else { self.setCouponTaken() }
                })
            }
        )

    }
    
    func setTakeButtonState(_ state: Bool) {
        if state { self.take_coupon_btn.tintColor = Utilities.dopColor }
        else { self.take_coupon_btn.tintColor = UIColor.darkGray }
    }
    
    func updateLikeAndTaken(_ notification:Foundation.Notification){
        
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
    func refreshAvailable(_ notification:Foundation.Notification){
        print("Available refresh!")
        let object = notification.object as! Int
        
        self.coupon.available = object;
        
    }
    
   

}
