//
//  FilterSideViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/26/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class FilterSideViewController: UIViewController {
    
    @IBOutlet weak var entertainmentView: UIView!
    @IBOutlet weak var servicesView: UIView!
    @IBOutlet weak var foodView: UIView!
    
    
    @IBAction func setFilterCategory(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            foodView.hidden = false
            servicesView.hidden = true
            entertainmentView.hidden = true
        case 1:
            foodView.hidden = true
            servicesView.hidden = false
            entertainmentView.hidden = true
        case 2:
            foodView.hidden = true
            servicesView.hidden = true
            entertainmentView.hidden = false
        default:
            break
        }
    }
   
    
}
