//
//  AppDelegate.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/4/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
//import Fabric
import FBSDKLoginKit
import AVFoundation
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if ((launchOptions) != nil) {
            URLCache.shared.removeAllCachedResponses()
            let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
            if notificationType.contains(UIUserNotificationType.alert) && !User.userToken.isEmpty  {
                registerForPushNotifications(application)
            }
            
            if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
                // 2
                let aps = notification["aps"] as! [String: AnyObject]
                let notification_data = notification["data"] as! [String: AnyObject]
                
                User.newestNotification = notification_data
                // 3
                (window?.rootViewController as? LoadingViewController)?.notification = notification_data
            }
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func application(_ application: UIApplication,
        open url: URL,
        sourceApplication: String?,
        annotation: Any) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                open: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("ALO1")

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //SocketIOManager.sharedInstance.closeConnection()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("ALO2")
        //SocketIOManager.sharedInstance.establishConnection()
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Complete");
        completionHandler(UIBackgroundFetchResult.newData)
        
        //getData();
        
    }
    func getData() -> Void{
            let localNotification:UILocalNotification = UILocalNotification()
            localNotification.alertAction = "Testing notifications on iOS8"
            localNotification.alertBody = "Movie Count: \(1)"
            localNotification.fireDate = Date(timeIntervalSinceNow: 1)
            UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    func registerForPushNotifications(_ application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)
        
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        if (notificationSettings.types == UIUserNotificationType()) {
        }
        else { application.registerForRemoteNotifications() }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString: String = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        User.deviceToken = tokenString
        let params: Parameters = ["device_token": User.deviceToken]
        
        Alamofire.request("\(Utilities.dopURL)user/device_token/set",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: User.userToken).validate().responseJSON { response in
                print(response)
        }
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "notificationsRegistered"), object: nil)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        let notification = userInfo["data"] as! [String: AnyObject]
        print(notification)
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "newNotification"), object: nil)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
