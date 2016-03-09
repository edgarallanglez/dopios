//
//  NearbyMapViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/28/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import MapKit

class NearbyMapViewController: BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIScrollViewDelegate {
    
 
    @IBOutlet weak var currentLocationLbl: UIButton!
    @IBOutlet weak var nearbyMap: MKMapView!
    @IBOutlet weak var topBorder: UIView!
    
    var coordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager!
    var current: CLLocation!
    var filterArray: [Int] = []
    var annotationArray: [MKAnnotation] = []
    var filterSidebarButton: UIBarButtonItem = UIBarButtonItem()
    
    var currentAnnotationView: MapPinCallout?
    
    var spinner: MMMaterialDesignSpinner!
    
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        Utilities.filterArray.removeAll()
        nearbyMap.delegate = self
//        topBorder.layer.borderWidth = (1.0 / UIScreen.mainScreen.scale) / 2
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        spinner = MMMaterialDesignSpinner(frame: CGRectMake(0, 0, 50, 50))
        spinner.center.x = self.view.center.x
        spinner.center.y = self.view.center.y - 70.0
        spinner.layer.cornerRadius = spinner.frame.width / 2
        spinner.lineWidth = 3.0
        spinner.startAnimating()
        spinner.tintColor = Utilities.dopColor
        spinner.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(spinner)
        spinner?.startAnimating()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getNearestBranches", name: "filtersChanged", object: nil)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        User.coordinate = locationManager.location!.coordinate
        
        if (self.revealViewController() != nil) {
            filterSidebarButton = UIBarButtonItem(image: UIImage(named: "filter"), style: UIBarButtonItemStyle.Plain, target: self.revealViewController(), action: "revealToggle:")
            self.nearbyMap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapMap"))
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
    func tapMap() {
        if FilterSideViewController.open == true { self.revealViewController().revealToggleAnimated(true) }
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if FilterSideViewController.open == true { self.revealViewController().revealToggleAnimated(true) }
    }
    
    
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
        Utilities.fadeInViewAnimation(self.spinner!, delay: 0, duration: 0.3)
        NearbyMapController.getNearestBranches(params, success: {(branchesData) -> Void in
            let json = JSON(data: branchesData)
            print(json)
            for (_, branch) in json["data"] {
                let branch_id = branch["branch_id"].int
                let company_id = branch["company_id"].int
                let latitude = branch["latitude"].double
                let longitude = branch["longitude"].double
                let address = branch["address"].string!
                let distance = Utilities.roundValue(branch["distance"].double!,numberOfPlaces: 1.0)
                let logo = branch["logo"].string!
                let newLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
                dispatch_async(dispatch_get_main_queue()) {
                    // Drop a pin
                    let dropPin : Annotation = Annotation(coordinate: newLocation, title: branch["name"].string!, subTitle: address, branch_distance: "\(distance)", branch_id: branch_id!, company_id: company_id!, logo: logo)
                    if branch["category_id"].int! == 1 {
                        dropPin.typeOfAnnotation = "marker-food-icon"
                    } else if branch["category_id"].int! == 2 {
                        dropPin.typeOfAnnotation = "marker-services-icon"
                    } else if branch["category_id"].int! == 3 {
                        dropPin.typeOfAnnotation = "marker-entertainment-icon"
                    }
                    self.annotationArray.append(dropPin)
                    self.nearbyMap.addAnnotation(dropPin)
                    
                    Utilities.fadeOutViewAnimation(self.spinner!, delay: 0, duration: 0.3)

                }
            }
            },
            failure:{(branchesData)-> Void in
                Utilities.fadeOutViewAnimation(self.spinner!, delay: 0, duration: 0.3)
        })
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "custom"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if mapView.userLocation == annotation as! NSObject { return nil }
        if (annotationView == nil) {
            annotationView = MapPin(annotation: annotation, reuseIdentifier: reuseId)
            annotationView!.canShowCallout = false
            
            
        } else {  annotationView?.annotation = annotation }
        
        let customAnnotation = annotation as! Annotation
       
        annotationView!.image = UIImage(named: customAnnotation.typeOfAnnotation)
        
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
     
        
        if let mapPin = view as? MapPin {
                currentAnnotationView = mapPin.calloutView
                let annotation = view.annotation! as! Annotation
                mapPin.calloutView?.name_label!.text = annotation.title!
                mapPin.calloutView?.address_label!.text = annotation.subtitle!
                mapPin.calloutView?.info_label!.text = "A \(annotation.distance!) km de tu ubicación actual"
                mapPin.calloutView?.button!.tag = annotation.branch_id!
                mapPin.calloutView?.button!.addTarget(self, action: "goToBranchProfile:", forControlEvents: .TouchUpInside)
                let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(annotation.company_id!)/\(annotation.logo!)")
            
                print("\(imageUrl!)")
                mapPin.calloutView?.branch_image!.alpha = 0
            
                Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                    if let image = data{
                        dispatch_async(dispatch_get_main_queue()) {
                            let imageData: NSData = NSData(data: image)
                            mapPin.calloutView?.branch_image!.image = UIImage(data: imageData)
                            Utilities.fadeInViewAnimation((mapPin.calloutView?.branch_image)!, delay:0, duration:1)
                            
                        }
                    }else{
                        print("Error")
                    }
                })
                

                updatePinPosition(mapPin)
        }
        
        
    }
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        currentAnnotationView!.removeFromSuperview()
       /* if let mapPin = view as? MapPin {
            if mapPin.preventDeselection {
                mapView.selectAnnotation(view.annotation!, animated: false)
            }
        }*/
    }
    func goToBranchProfile(sender: UIButton) {
        let view_controller = self.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
        view_controller.branch_id = sender.tag
        self.navigationController?.pushViewController(view_controller, animated: true)
    }


    func updatePinPosition(pin:MapPin) {
        let defaultShift:CGFloat = 10
        let pinPosition = CGPointMake(pin.frame.midX, pin.frame.maxY)
        
        let y = pinPosition.y - defaultShift
        
        let controlPoint = CGPointMake(pinPosition.x, y)
        let controlPointCoordinate = nearbyMap.convertPoint(controlPoint, toCoordinateFromView: nearbyMap)
        
        nearbyMap.setCenterCoordinate(controlPointCoordinate, animated: true)
    }
    
}