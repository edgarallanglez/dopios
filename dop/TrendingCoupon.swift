//
//  TrendingCoupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 23/09/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TrendingCoupon: UIView, ModalDelegate {
    
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var logo: UIImageView!
    @IBOutlet var likes: UILabel!
    @IBOutlet weak var takeCouponButton: UIButton!
    @IBOutlet weak var takeView: UIView!
    @IBOutlet var heartView: UIView!
    @IBOutlet var heart: UIImageView!
    var viewController: UIViewController?
    var coupon: Coupon!
    
    func loadItem(coupon: Coupon, viewController: UIViewController) {
        heartView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeCoupon:"))
        takeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "setTakeCoupon:"))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapCoupon:"))
        self.coupon = coupon
        
        self.likes.text = String(coupon.total_likes)
        self.descriptionLbl.text = coupon.couponDescription
        self.viewController = viewController
        if coupon.user_like == 1 { self.heart.tintColor = Utilities.dopColor } else { self.heart.tintColor = UIColor.lightGrayColor() }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 230))
    }
    
    func viewDidAppear(){
        print("USER LIKE ES \(coupon.user_like)")
        self.likes.text = String(coupon.total_likes)
        if coupon.user_like == 1 { self.heart.tintColor = Utilities.dopColor } else { self.heart.tintColor = UIColor.lightGrayColor() }
    }
    
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
        self.coupon.setUserLike(1, total_likes: totalLikes)
    }
    
    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGrayColor()
        let total_likes = (Int(self.likes.text!))! - 1
        self.likes.text = String(total_likes)
        self.coupon.setUserLike(0, total_likes: total_likes)
    }
    
    func tapCoupon(sender: UITapGestureRecognizer){
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
    
    func setTakeCoupon(sender: UITapGestureRecognizer) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let folioDate = dateFormatter.stringFromDate(NSDate())
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let date = dateFormatter.stringFromDate(NSDate())
        
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "branch_id": self.coupon.branch_id,
            "taken_date" : date,
            "folio_date": folioDate,
            "latitude": User.coordinate.latitude ?? 0,
            "longitude": User.coordinate.longitude ?? 0 ]
        
        
        CouponController.takeCouponWithSuccess(params,
            success: { (data) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: data)
                    print(json)
                    
                    self.takeCouponButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
                    UIView.animateWithDuration(0.8,
                        delay: 0,
                        usingSpringWithDamping: 0.2,
                        initialSpringVelocity: 6.0,
                        options: UIViewAnimationOptions.AllowUserInteraction,
                        animations: { self.takeCouponButton.transform = CGAffineTransformIdentity }, completion: nil)
                    
                    self.takeCouponButton.tintColor = Utilities.dopColor
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
    
    func setTakeButtonState() {
        self.takeCouponButton.tintColor = Utilities.dopColor
    }

    func pressActionButton(modal: ModalViewController) {
        if modal.action_type == "profile" {
            let view_controller = viewController!.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.coupon = self.coupon
            view_controller.branch_id = coupon.branch_id
            modal.dismissAnimated(true, completionHandler: { (modal) -> Void in
                self.viewController!.navigationController?.pushViewController(view_controller, animated: true)
            })
        }
        
        if modal.action_type == "redeem" {
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
        }
    }
    
}

