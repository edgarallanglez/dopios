//
//  Nearest.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 08/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NearestCoupon: UIView, ModalDelegate {

    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var branchNameLbl: UILabel!
    
    var viewController: UIViewController?
    var coupon: Coupon!
    
    init(height:Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 230))
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func loadItem(coupon: Coupon, viewController: UIViewController) {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapCoupon:"))
        self.coupon = coupon
        self.descriptionLbl.text = coupon.couponDescription
        self.viewController = viewController
    }
    
    func tapCoupon(sender:UITapGestureRecognizer){
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
    
    func move(x: CGFloat, y: CGFloat){
        self.frame.origin = CGPointMake(x, y)
    }

    func pressActionButton(modal: ModalViewController) {
        if modal.action_type == "profile" {
            let view_controller = viewController!.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.coupon = self.coupon
            view_controller.branch_id = coupon.branch_id
            viewController!.navigationController?.pushViewController(view_controller, animated: true)
            viewController?.hidesBottomBarWhenPushed = false
            modal.dismissAnimated(true, completionHandler: nil)
        }
        
        if modal.action_type == "redeem" {
            let view_controller  = viewController!.storyboard!.instantiateViewControllerWithIdentifier("readQRView") as! readQRViewController
            view_controller.coupon_id = self.coupon.id
            view_controller.branch_id = self.coupon.branch_id
            viewController?.hidesBottomBarWhenPushed = true
            viewController!.navigationController?.pushViewController(view_controller, animated: true)
            viewController?.hidesBottomBarWhenPushed = false
            modal.dismissAnimated(true, completionHandler: nil)
        }
    }
}
