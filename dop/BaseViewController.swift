//
//  BaseViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 11/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, NotificationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named:"search-icon"), style: UIBarButtonItemStyle.Plain, target: self, action: "search")
        
        
         let notificationButton: NotificationButton = NotificationButton(image: UIImage(named: "notification"), style: UIBarButtonItemStyle.Plain, target: self, action: "notification")
        
        
        self.navigationItem.rightBarButtonItem = searchButton
        self.navigationItem.leftBarButtonItem = notificationButton
        
        notificationButton.delegate = self
        notificationButton.startListening()
    }

    
    func search(){
        //self.navigationController?.popToRootViewControllerAnimated(true)
        //self.navigationController?.pushViewController(nextViewController, animated: true)
        let vc : SearchViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SearchView") as! SearchViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
        
 
        
        /*self.navigationController?.pushViewController(vc, animated: true) {
            vc.doSomething()
        }*/
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func notification() {
        self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("Notifications") as UIViewController, animated: true)
        self.navigationController?.hidesBottomBarWhenPushed = false
        
    }
    
    func getNotification(packet:SocketIOPacket) {
        print("NOTIFICATION")
        var alert = UIAlertController(title: "Alert", message: packet.data, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
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
