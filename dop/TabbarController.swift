//
//  TabbarController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 31/07/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.tabBar.tintColor = Utilities.dopColor
        
        self.navigationController?.navigationBar.barTintColor = Utilities.dopColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes( [NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
       

    
        
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
