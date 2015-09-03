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
       
        
        var imagen:UIImage = UIImage(named: "main-icon-dop")!
        addCenterButtonWithImage(imagen)
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        
        
        
        
        
        var logButton : UIBarButtonItem = UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.Plain, target: self, action: "search")
        
        self.navigationItem.rightBarButtonItem = logButton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addCenterButtonWithImage(buttonImage:UIImage){
        var button : UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        
        
        button.frame = CGRectMake(0,0, 57,49)
        button.backgroundColor = UIColor.clearColor()
        //button.setBackgroundImage(buttonImage, forState: .Normal)
        
        button.setImage(buttonImage, forState: .Normal)
        
        var heightDiference = 49 - self.tabBar.frame.size.height
        
        var center:CGPoint = self.tabBar.center
        var navBarHeight = self.navigationController?.navigationBar.frame.size.height

        let staturBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        center.y = center.y - (navBarHeight!)-staturBarHeight

        
        button.center = center
        
        
        self.view.addSubview(button)
        button.addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchUpInside)

        self.view.bringSubviewToFront(button)
 
        
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
        let barViewControllers = segue.destinationViewController as! UIViewController
        barViewControllers.hidesBottomBarWhenPushed = false
        
        /*let nav = barViewControllers.viewControllers![2] as! UINavigationController
        let destinationViewController = nav.topViewController as! SearchViewController*/
        
    }

  

}
