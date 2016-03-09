//
//  AlertModalViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 2/9/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class AlertModalViewController: UIViewController {
    
    @IBOutlet weak var alert_title: UILabel!
    @IBOutlet weak var alert_image: UIImageView!
    @IBOutlet weak var alert_description: UILabel!
    @IBOutlet weak var dismiss_button: ModalButton!
    
    var alert_array = [AlertModel]()
    var alert_flag: Int!
    
    override func viewDidAppear(animated: Bool) {
        dismiss_button.layoutIfNeeded()
    }
    
    func setAlert(alert_array: [AlertModel]) {
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
    
    @IBAction func dismissAlert(sender: ModalButton) {
        if self.alert_flag > 1 {
            for model in alert_array {
                if model != alert_array.first { self.setNextAlert(model) }
                self.alert_flag!--
            }
        } else {
            self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func setNextAlert(model: AlertModel) {
        self.alert_description.alpha = 0
        self.alert_title.text = model.alert_title
        self.alert_title.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.alert_title.transform = CGAffineTransformIdentity
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