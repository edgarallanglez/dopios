//
//  ReadQRHelpViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 11/3/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import Foundation
import UIKit

class ReadQRHelpViewController: UIViewController, ModalDelegate {
    
    @IBOutlet weak var branch_indiference: UISwitch!
    @IBOutlet weak var camera_broken: UISwitch!
    @IBOutlet weak var app_broken: UISwitch!
    @IBOutlet weak var qr_lost: UISwitch!
    
    var some_checked: Bool = false
    var coupon: Coupon!
    var modal_alert: ModalViewController!
    var alert_array = [AlertModel]()
    var problems_switch_array: [UISwitch] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.problems_switch_array = [ branch_indiference,
                                       camera_broken,
                                       app_broken,
                                       qr_lost ]
    }
    
    @IBAction func send_report(_ sender: UIButton) {
        
        var params: [String: AnyObject] = [ "user_id": User.user_id as AnyObject,
                                            "branch_id": coupon.branch_id as AnyObject,
                                            "coupon_id": coupon.id as AnyObject,
                                            "branch_indiference": false as AnyObject,
                                            "camera_broken": false as AnyObject,
                                            "app_broken": false as AnyObject,
                                            "qr_lost":  false as AnyObject ]
        
        for item in problems_switch_array {
            if item.isOn { some_checked = true }
            
            switch item.tag {
            case 0:
                params["branch_indiference"] = item.isOn as AnyObject
            case 1:
                params["camera_broken"] = item.isOn as AnyObject
            case 2:
                params["app_broken"] = item.isOn as AnyObject
            case 3:
                params["qr_lost"] = item.isOn as AnyObject
            default: print("You are out of range")
            }
            
        }
        
        
        if some_checked {
            ReadQRController.sendReport("\(Utilities.dopURL)coupon/report",
                                    params: params,
                                    success: { (data) -> Void in
                                        DispatchQueue.main.async(execute: {
                                            self.triggerAlertSuccess()
                                        })
                                    },
                                    failure: { (error) -> Void in
                                        DispatchQueue.main.async(execute: {
                                            self.triggerAlertError()
                                        })
                                    }
            )
        } else {
            self.triggerWarningAlert()
        }
    }
    
    func triggerAlertError() {
        self.modal_alert = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
        self.modal_alert.willPresentCompletionHandler = { vc in
            let navigation_controller = vc as! AlertModalViewController
            navigation_controller.dismiss_button.setTitle("CERRAR", for: UIControlState())
            
            self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error ☹️"))
            
            navigation_controller.setAlert(self.alert_array)
        }
        self.modal_alert.present(animated: true, completionHandler: nil)
        self.modal_alert.delegate = self
    }
    
    func triggerAlertSuccess() {
        self.modal_alert = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
        self.modal_alert.willPresentCompletionHandler = { vc in
            let navigation_controller = vc as! AlertModalViewController
            navigation_controller.share_view.isHidden = true
            navigation_controller.dismiss_button.setTitle("CERRAR", for: UIControlState())
            
            self.alert_array.append(AlertModel(alert_title: "¡Gracias!", alert_image: "success", alert_description: "Has generado un reporte, revisaremos tu caso a la mayor brevedad posible"))
            
            navigation_controller.setAlert(self.alert_array)
        }
        self.modal_alert.present(animated: true, completionHandler: nil)
        self.modal_alert.delegate = self
    }
    
    func triggerWarningAlert() {
        self.alert_array.removeAll()
        self.modal_alert = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
        self.modal_alert.willPresentCompletionHandler = { vc in
            let navigation_controller = vc as! AlertModalViewController
            navigation_controller.share_view.isHidden = true
            navigation_controller.dismiss_button.setTitle("CERRAR", for: UIControlState())
            
            self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "warning", alert_description: "No has seleccionado algún problema aún"))
            
            navigation_controller.setAlert(self.alert_array)
        }
        self.modal_alert.present(animated: true, completionHandler: nil)
        self.modal_alert.delegate = self
    }
    
    func pressActionButton(_ modal: ModalViewController) {
        modal.didDismissCompletionHandler = { vc in
            if self.some_checked {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
