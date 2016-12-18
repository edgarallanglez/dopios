//
//  PageFiveViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/11/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PageFiveViewController: UIViewController {
    @IBOutlet var tutorial_description: UILabel!
    @IBOutlet var tutorial_title: UILabel!
    @IBOutlet var top_logo: UIImageView!

    @IBOutlet weak var permission_button: UIButton!
    @IBOutlet weak var notification_view: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyPlainShadow(notification_view)
        Utilities.applyPlainShadow(permission_button)
        // Do any additional setup after loading the view.
        
        top_logo.alpha = 0
        tutorial_title.alpha = 0
        tutorial_description.alpha = 0
        permission_button.alpha = 0
        notification_view.alpha = 0
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
    override func viewWillAppear(_ animated: Bool) {
        Utilities.fadeInFromBottomAnimation(top_logo, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(notification_view, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(tutorial_title, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(tutorial_description, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(permission_button, delay: 0.8, duration: 1, yPosition: 20)
    }
    override func viewDidDisappear(_ animated: Bool) {
        top_logo.alpha = 0
        notification_view.alpha = 0
        tutorial_title.alpha = 0
        tutorial_description.alpha = 0
        permission_button.alpha = 0
    }
}
