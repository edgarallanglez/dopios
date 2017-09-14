//
//  LoyaltyReward.swift
//  dop
//
//  Created by Edgar Allan Glez on 3/24/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import UIKit

class LoyaltyReward: UIView, ModalDelegate {
    
    @IBOutlet weak var loyalty_logo: UIImageView!
    @IBOutlet weak var loyalty_progress: UILabel!
    @IBOutlet weak var empty_bait: UILabel!
    
    var view_controller: UIViewController!
    var current_storyboard: UIStoryboard!
    var loyalty: Loyalty!
    
    func setLoyaltyBox(_ loyalty: Loyalty, view_controller: UIViewController, storyboard: UIStoryboard) {
        self.view_controller = view_controller
        self.current_storyboard = storyboard
        self.loyalty = loyalty
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoyaltyReward.triggerModal(_:))))
    }
    
    func triggerModal(_ sender: UITapGestureRecognizer) {
        let controller_from_main: UIViewController = self.current_storyboard.instantiateInitialViewController()!
        setViewCount()
        
        let modal_storyboard = UIStoryboard(name: "ModalStoryboard", bundle: nil)
        let view_controller = modal_storyboard.instantiateInitialViewController()!
        let modal: ModalViewController = ModalViewController(currentView: view_controller, type: ModalViewControllerType.LoyaltyModal)
        
        DispatchQueue.main.async {
            modal.willPresentCompletionHandler = { view_controller in
                let navigationController = view_controller as! LoyaltyModalViewController
                navigationController.loyalty = self.loyalty
            }
            
            modal.present(animated: true, completionHandler: nil)
            modal.delegate = self
        }


    }
    
    func pressActionButton(_ modal: ModalViewController) {
        if modal.action_type == "redeem" {
            var available = true
            if available {
                let storyboard =  UIStoryboard(name: "Main", bundle: nil)
                let view_controller  = storyboard.instantiateViewController(withIdentifier: "readQRView") as! ReadQRViewController
                view_controller.coupon_id = self.loyalty.loyalty_id
                view_controller.loyalty = self.loyalty
                view_controller.branch_id = self.loyalty.owner_id
                view_controller.branch_folio = " "
                view_controller.is_global = self.loyalty.is_global!
                
                // view_controller?.hidesBottomBarWhenPushed = true
                
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

    }
    
    func setViewCount() {
        let params: [String: AnyObject] = [ "loyalty_id": self.loyalty.loyalty_id as AnyObject,
                                            "latitude": User.coordinate.latitude as AnyObject,
                                            "longitude": User.coordinate.longitude as AnyObject ]
        
        CouponController.viewLoyaltyWithSuccess(params,
                                                success: { (data) -> Void in
                                                    //let json: JSON = JSON(data!)
                                                    print("👍")
        },
                                                failure: { (data) -> Void in
                                                    print("👎")
        }
        )
    }
}
