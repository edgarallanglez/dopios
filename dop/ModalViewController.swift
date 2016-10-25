//
//  ModalViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 28/12/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
enum ModalViewControllerType: String {
    case Share
    case CouponDetail
    case AlertModal
}

@objc protocol ModalDelegate {
    func pressActionButton(_ modal: ModalViewController)
}

class ModalViewController: MZFormSheetController {
    var delegate: ModalDelegate?
    var type: ModalViewControllerType?
    var simple_modal : SimpleModalViewController?
    var parent_view: UIViewController!
    var action_type: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let simple_modal:UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("SimpleModal"))!
        //ModalViewController(viewController: simple_modal)
        /*MZFormSheetBackgroundWindow.appearance().backgroundBlurEffect = true
        MZFormSheetBackgroundWindow.appearance().blurRadius = 1.0
        MZFormSheetBackgroundWindow.appearance().backgroundColor = UIColor.clearColor()
        
        MZFormSheetController.sharedBackgroundWindow().backgroundBlurEffect = true
        MZFormSheetController.sharedBackgroundWindow().blurRadius = 1.0
        MZFormSheetController.sharedBackgroundWindow().backgroundColor = UIColor.clearColor()*/
        self.shouldDismissOnBackgroundViewTap = false
        self.cornerRadius = 8.0
        self.transitionStyle = MZFormSheetTransitionStyle.easeFromBottom
        self.portraitTopInset = 40.0
        self.landscapeTopInset = 6.0
        
        self.willPresentCompletionHandler = { simple_modal in
        }
        
    }
    
    init(currentView presentedFormSheetViewController: UIViewController, type: ModalViewControllerType) {
        self.type = type
        self.parent_view = presentedFormSheetViewController
        var simple_modal : SimpleModalViewController!
        var alert_modal: AlertModalViewController!
        
        switch type {
            case .Share: simple_modal = presentedFormSheetViewController.storyboard?.instantiateViewController(withIdentifier: "ShareModal") as? SimpleModalViewController
                super.init(viewController: simple_modal!)
            
                let width = UIScreen.main.bounds.width - 50
                self.presentedFormSheetSize = CGSize(width: width, height: 330)
                simple_modal!.title_label.text = "Compartir"
                simple_modal!.action_button.titleLabel!.text = "Compartir"
                simple_modal!.share_text.contentInset = UIEdgeInsetsMake(0,-5,0,0)
                simple_modal!.twitter_button.addTarget(self, action: #selector(ModalViewController.tintButton(_:)), for: .touchUpInside)
                simple_modal!.facebook_button.addTarget(self, action: #selector(ModalViewController.tintButton(_:)), for: .touchUpInside)
                simple_modal!.instagram_button.addTarget(self, action: #selector(ModalViewController.tintButton(_:)), for: .touchUpInside)
            
            case .CouponDetail: simple_modal = presentedFormSheetViewController.storyboard?.instantiateViewController(withIdentifier: "CouponDetailModal") as? SimpleModalViewController
                super.init(viewController: simple_modal!)
            var height: CGFloat = CGFloat(0)
                if UIScreen.main.bounds.width == 320 {
                    simple_modal.setLittleSize()
                    height = (UIScreen.main.bounds.height / 3) * 2.4
                } else { height = (UIScreen.main.bounds.height / 3) * 2.16 }
                let width = UIScreen.main.bounds.width - 30
                
                self.presentedFormSheetSize = CGSize(width: width, height: height)
                simple_modal.branch_title.addTarget(self, action: #selector(ModalViewController.toBranch), for: .touchUpInside)
                
                let gesture = UITapGestureRecognizer(target: self, action: #selector(ModalViewController.likeCoupon(_:)))
                simple_modal.heartView.addGestureRecognizer(gesture)

            
            case .AlertModal: alert_modal = presentedFormSheetViewController.storyboard?.instantiateViewController(withIdentifier: "AlertModal") as? AlertModalViewController
                super.init(viewController: alert_modal!)
            
                let width = UIScreen.main.bounds.width - 60
                let height = (UIScreen.main.bounds.height / 3) * 2
                self.presentedFormSheetSize = CGSize(width: width, height: height)
            
        default: super.init(viewController: simple_modal!)
        }

        if simple_modal?.action_button != nil { simple_modal!.action_button.addTarget(self, action: #selector(ModalViewController.pressed(_:)), for: .touchUpInside) }
        if alert_modal?.dismiss_button != nil { alert_modal!.dismiss_button.addTarget(self, action: #selector(ModalViewController.pressed(_:)), for: .touchUpInside) }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle:nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pressed(_ sender: UIButton!) {
        self.action_type = "redeem"
        self.delegate?.pressActionButton(self)
    }
    
    func toBranch() {
        self.action_type = "profile"
        self.delegate?.pressActionButton(self)
    }
    
    func tintButton(_ sender: UIButton!) {
        if (sender.isSelected) {
            sender.isSelected = false
            sender.tintColor = UIColor.lightGray
        } else {
            sender.isSelected = true
            sender.tintColor = Utilities.dopColor
        }
    }
    
    func likeCoupon(_ sender: UITapGestureRecognizer){
        /*let params:[String: AnyObject] = [
            "coupon_id" : String(stringInterpolationSegment: simple_modal!.coupon!.id),
            "date" : "2015-01-01"]
        
        var liked: Bool
        
        if (simple_modal?.heart.tintColor == UIColor.lightGrayColor()) {
            self.simple_modal?.setCouponLike()
            liked = true
        } else {
            self.simple_modal?.removeCouponLike()
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
                        self.simple_modal?.removeCouponLike()
                    }else{
                        self.simple_modal?.setCouponLike()
                    }
                })
        })*/
    }
    
}
