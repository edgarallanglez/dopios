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
    
    override func viewDidAppear(animated: Bool) {
        dismiss_button.layoutIfNeeded()
    }
    
    func setAlert(type: String, alert_title: String, alert_description: String) {
        self.alert_title.text = alert_title
        self.alert_description.text = alert_description
        
        switch type {
            case "success": alert_image.image = UIImage(named: "success")
            case "error": alert_image.image = UIImage(named: "error")
        default:break
        }
    }
    
    @IBAction func dismissAlert(sender: ModalButton) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
    
    
}
