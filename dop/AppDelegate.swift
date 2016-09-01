//
//  AppDelegate.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/4/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
//import TwitterKit
import Fabric
import FBSDKLoginKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        // Override point for customization after application launch.
//        
//        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
//        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
//        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
//        
//        
//        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        registerForPushNotifications(application)
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
            // 2
            let aps = notification["aps"] as! [String: AnyObject]
            
            let notification_data = notification["data"] as! [String: AnyObject]
            
            User.newestNotification = notification_data
            // 3
            (window?.rootViewController as? LoadingViewController)?.notification = notification_data
        }

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        //SocketIOManager.sharedInstance.closeConnection()
    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {
        //SocketIOManager.sharedInstance.establishConnection()
    }

    func applicationWillTerminate(application: UIApplication) {

    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("Complete");
        completionHandler(UIBackgroundFetchResult.NewData)
        
        getData();
        
    }
    func getData() -> Void{
            let localNotification:UILocalNotification = UILocalNotification()
            localNotification.alertAction = "Testing notifications on iOS8"
            localNotification.alertBody = "Movie Count : \(1)"
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        if (notificationSettings.types == UIUserNotificationType.None) {
            
        }
            
        else{
            
            application.registerForRemoteNotifications()
        }
        
        
    }


    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        User.deviceToken = tokenString
        print("Device Token:", tokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        let notification = userInfo["data"] as! [String: AnyObject]
        print(notification)
        
        NSNotificationCenter.defaultCenter().postNotificationName("newNotification", object: nil)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }


}
