//
//  TabbarController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 31/07/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AVFoundation

class TabbarController: UITabBarController, SocketIODelegate {
    
    var lastSelected = 0
    
    let socketIO : SocketIO = SocketIO()
    
    var vcNot: NotificationViewController!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        /*  var DynamicView=UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 49))
        DynamicView.backgroundColor=UIColor.greenColor()
        DynamicView.alpha = 0.5
        
        
        self.tabBar.viewForBaselineLayout()?.addSubview(DynamicView)
        self.tabBar.viewForBaselineLayout()?.sendSubviewToBack(DynamicView)
        
        */
        vcNot = self.storyboard!.instantiateViewControllerWithIdentifier("Notifications") as! NotificationViewController

        
        self.tabBar.opaque = false
        self.tabBar.translucent = false
        self.tabBar.alpha = 0.97
        
        self.tabBar.backgroundColor = UIColor.whiteColor()
        self.tabBar.tintColor = Utilities.dopColor
        
        self.tabBar.backgroundImage = UIImage(named: "")
        
        self.navigationController?.navigationBar.hidden = true
        
        self.startListening()
       /* let notificationButton = NotificationButton(image: UIImage(named: "notification"), style: UIBarButtonItemStyle.Plain, target: self, action: "notification")
        
        
        self.navigationItem.rightBarButtonItem = notificationButton
        
        notificationButton.delegate = self
        notificationButton.startListening()*/
        
        

        
    /*self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"topbarBackground"), forBarMetrics: .Default)
        
        var backgroundLayer = Utilities.Colors
        

        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        
        
    
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes( [NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
       */
        
        //let imagen:UIImage = UIImage(named: "tabButtonn")!
        //addCenterButtonWithImage(imagen)
        
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
    
    func notification() {
        self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("Notifications") as UIViewController, animated: true)
        self.navigationController?.hidesBottomBarWhenPushed = false
        
    }
    
    func search(){
        //self.performSegueWithIdentifier("searchView", sender: self)
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
        /*let nav = barViewControllers.viewControllers![2] as! UINavigationController
        let destinationViewController = nav.topViewController as! SearchViewController*/
        
    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let currentSelected = self.selectedIndex
        if(lastSelected == currentSelected){
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        lastSelected = currentSelected
    }
    
    //NOTIFICATIONS
    
    func getNotification(packet:SocketIOPacket) {
        let navController = self.selectedViewController as! UINavigationController
        
        NSNotificationCenter.defaultCenter().postNotificationName("newNotification", object: nil)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    func startListening(){
        socketIO.delegate = self
        socketIO.useSecure = true
        socketIO.connectToHost("inmoon.com.mx", onPort: 443, withParams: nil, withNamespace: "/app")
        
        
    }
    func socketIODidConnect(socket: SocketIO) {
        print("socket.io connected.")
        socketIO.sendEvent("join room", withData: User.userToken)
        //socketIO.sendEvent("notification", withData: User.userToken)
    }
    func socketIO(socket: SocketIO, didReceiveEvent packet: SocketIOPacket) {
        print("didReceiveEvent >>> data: %@", packet.dataAsJSON())
        
        if(packet.name == "my response"){
            //socketIO.sendMessage("hello back!", withAcknowledge: cb)
        }
        if(packet.name == "notification"){
            self.getNotification(packet)
        }
    }
    func socketIODidDisconnect(socket: SocketIO!, disconnectedWithError error: NSError!) {
        socketIO.connectToHost("inmoon.com.mx", onPort: 443, withParams: nil, withNamespace: "/app")
    }

}
