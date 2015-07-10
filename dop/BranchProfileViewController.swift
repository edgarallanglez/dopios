//
//  BranchProfileViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/8/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit

class BranchProfileViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var branchLogo: UIImageView!
    @IBOutlet weak var branchName: UILabel!
    @IBOutlet weak var branchLocationMap: MKMapView!
    
    override func viewDidLoad() {
        branchLogo.image = UIImage(named: "starbucks.gif")
    }
    
}