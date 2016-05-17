//
//  TabbarController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 31/07/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AVFoundation

class TabbarController: UITabBarController {
    
    var lastSelected = 0
    
    //let socketIO : SocketIO = SocketIO()
    
    var vcNot: NotificationViewController!

    override func viewDidLoad() {
        
        super.viewDidLoad()

        vcNot = self.storyboard!.instantiateViewControllerWithIdentifier("Notifications") as! NotificationViewController

        
        self.tabBar.opaque = false
        self.tabBar.translucent = false
        self.tabBar.alpha = 0.97
        
        self.tabBar.backgroundColor = UIColor.whiteColor()
        self.tabBar.tintColor = Utilities.dopColor
        
        self.tabBar.backgroundImage = UIImage(named: "")
        
        self.navigationController?.navigationBar.hidden = true
        
        //self.startListening()
        //self.startSocketListener()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addCenterButtonWithImage(buttonImage:UIImage){
        let button : UIButton = UIButton(type: UIButtonType.Custom)
        
        
        button.frame = CGRectMake(0,0, 57,57)
        button.backgroundColor = UIColor.clearColor()
        
        button.setImage(buttonImage, forState: .Normal)

        button.center = self.tabBar.center
        button.center.y = button.center.y - 6
        
        
        self.view.addSubview(button)
        button.addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchUpInside)

        self.view.bringSubviewToFront(button)
 
        
    }
    
    func pressed(sender: UIButton!) {
        self.selectedIndex = 2
    }
    override func viewWillAppear(animated: Bool) {
        self.selectedIndex = 1
        self.selectedIndex = 0
    }
    
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let barViewControllers = segue.destinationViewController 
        barViewControllers.hidesBottomBarWhenPushed = false
        
        self.hidesBottomBarWhenPushed = false

    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let currentSelected = self.selectedIndex
        if(lastSelected == currentSelected){
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        lastSelected = currentSelected
        
        if(FilterSideViewController.open == true){
            self.revealViewController().revealToggleAnimated(true)
        }
    }
    
    //NOTIFICATIONS SOCKET IO 2
    /*func startSocketListener(){
        SocketIOManager.sharedInstance.establishConnection()
        
        SocketIOManager.sharedInstance.connectToServerWithNickname(User.userToken, completionHandler: { (notification) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if notification != nil {
                    print("YESSSSS")
                }
            })
        })
        SocketIOManager.sharedInstance.getNotification { (info) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("NOTIFICATION")
                NSNotificationCenter.defaultCenter().postNotificationName("newNotification", object: nil)
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            })
        }
        SocketIOManager.sharedInstance.getNotification { (info) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("JOINED TO ROOM")
            })
        }
    }*/
    
    

}
