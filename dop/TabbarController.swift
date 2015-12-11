//
//  TabbarController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 31/07/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TabbarController: UITabBarController, NotificationDelegate {
    
    var lastSelected = 0
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
        
        self.navigationController?.navigationBar.hidden = true
        
        
        
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
        
        
        self.hidesBottomBarWhenPushed = false
        /*let nav = barViewControllers.viewControllers![2] as! UINavigationController
        let destinationViewController = nav.topViewController as! SearchViewController*/
        
    }
    
    func getNotification(packet:SocketIOPacket) {
        print("NOTIFICATION")
        var alert = UIAlertController(title: "Alert", message: packet.data, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)

    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let currentSelected = self.selectedIndex
        if(lastSelected == currentSelected){
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        lastSelected = currentSelected
    }
   

  

}
