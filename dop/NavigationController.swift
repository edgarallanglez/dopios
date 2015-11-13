//
//  NavigationController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 10/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit


class NavigationController: UINavigationController, NotificationDelegate {

    @IBOutlet var navBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
    
        
        
        self.navigationBar.setBackgroundImage(UIImage(named:"topbarBackground"), forBarMetrics: .Default)
        
        self.navigationBar.translucent = false
        
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes( [NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
   
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        
        let notificationButton: NotificationButton = NotificationButton(image: UIImage(named: "notification"), style: UIBarButtonItemStyle.Plain, target: self, action: "notification")
        
        
        let searchButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named:"search-icon"), style: UIBarButtonItemStyle.Plain, target: self, action: "search")
        
        
        self.navigationItem.leftBarButtonItem = notificationButton
        self.navigationItem.rightBarButtonItem = searchButton
        
        

        notificationButton.delegate = self
        notificationButton.startListening()
        
        self.navigationItem.setLeftBarButtonItem(notificationButton, animated: true)
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNotification(packet:SocketIOPacket) {
        print("NOTIFICATION")
        var alert = UIAlertController(title: "Alert", message: packet.data, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    func notification() {
        self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("Notifications") as UIViewController, animated: true)
        self.navigationController?.hidesBottomBarWhenPushed = false
        
    }
    
    func search(){
        self.performSegueWithIdentifier("searchView", sender: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
