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
       
        
        var imagen:UIImage = UIImage(named: "tabButton")!
        addCenterButtonWithImage(imagen)

    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addCenterButtonWithImage(buttonImage:UIImage){
        var button : UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        
        button.frame = CGRectMake(0,0, 65,65)
        
        button.setBackgroundImage(buttonImage, forState: .Normal)
        
        var heightDiference = 65 - self.tabBar.frame.size.height / 2
        
            var center:CGPoint = self.tabBar.center
            center.y = center.y - 71
            button.center = center
        
        
        self.view.addSubview(button)
        button.addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchUpInside)

        self.view.bringSubviewToFront(button)
       
        /*button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        
        [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
        */
        
        
    }
    func pressed(sender: UIButton!) {
        
        self.selectedIndex = 3
    }

  

}
