//
//  TrendingCoupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 23/09/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TrendingCoupon: UIView, ModalDelegate, FBSDKSharingDelegate {
    
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var logo: UIImageView!
    @IBOutlet var shareView: UIView!
    @IBOutlet var likes: UILabel!
    @IBOutlet weak var takeCouponButton: UIButton!
    @IBOutlet weak var takeView: UIView!
    @IBOutlet var heartView: UIView!
    @IBOutlet var heart: UIImageView!

    var viewController: UIViewController?
    var coupon: Coupon!
    
    func loadItem(coupon: Coupon, viewController: UIViewController) {
        heartView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TrendingCoupon.likeCoupon(_:))))
        takeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TrendingCoupon.setTakeCoupon(_:))))
        shareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TrendingCoupon.share(_:))))

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TrendingCoupon.tapCoupon(_:))))
        self.coupon = coupon
        
        self.likes.text = String(coupon.total_likes)
        self.descriptionLbl.text = coupon.couponDescription
        self.viewController = viewController
        if coupon.user_like == true { self.heart.tintColor = Utilities.dopColor } else { self.heart.tintColor = UIColor.lightGrayColor() }
        if coupon.taken == true { self.takeCouponButton.tintColor = Utilities.dopColor } else { self.takeCouponButton.tintColor = UIColor.darkGrayColor() }
        
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(TrendingCoupon.updateLikeAndTaken(_:)),
            name: "takenOrLikeStatus",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(TrendingCoupon.refreshAvailable(_:)),
            name: "updateAvailable",
            object: nil)
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 230))
    }
    
