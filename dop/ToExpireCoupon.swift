//
//  ToExpireCoupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 01/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ToExpireCoupon: UIView, ModalDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var branch_logo_view: UIView!
    @IBOutlet weak var branch_logo: UIImageView!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var branchNameLbl: UILabel!
    @IBOutlet weak var expire_date: UILabel!
    
    var viewController: UIViewController?
    var coupon: Coupon!
    
    init(height:Int, coupon: Coupon, viewController: UIViewController) {
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 230))
    }
    
    func loadItem(_ coupon: Coupon, viewController: UIViewController) {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ToExpireCoupon.tapCoupon(_:))))
        
        self.coupon = coupon
        self.descriptionLbl.text = coupon.name
        self.branchNameLbl.text = coupon.couponDescription
        self.expire_date.text = "\(Utilities.friendlyToDate(coupon.end_date!))"
        self.viewController = viewController
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ToExpireCoupon.updateLikeAndTaken(_:)),
            name: NSNotification.Name(rawValue: "takenOrLikeStatus"),
            object: nil)
        
        Alamofire.request("\(Utilities.dopImagesURL)\(self.coupon.company_id)/\(self.coupon.logo)").responseImage { response in
            if let image = response.result.value {
                
                self.branch_logo.image = image
                self.branch_logo.alpha = 1
            
                let container_layer: CALayer = CALayer()
                container_layer.shadowColor = UIColor.lightGray.cgColor
                container_layer.shadowRadius = 1
                container_layer.shadowOffset = CGSize(width: 1.2, height: 1.2)
                container_layer.shadowOpacity = 1
                container_layer.contentsScale = 2.0
                container_layer.addSublayer(self.branch_logo.layer)
                
                self.branch_logo_view.layer.addSublayer(container_layer)
                self.branch_logo_view.layer.contentsScale = 2.0
                self.branch_logo_view.layer.rasterizationScale = 12.0
                self.branch_logo_view.layer.shouldRasterize = true

            } else { print("HUEHUE") }
        }

        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func move(_ x: CGFloat, y: CGFloat){
        self.frame.origin = CGPoint(x: x,y: y)
    }

    func tapCoupon(_ sender: UITapGestureRecognizer){
        setViewCount()
        
        let modal: ModalViewController = ModalViewController(currentView: self.viewController!, type: ModalViewControllerType.CouponDetail)
        
        DispatchQueue.main.async {
            modal.willPresentCompletionHandler = { vc in
                let navigationController = vc as! SimpleModalViewController
                navigationController.coupon = self.coupon
            }
            modal.present(animated: true, completionHandler: nil)
            modal.delegate = self
        }
    }
    
    func pressActionButton(_ modal: ModalViewController) {
        if modal.action_type == "profile" {
            let view_controller = viewController!.storyboard!.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.coupon = self.coupon
            view_controller.branch_id = coupon.owner_id
            viewController!.navigationController?.pushViewController(view_controller, animated: true)
            viewController?.hidesBottomBarWhenPushed = false
            modal.dismiss(animated: true, completionHandler: nil)
        }
        
        if modal.action_type == "redeem" {
            if coupon.available>0{
                let view_controller  = viewController!.storyboard!.instantiateViewController(withIdentifier: "readQRView") as! ReadQRViewController
                view_controller.coupon_id = self.coupon.id
                view_controller.coupon = self.coupon
                view_controller.branch_id = self.coupon.owner_id
                view_controller.branch_folio = self.coupon.branch_folio
                
                viewController?.hidesBottomBarWhenPushed = true
                
                modal.dismiss(animated: true, completionHandler:{ (modal) -> Void in
                    self.viewController!.hidesBottomBarWhenPushed = true
                    self.viewController!.navigationController?.pushViewController(view_controller, animated: true)
                    self.viewController!.hidesBottomBarWhenPushed = false
                })
            } else {
                let error_modal: ModalViewController = ModalViewController(currentView: self.viewController!, type: ModalViewControllerType.AlertModal)
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
    }
    
    func setViewCount() {
        let params: [String: AnyObject] = ["coupon_id": self.coupon.id as AnyObject, "latitude": User.coordinate.latitude as AnyObject, "longitude": User.coordinate.longitude as AnyObject]
        CouponController.viewCouponWithSuccess(params, success: { (data) -> Void in
            let json: JSON = JSON(data)
            },
            failure: { (data) -> Void in
                print("couponsData")
            }
        )
    }
    
    func updateLikeAndTaken(_ notification:Foundation.Notification){
        let object = notification.object as! [String: AnyObject]
        
        let type = object["type"] as! String
        let status = object["status"] as! Bool
        let coupon_id = object["coupon_id"] as! Int
        
        if coupon_id == self.coupon.id {
            if !status {
                if type == "take" { self.coupon.taken = false }
                else { self.coupon.user_like = false }
            } else {
                if type == "take" { self.coupon.taken = true }
                else { self.coupon.user_like = true }
            }
        }
    }

    

}
