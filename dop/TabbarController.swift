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

        vcNot = self.storyboard!.instantiateViewController(withIdentifier: "Notifications") as! NotificationViewController

        
        self.tabBar.isOpaque = false
        self.tabBar.isTranslucent = false
        self.tabBar.alpha = 0.97
        
        self.tabBar.backgroundColor = UIColor.white
        self.tabBar.tintColor = Utilities.dopColor
        
        self.tabBar.backgroundImage = UIImage(named: "")
        
        self.navigationController?.navigationBar.isHidden = true
        
        //self.startListening()
        //self.startSocketListener()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addCenterButtonWithImage(_ buttonImage:UIImage){
        let button : UIButton = UIButton(type: UIButtonType.custom)
        
        button.frame = CGRect(x: 0,y: 0, width: 57,height: 57)
        button.backgroundColor = UIColor.clear
        
        button.setImage(buttonImage, for: UIControlState())

        button.center = self.tabBar.center
        button.center.y = button.center.y - 6
        
        
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(TabbarController.pressed(_:)), for: UIControlEvents.touchUpInside)

        self.view.bringSubview(toFront: button)
        
    }
    
    func pressed(_ sender: UIButton!) {
        self.selectedIndex = 2
    }
    override func viewWillAppear(_ animated: Bool) {
        self.selectedIndex = 1
        self.selectedIndex = 0
    }
    
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let barViewControllers = segue.destination 
        barViewControllers.hidesBottomBarWhenPushed = false
        
        self.hidesBottomBarWhenPushed = false

    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let currentSelected = self.selectedIndex
        if(lastSelected == currentSelected){
            self.navigationController?.popToRootViewController(animated: true)
        }
        lastSelected = currentSelected
        
        if(FilterSideViewController.open == true){
            self.revealViewController().revealToggle(animated: true)
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
