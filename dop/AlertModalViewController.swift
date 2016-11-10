//
//  AlertModalViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 2/9/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol AlertDelegate {
    func pressAlertButton(_ modal: AlertModalViewController)
}

class AlertModalViewController: UIViewController {
    var delegate: AlertDelegate?
    
    @IBOutlet var share_view: UIView!
    @IBOutlet var share_activity: UISwitch!
    @IBOutlet weak var alert_title: UILabel!
    @IBOutlet weak var alert_image: UIImageView!
    @IBOutlet weak var alert_description: UILabel!
    @IBOutlet weak var dismiss_button: ModalButton!
    
    var alert_array = [AlertModel]()
    var alert_flag: Int!
    
    override func viewDidAppear(_ animated: Bool) {
        dismiss_button.layoutIfNeeded()
    }
    
    func setAlert(_ alert_array: [AlertModel]) {
        self.alert_array = alert_array
        alert_flag = self.alert_array.count
        
        if alert_array.count != 0 {
            let model = alert_array.first!
            self.alert_title.text = model.alert_title
            self.alert_description.text = model.alert_description
            
            switch model.alert_image {
                case "success": alert_image.image = UIImage(named: "success")
                case "error": alert_image.image = UIImage(named: "error")
                case "Bronce": alert_image.image = UIImage(named: "bronce")
            default:break
            }
        }
    }
    
    @IBAction func dismissAlert(_ sender: ModalButton) {
        if self.alert_flag > 1 {
            for model in alert_array {
                if model != alert_array.first { self.setNextAlert(model) }
                self.alert_flag! -= 1
            }
        } else {
            self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
            self.navigationController?.popViewController(animated: true)
        }
        
        self.delegate?.pressAlertButton(self)
    }
    
    func setNextAlert(_ model: AlertModel) {
        self.alert_description.alpha = 0
        self.alert_title.text = model.alert_title
        self.alert_title.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
                self.alert_title.transform = CGAffineTransform.identity
                Utilities.fadeInFromBottomAnimation(self.alert_image, delay: 0, duration: 0.5, yPosition: 40)
            }, completion: { (Bool) -> Void in
                Utilities.fadeInFromBottomAnimation(self.alert_description, delay: 0, duration: 0.5, yPosition: 20)
        })

        self.alert_description.text = model.alert_description
        
        switch model.alert_image {
            case "success": alert_image.image = UIImage(named: "success")
            case "error": alert_image.image = UIImage(named: "error")
            case "Bronce": alert_image.image = UIImage(named: "bronce")

        default: break
        }

    }
}
