//
//  BranchProfileAboutView.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/6/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit

class BranchProfileAboutView: UITableViewCell, CLLocationManagerDelegate {
    
    @IBOutlet weak var branchLocationMap: MKMapView!
    @IBOutlet weak var branchDescription: UITextView!
    @IBOutlet weak var pinIcon: UIImageView!
    @IBOutlet weak var clockIcon: UIImageView!

    let regionRadius: CLLocationDistance = 500
    
    func loadAbout(description: String, branchLocation: CLLocation ) {
        branchDescription.text = description
        pinIcon.image = pinIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        pinIcon.tintColor = UIColor.lightGrayColor()
        clockIcon.image = clockIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        clockIcon.tintColor = UIColor.lightGrayColor()
        
        centerMapOnLocation(branchLocation)

    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                regionRadius * 2.0, regionRadius * 2.0)
        branchLocationMap.setRegion(coordinateRegion, animated: true)
    }

}
