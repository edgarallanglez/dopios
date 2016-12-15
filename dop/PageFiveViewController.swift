//
//  PageFiveViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/11/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PageFiveViewController: UIViewController {

    @IBOutlet weak var permission_button: UIButton!
    @IBOutlet weak var notification_view: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyPlainShadow(notification_view)
        Utilities.applyPlainShadow(permission_button)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func askPermission(_ sender: UIButton) {
        let status = UIApplication.shared.currentUserNotificationSettings

        
        if let settingTypes = status?.types, settingTypes != UIUserNotificationType() {
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(settingsUrl!)
        } else {
//            if UIApplication.shared.currentUserNotificationSettings?.hashValue == 0 {
            UIApplication.shared.registerForRemoteNotifications()
            UIApplication.shared.registerUserNotificationSettings(
                UIUserNotificationSettings(types: [.alert, .sound, .badge],
                                           categories: nil)
            )
        }
    }
}
