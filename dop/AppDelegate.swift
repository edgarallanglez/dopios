//
//  AppDelegate.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/4/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import TwitterKit
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
    /* Twitter.sharedInstance().startWithConsumerKey("mNtK5gCZ1KZsZdzGbwPrDZvwR", consumerSecret: "X70nDMV3aFCObSuL0k3u9NaaadNtSDlhmmjIlQhWZzzF4RAUiO")
        
        Fabric.with([Twitter.sharedInstance()])*/
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
                
        FBLoginView.self
        FBProfilePictureView.self
        
        if FBSession.activeSession().state.value == FBSessionStateCreatedTokenLoaded.value {
            FBSession.openActiveSessionWithReadPermissions(["public_profile"], allowLoginUI: false, completionHandler: {
                (session, state, error) -> Void in
                self.sessionStateChanged(session, state: state, error: error)
            })
        }
        return true
    }
    
    
    func sessionStateChanged(session : FBSession, state : FBSessionState, error : NSError?) {
        println("el estado cambio")
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        var wasHandledFB:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        
        var wasHandledGG:Bool = GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
        
        return  wasHandledGG || wasHandledFB

    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }



}