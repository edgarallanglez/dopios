//
//  NearbyMapViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/28/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import MapKit

class NearbyMapViewController: BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
 
    @IBOutlet weak var currentLocationLbl: UIButton!
    @IBOutlet weak var nearbyMap: MKMapView!
    @IBOutlet weak var topBorder: UIView!
    
    var coordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager!
    var current: CLLocation!
    var filterArray: [Int] = []
    var annotationArray: [MKAnnotation] = []
    var filterSidebarButton: UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        Utilities.filterArray.removeAll()
        nearbyMap.delegate = self
//        topBorder.layer.borderWidth = (1.0 / UIScreen.mainScreen.scale) / 2
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getNearestBranches", name: "filtersChanged", object: nil)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        User.coordinate = locationManager.location!.coordinate
        if (self.revealViewController() != nil) {
            filterSidebarButton = UIBarButtonItem(image: UIImage(named: "filter"), style: UIBarButtonItemStyle.Plain, target: self.revealViewController(), action: "revealToggle:")
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.navigationItem.leftBarButtonItem = filterSidebarButton
        }
        
        let locationArrow:UIImageView = UIImageView(image: UIImage(named: "locationArrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        currentLocationLbl.setImage(locationArrow.image, forState: UIControlState.Normal)
        currentLocationLbl.tintColor = Utilities.dopColor
        currentLocationLbl.backgroundColor = UIColor.whiteColor()
        
        getNearestBranches()
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = manager.location!.coordinate
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func currentLocation(sender: UIButton) {
        setMapAtCurrent()
    }
    
    func setMapAtCurrent() {
        let currentUserLocation = CLLocation(latitude: User.coordinate.latitude, longitude: User.coordinate.longitude)
        self.current = currentUserLocation
        centerMapOnLocation(currentUserLocation)
    }
    
    func getNearestBranches() {
        let latitude = User.coordinate.latitude
        let longitude = User.coordinate.longitude
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
        print(params, terminator: "")
        NearbyMapController.getNearestBranches(params, success: {(branchesData) -> Void in
            let json = JSON(data: branchesData)
            for (_, branch) in json["data"] {
                let latitude = branch["latitude"].double
                let longitude = branch["longitude"].double

                let newLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
                dispatch_async(dispatch_get_main_queue()) {
                    // Drop a pin
                    let dropPin : Annotation = Annotation(coordinate: newLocation, title: branch["name"].string!, subTitle: "Los mejores", branch_distance: "4.3")
                    if branch["category_id"].int! == 1 {
                        dropPin.typeOfAnnotation = "marker-food-icon"
                    } else if branch["category_id"].int! == 2 {
                        dropPin.typeOfAnnotation = "marker-services-icon"
                    } else if branch["category_id"].int! == 3 {
                        dropPin.typeOfAnnotation = "marker-entertainment-icon"
                    }
                    self.annotationArray.append(dropPin)
                    self.nearbyMap.addAnnotation(dropPin)
                }
            }
            },
            failure:{(branchesData)-> Void in
        })
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "custom"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if mapView.userLocation == annotation as! NSObject { return nil }
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView!.canShowCallout = true
            
        } else { annotationView?.annotation = annotation }
        
        let customAnnotation = annotation as! Annotation
        annotationView!.image = UIImage(named: customAnnotation.typeOfAnnotation)
        
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if view.annotation is MKUserLocation {  print("h") } else {
            var custom_view: UIView = UIView(frame: CGRectMake(0, 0, 100, 100))
            custom_view.backgroundColor = UIColor.redColor()
//            view.addSubview(custom_view)
        }
        
        
    }

}