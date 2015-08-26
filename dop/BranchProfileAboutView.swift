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
    @IBOutlet weak var pinIcon: UILabel!
    @IBOutlet weak var clockIcon: UILabel!
    let regionRadius: CLLocationDistance = 500
    
    func loadAbout(description: String, branchLocation: CLLocation ) {
        branchDescription.text = description
        pinIcon.text =  String.fontAwesomeString("fa-map-marker")
        clockIcon.text = String.fontAwesomeString("fa-clock-o")
        centerMapOnLocation(branchLocation)

    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                regionRadius * 2.0, regionRadius * 2.0)
        branchLocationMap.setRegion(coordinateRegion, animated: true)
    }

}
