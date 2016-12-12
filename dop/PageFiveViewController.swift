//
//  PageFiveViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/11/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PageFiveViewController: UIViewController {

    @IBOutlet weak var notification_view: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyPlainShadow(notification_view)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func askPermission(_ sender: UIButton) {
        let status = UIApplication.shared.currentUserNotificationSettings

        
        if let settingTypes = status?.types, settingTypes != UIUserNotificationType() || settingTypes == UIUserNotificationType() {
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(settingsUrl!)
        } else {
            UIApplication.shared.registerForRemoteNotifications()
            UIApplication.shared.registerUserNotificationSettings(
                UIUserNotificationSettings(types: [.alert, .sound, .badge],
                                           categories: nil)
            )
        }
    }
}
