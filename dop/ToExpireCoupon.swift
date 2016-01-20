//
//  ToExpireCoupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 01/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class ToExpireCoupon: UIView {

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
    var coupon:Coupon!
    
    init(height:Int, coupon:Coupon, viewController:UIViewController) {
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 230))
        let coupon_gesture = UITapGestureRecognizer(target: self, action: "tapCoupon:")
        self.addGestureRecognizer(coupon_gesture)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func move(x:CGFloat,y:CGFloat){
        self.frame.origin = CGPointMake(x,y)
    }
    func tapCoupon(sender:UITapGestureRecognizer){

        /*let modal:ModalViewController = ModalViewController(currentView: self.viewController!, type: ModalViewControllerType.CouponDetail)
        
        dispatch_async(dispatch_get_main_queue()) {
            
            modal.willPresentCompletionHandler = { vc in
                let navigationController = vc as! SimpleModalViewController
                /*navigationController.title_label.text = self.coupon.name
                navigationController.title_label.text = navigationController.title_label.text?.uppercaseString
                navigationController.category_label.text = "Cafeteria"
                navigationController.category_label.text = navigationController.category_label.text?.uppercaseString*/
                //navigationController.coupon = self.coupon
                
            }
            modal.presentAnimated(true, completionHandler: nil)
            
        }*/
    }

}
