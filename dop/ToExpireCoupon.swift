//
//  ToExpireCoupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 01/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class ToExpireCoupon: UIView, ModalDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var branchNameLbl: UILabel!
    var viewController: UIViewController?
    var coupon: Coupon!
    
    init(height:Int, coupon: Coupon, viewController: UIViewController) {
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 230))
    }
    
    func loadItem(coupon: Coupon, viewController: UIViewController) {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ToExpireCoupon.tapCoupon(_:))))
        
        self.coupon = coupon
        self.descriptionLbl.text = coupon.couponDescription
        self.viewController = viewController
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(ToExpireCoupon.updateLikeAndTaken(_:)),
            name: "takenOrLikeStatus",
            object: nil)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func move(x: CGFloat, y: CGFloat){
        self.frame.origin = CGPointMake(x,y)
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
    
    func updateLikeAndTaken(notification:NSNotification){
        
        let object = notification.object as! [String: AnyObject]
        
        let type = object["type"] as! String
        let status = object["status"] as! Bool
        let coupon_id = object["coupon_id"] as! Int
        
        
        if(coupon_id == self.coupon.id){
            if(status == false){
                if(type == "take"){
                    self.coupon.taken = false
                }else{
                    self.coupon.user_like = 0
                }
            }else{
                if(type == "take"){
                    self.coupon.taken = true
                }else{
                    self.coupon.user_like = 1
                }
            }
        }
    }

    

}
