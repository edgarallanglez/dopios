//
//  CampaignPromo.swift
//  dop
//
//  Created by Edgar Allan Glez on 3/24/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import UIKit

class CampaignPromo: UIView, ModalDelegate, FBSDKSharingDelegate {
    /**
     Sent to the delegate when the share completes without error or cancellation.
     - Parameter sharer: The FBSDKSharing that completed.
     - Parameter results: The results from the sharer.  This may be nil or empty.
     */
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        print(results)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("cancel share")
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        //print(error.description)
    }
    
    
    @IBOutlet weak var company_name: UILabel!
    @IBOutlet var campaign_description: UILabel!
    @IBOutlet weak var company_logo_view: UIView!
    @IBOutlet var logo: UIImageView!
    @IBOutlet weak var expire_date: UILabel!
    
    var view_controller: UIViewController!
    var main_storyboard: UIStoryboard!
    var coupon: Coupon!
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 170, height: 200))
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setCoupon(_ coupon: Coupon, view: UIViewController, x: CGFloat, y: CGFloat){
        self.coupon = coupon
        self.view_controller = view
        self.frame.origin = CGPoint(x: x, y: y)
    }
    
    func loadItem(_ coupon: Coupon, viewController: UIViewController, main_storyboard: UIStoryboard) {

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CampaignPromo.tapCoupon(_:))))
        self.coupon = coupon
        self.campaign_description.text = coupon.couponDescription
        self.expire_date.text = "\(Utilities.friendlyToDate(coupon.end_date!))"
        self.view_controller = viewController
        self.main_storyboard = main_storyboard
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(CampaignPromo.updateLikeAndTaken(_:)),
//            name: NSNotification.Name(rawValue: "takenOrLikeStatus"),
//            object: nil)
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(CampaignPromo.refreshAvailable(_:)),
//            name: NSNotification.Name(rawValue: "updateAvailable"),
//            object: nil)
    }

    
    func tapCoupon(_ sender: UITapGestureRecognizer) {
        let controller_from_main: UIViewController = self.main_storyboard.instantiateInitialViewController()!
        //setViewCount()
        let modal: ModalViewController = ModalViewController(currentView: controller_from_main, type: ModalViewControllerType.CouponDetail)
        
        DispatchQueue.main.async {
            modal.willPresentCompletionHandler = { view_controller in
                let navigationController = view_controller as! SimpleModalViewController
                navigationController.coupon = self.coupon
            }
            
            modal.present(animated: true, completionHandler: nil)
            modal.delegate = self
        }
    }
    
    func pressActionButton(_ modal: ModalViewController) {
        if modal.action_type == "profile" {
            print("Profile delegate modal")
            
            let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            let view_controller = storyboard.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
            //        self.present(controller, animated: true, completion: nil)
            
            
            view_controller.branch_id = coupon.branch_id
            modal.dismiss(animated: true, completionHandler: { (modal) -> Void in
                self.view_controller!.navigationController?.pushViewController(view_controller, animated: true)
            })
        }
        
        if modal.action_type == "redeem" {
            
            if coupon.available > 0 {
                let storyboard =  UIStoryboard(name: "Main", bundle: nil)
                let view_controller  = storyboard.instantiateViewController(withIdentifier: "readQRView") as! ReadQRViewController
                view_controller.coupon_id = self.coupon.id
                view_controller.coupon = self.coupon
                view_controller.branch_id = self.coupon.branch_id
                view_controller.branch_folio = self.coupon.branch_folio
                view_controller.is_global = self.coupon.is_global
                
                print("FOLIO ES \(coupon.branch_folio)")
//                view_controller?.hidesBottomBarWhenPushed = true
                
                modal.dismiss(animated: true, completionHandler:{ (modal) -> Void in
                    self.view_controller!.hidesBottomBarWhenPushed = true
                    self.view_controller!.navigationController?.pushViewController(view_controller, animated: true)
                    self.view_controller!.hidesBottomBarWhenPushed = false
                })
            } else {
                let error_modal: ModalViewController = ModalViewController(currentView: self.view_controller!, type: ModalViewControllerType.AlertModal)
                error_modal.willPresentCompletionHandler = { vc in
                    let navigation_controller = vc as! AlertModalViewController
                    
                    var alert_array = [AlertModel]()
                    
                    alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Esta promoción se ha terminado ☹️"))
                    
                    navigation_controller.setAlert(alert_array)
                }
                
                modal.dismiss(animated: true, completionHandler: { (modal) -> Void in
                    error_modal.present(animated: true, completionHandler: nil)
                    
                })
                
            }
        }
        //}
    }
    
    func share(_ sender: UITapGestureRecognizer) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = URL(string: "http://www.dop.life")
        content.contentTitle = self.coupon.name
        content.imageURL = URL(string: "\(Utilities.dopImagesURL)\(self.coupon.company_id)/\(self.coupon.logo)")
        content.contentDescription = self.coupon.couponDescription
        
        
        let dialog: FBSDKShareDialog = FBSDKShareDialog()
        
        dialog.shareContent = content
        dialog.delegate = nil
        dialog.fromViewController = self.view_controller
        if UIApplication.shared.canOpenURL(URL(string: "fbauth2://")!) {
            dialog.mode = FBSDKShareDialogMode.native
        }else{
            dialog.mode = FBSDKShareDialogMode.browser
        }
        
        dialog.show()
        
    }
}
