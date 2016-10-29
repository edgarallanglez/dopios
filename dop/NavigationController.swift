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
            NSForegroundColorAttributeName: UIColor.white
        ]
    
        
        self.navigationBar.setBackgroundImage(UIImage(named:"topbarBackground"), for: .default)
        
        self.navigationBar.isTranslucent = false
        
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes( [NSForegroundColorAttributeName: UIColor.white], for: UIControlState())
   

        UIApplication.shared.statusBarStyle = .lightContent
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

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