/*    func viewDidAppear(){
        self.likes.text = String(coupon.total_likes)
        if coupon.user_like == 1 { self.heart.tintColor = Utilities.dopColor } else { self.heart.tintColor = UIColor.lightGrayColor() }
    }*/
    
    func likeCoupon(sender: UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "coupon_id" : coupon.id,
            "date" : "2015-01-01" ]
        
        var liked: Bool
        
        if self.heart.tintColor == UIColor.lightGrayColor() {
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
                    if liked { self.removeCouponLike() }
                    else { self.setCouponLike() }
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
        self.coupon.setUserLike(true, total_likes: totalLikes)
    }
    
    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGrayColor()
        let total_likes = (Int(self.likes.text!))! - 1
        self.likes.text = String(total_likes)
        self.coupon.setUserLike(false, total_likes: total_likes)
        
    }
    
    func tapCoupon(sender: UITapGestureRecognizer){
        
        setViewCount()
        let modal: ModalViewController = ModalViewController(currentView: self.viewController!, type: ModalViewControllerType.CouponDetail)
        
        dispatch_async(dispatch_get_main_queue()) {
            modal.willPresentCompletionHandler = { vc in
                let navigationController = vc as! SimpleModalViewController
                navigationController.coupon = self.coupon
            }
           
            modal.presentAnimated(true, completionHandler: nil)
            modal.delegate = self
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setCoupon(coupon:Coupon, view: UIViewController, x: CGFloat, y: CGFloat){
        self.coupon = coupon
        self.viewController = view
        self.frame.origin = CGPointMake(x,y)
    }
    func setCouponTaken() {
        self.takeCouponButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.takeCouponButton.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        self.takeCouponButton.tintColor = Utilities.dopColor
        self.coupon.taken = true
        self.coupon.available -= 1
        
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "status": true,
            "type": "take"]
        NSNotificationCenter.defaultCenter().postNotificationName("takenOrLikeStatus", object: params)
        self.coupon.setTakenCoupons(true, available: self.coupon.available)

    }
    
    func removeCouponTaken() {
        self.takeCouponButton.tintColor = UIColor.darkGrayColor()
        self.coupon.taken = false
        self.coupon.available += 1
        
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "status": false,
            "type": "take"]
        NSNotificationCenter.defaultCenter().postNotificationName("takenOrLikeStatus", object: params)
        self.coupon.setTakenCoupons(false, available: self.coupon.available)

    }
    func setCouponTakenNotification() {
        self.takeCouponButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.8,
                                   delay: 0,
                                   usingSpringWithDamping: 0.2,
                                   initialSpringVelocity: 6.0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    self.takeCouponButton.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        self.takeCouponButton.tintColor = Utilities.dopColor
        self.coupon.taken = true
        
        print("Total es \(self.coupon.available)")
    }
    
    func removeCouponTakenNotification() {
        self.takeCouponButton.tintColor = UIColor.darkGrayColor()
        self.coupon.taken = false
        
        print("Total es \(self.coupon.available)")
    }
    
    func setTakeCoupon(sender: UITapGestureRecognizer) {
        
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "branch_id": self.coupon.branch_id,
            "latitude": User.coordinate.latitude ?? 0,
            "longitude": User.coordinate.longitude ?? 0 ]
        
        var taken: Bool
        
        
        if self.takeCouponButton.tintColor == UIColor.darkGrayColor() {
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
                    self.coupon.available = json["total"].int!

                    if(json["message"].string=="agotado"){
                        self.takeCouponButton.hidden = true
                        self.removeCouponTaken()
                    
                    }
                    
                    
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
    
    func setTakeButtonState() {
        self.takeCouponButton.tintColor = Utilities.dopColor
    }

    func pressActionButton(modal: ModalViewController) {
        if modal.action_type == "profile" {
            let view_controller = viewController!.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.coupon = self.coupon
            //view_controller.branch.adults_only = coupon.adult_branch
            view_controller.branch_id = coupon.branch_id
            modal.dismissAnimated(true, completionHandler: { (modal) -> Void in
                self.viewController!.navigationController?.pushViewController(view_controller, animated: true)
            })
        }
        
        if modal.action_type == "redeem" {
            
            if coupon.available>0{
                let view_controller  = viewController!.storyboard!.instantiateViewControllerWithIdentifier("readQRView") as! readQRViewController
                view_controller.coupon_id = self.coupon.id
                view_controller.coupon = self.coupon
                view_controller.branch_id = self.coupon.branch_id
                
                viewController?.hidesBottomBarWhenPushed = true

                modal.dismissAnimated(true, completionHandler:{ (modal) -> Void in
                    self.viewController!.hidesBottomBarWhenPushed = true
                    self.viewController!.navigationController?.pushViewController(view_controller, animated: true)
                    self.viewController!.hidesBottomBarWhenPushed = false
                })
            }else{
                let error_modal: ModalViewController = ModalViewController(currentView: self.viewController!, type: ModalViewControllerType.AlertModal)
                error_modal.willPresentCompletionHandler = { vc in
                        let navigation_controller = vc as! AlertModalViewController
                        
                        var alert_array = [AlertModel]()
                        
                        alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Esta promoción se ha terminado :("))
                        
                        navigation_controller.setAlert(alert_array)
                    }

                modal.dismissAnimated(true, completionHandler: { (modal) -> Void in
                    error_modal.presentAnimated(true, completionHandler: nil)

                })

            }
        }
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
    
    func setViewCount() {
        let params: [String: AnyObject] = ["coupon_id": self.coupon.id]
        CouponController.viewCouponWithSuccess(params, success: { (couponsData) -> Void in
            let json: JSON = JSON(couponsData)
            print(json)
            },
            failure: { (couponsData) -> Void in
                print("couponsData")
            }
        )
    }
    func refreshAvailable(notification:NSNotification){
        print("Available refresh!")
        let object = notification.object as! Int
        
        self.coupon.available = object;
        
    }
    
    func share(sender: UITapGestureRecognizer) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://www.inmoon.io")
        content.contentTitle = self.coupon.name
        content.imageURL = NSURL(string: "\(Utilities.dopImagesURL)\(self.coupon.company_id)/\(self.coupon.logo)")
        content.contentDescription = self.coupon.couponDescription
        
        
        let dialog: FBSDKShareDialog = FBSDKShareDialog()
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "fbauth2://")!) {
            dialog.mode = FBSDKShareDialogMode.FeedWeb
        }else{
            dialog.mode = FBSDKShareDialogMode.FeedWeb
        }
        dialog.shareContent = content
        dialog.delegate = self
        dialog.fromViewController = self.viewController
        dialog.show()
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
    
}

