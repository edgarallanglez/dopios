//
//  CouponDetailView.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit
class CouponDetailView: UIView {

    @IBOutlet var branch_cover: UIImageView!
    @IBOutlet var branch_logo: UIImageView!
    @IBOutlet var branch_category: UILabel!
    @IBOutlet var location: MKMapView!
    
    @IBOutlet weak var branchName: UIButton!
    var viewController: UIViewController?
    
    @IBAction func triggerSegue(sender: UIButton) {
        self.viewController!.performSegueWithIdentifier("branchProfile", sender: self)
    }
    
    
  
}
