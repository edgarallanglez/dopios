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
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var topBorder: UIView!
    
    var coordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager!
    var current: CLLocation!
    var filterArray: [Int] = []
    var annotationArray: [AnyObject] = []
    @IBOutlet weak var filterSidebarButton: UIButton!
    
    override func viewDidLoad() {
        Utilities.filterArray.removeAll()
        
//        topBorder.layer.borderWidth = (1.0 / UIScreen.mainScreen.scale) / 2
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getNearestBranches", name: "filtersChanged", object: nil)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        User.coordinate = locationManager.location.coordinate
        if (self.revealViewController() != nil) {
            self.filterSidebarButton.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        var locationArrow:UIImageView = UIImageView(image: UIImage(named: "locationArrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        currentLocationLbl.setBackgroundImage(locationArrow.image, forState: UIControlState.Normal)
        currentLocationLbl.tintColor = Utilities.dopColor
        
        //getNearestBranches()
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        setMapAtCurrent()
        
    }
    
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
        setMapAtCurrent()
    }
    
    @IBAction func searchNearest(sender: UIButton) {
        getNearestBranches()
    }
    
    func setMapAtCurrent() {
        var currentUserLocation = CLLocation(latitude: User.coordinate.latitude, longitude: User.coordinate.longitude)
        self.current = currentUserLocation
        centerMapOnLocation(currentUserLocation)
    }
    
    func getNearestBranches() {
        var latitude = User.coordinate.latitude
        var longitude = User.coordinate.longitude
        filterArray = Utilities.filterArray
        if self.nearbyMap != nil {
            self.nearbyMap.removeAnnotations(self.annotationArray)
        }
        let params:[String:AnyObject] = [
            "latitude": latitude,
            "longitude": longitude,
            "radio": 15,
            "filterArray": filterArray
        ]
        print(params)
        NearbyMapController.getNearestBranches(params, success: {(branchesData) -> Void in
            let json = JSON(data: branchesData)
            print(json["data"].count)
            for (index, location) in json["data"] {
                var latitude = location["latitude"].double
                var longitude = location["longitude"].double
                
                var newLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
                dispatch_async(dispatch_get_main_queue()) {
                    // Drop a pin
                    var dropPin = MKPointAnnotation()
                    dropPin.coordinate = newLocation
                    dropPin.title = location["name"].string
                    self.annotationArray.append(dropPin)
                    self.nearbyMap.addAnnotation(dropPin)
                }
            }
            },
            failure:{(branchesData)-> Void in
        })
    }
    

}