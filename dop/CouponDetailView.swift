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
    @IBOutlet weak var couponsName: UIButton!
    @IBOutlet weak var couponsDescription: UITextView!

    var viewController: UIViewController?
    let regionRadius: CLLocationDistance = 1000
    
    @IBAction func triggerSegue(sender: UIButton) {
        self.viewController!.performSegueWithIdentifier("branchProfile", sender: self)
    }
    
    func loadView(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        var dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        dropPin.title = self.couponsName.titleLabel?.text
        self.location.addAnnotation(dropPin)
        
        let centerPin = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(centerPin.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        self.location.setRegion(coordinateRegion, animated: true)
    }
  
}
