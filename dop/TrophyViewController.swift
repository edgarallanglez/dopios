//
//  TrophyViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 9/30/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TrophyViewController: UIViewController {
    
    
    
    @IBAction func launchBadgeAlert(sender: UIButton) {
        self.presentViewController(AlertClass().launchAlert(), animated: true, completion: nil)
    }
}
