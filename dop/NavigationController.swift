//
//  NavigationController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 10/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit


class NavigationController: UINavigationController{

    @IBOutlet var navBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = nil

        self.delegate = self.navigationController?.delegate
        
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
    
        
        
        self.navigationBar.setBackgroundImage(UIImage(named:"topbarBackground"), forBarMetrics: .Default)
        
        self.navigationBar.translucent = false
        
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes( [NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
   
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
  
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
