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
    var branchId: Int!
    let regionRadius: CLLocationDistance = 500
    
    override func viewDidLoad() {

        
    }
    override func viewDidAppear(animated: Bool) {
        getBranchProfile()
    }
    
    func getBranchProfile() {
        branchLogo.image = UIImage(named: "starbucks.gif")
        BranchProfileController.getBranchProfileWithSuccess(2, success: { (branchData) -> Void in
            let data = JSON(data: branchData)
            var json = data["data"]
            json = json[0]
            var latitude = json["latitude"].double
            var longitude = json["longitude"].double
            
            let branchPin = CLLocation(latitude: latitude!, longitude: longitude!)
            var newLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.branchName.text = json["name"].string
                var dropPin = MKPointAnnotation()
                dropPin.coordinate = newLocation
                self.branchLocationMap.addAnnotation(dropPin)
                self.centerMapOnLocation(branchPin)
            });
        })
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        branchLocationMap.setRegion(coordinateRegion, animated: true)
    }
    
    
}