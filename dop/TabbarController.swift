//
//  TabbarController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 31/07/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TabbarController: UITabBarController, NotificationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
      /*  var DynamicView=UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 49))
        DynamicView.backgroundColor=UIColor.greenColor()
        DynamicView.alpha = 0.5
        
        
        self.tabBar.viewForBaselineLayout()?.addSubview(DynamicView)
        self.tabBar.viewForBaselineLayout()?.sendSubviewToBack(DynamicView)
        
        */
        
        self.tabBar.opaque = false
        self.tabBar.translucent = false
        self.tabBar.alpha = 0.97
        
        self.tabBar.backgroundColor = UIColor.whiteColor()
        self.tabBar.tintColor = Utilities.dopColor
        
        self.tabBar.backgroundImage = UIImage(named: "")
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"topbarBackground"), forBarMetrics: .Default)
        
        var backgroundLayer = Utilities.Colors
        
        //self.navigationController?.navigationBar.layer.insertSublayer(backgroundLayer,atIndex:5)

        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        
        
    
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes( [NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
       
        
        let imagen:UIImage = UIImage(named: "main-icon-dop")!
        addCenterButtonWithImage(imagen)
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        
        let notificationButton: NotificationButton = NotificationButton(image: UIImage(named: "trophy1"), style: UIBarButtonItemStyle.Plain, target: self, action: "notification")
        
        
        let searchButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named:"search-icon"), style: UIBarButtonItemStyle.Plain, target: self, action: "search")
        
       /* var logButton : UIBarButtonItem = UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.Plain, target: self, action: "search")*/
        self.navigationItem.leftBarButtonItem = notificationButton
        self.navigationItem.rightBarButtonItem = searchButton
        
        notificationButton.delegate = self
        notificationButton.startListening()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addCenterButtonWithImage(buttonImage:UIImage){
        let button : UIButton = UIButton(type: UIButtonType.Custom)
        
        
        button.frame = CGRectMake(0,0, 57,49)
        button.backgroundColor = UIColor.clearColor()
        //button.setBackgroundImage(buttonImage, forState: .Normal)
        
        button.setImage(buttonImage, forState: .Normal)
        
        var heightDiference = 49 - self.tabBar.frame.size.height
        
        var center:CGPoint = self.tabBar.center
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height

        let staturBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        center.y = center.y - (navBarHeight!)-staturBarHeight

        
        button.center = center
        
        
        self.view.addSubview(button)
        button.addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchUpInside)

        self.view.bringSubviewToFront(button)
 
        
    }
    
    func notification() {
        self.performSegueWithIdentifier("notificationView", sender: self)
    }
    
    func search(){
        self.performSegueWithIdentifier("searchView", sender: self)
    }
    
    func pressed(sender: UIButton!) {
        self.selectedIndex = 2
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.performSegueWithIdentifier("searchView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let barViewControllers = segue.destinationViewController 
        barViewControllers.hidesBottomBarWhenPushed = false
        
        /*let nav = barViewControllers.viewControllers![2] as! UINavigationController
        let destinationViewController = nav.topViewController as! SearchViewController*/
        
    }
    
    func getNotification(packet:SocketIOPacket) {
        print("NOTIFICATION")
        var alert = UIAlertController(title: "Alert", message: packet.data, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)

    }

  

}
