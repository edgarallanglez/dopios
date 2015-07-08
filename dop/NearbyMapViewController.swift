//
//  NearbyMapViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/28/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import MapKit

class NearbyMapViewController: UIViewController, CLLocationManagerDelegate {
    
 
    @IBOutlet weak var currentLocationLbl: UIButton!
    @IBOutlet weak var nearbyMap: MKMapView!
    var coordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager!
    var current: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation(initialLocation)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        var gpsIcon = String.fontAwesomeString("fa-location-arrow")
        var buttonStringAttributed = NSMutableAttributedString(string: gpsIcon, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("FontAwesome", fontSize: 25), range: NSRange(location: 0,length: 1))
        
        currentLocationLbl.titleLabel?.textAlignment = .Center
        currentLocationLbl.titleLabel?.numberOfLines = 2
        currentLocationLbl.setAttributedTitle(buttonStringAttributed, forState: .Normal)

    }
    
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        nearbyMap.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        coordinate = manager.location.coordinate
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func currentLocation(sender: UIButton) {
        var currentUserLocation = CLLocation(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
        self.current = currentUserLocation
        centerMapOnLocation(currentUserLocation)
    }
    
    @IBAction func getNearestBranches(sender: UIButton) {
        var latitude = String(stringInterpolationSegment: coordinate!.latitude)
        var longitude = String(stringInterpolationSegment: coordinate!.longitude)
        
        var params:[String:AnyObject] = [
            "latitude": latitude,
            "longitude": longitude,
            "radio": 10
        ]
        
        NearbyMapController.getNearestBranches(params) {(branchesData) -> Void in
            let json = JSON(data: branchesData)
            println(branchesData)
        }
    }
    

}