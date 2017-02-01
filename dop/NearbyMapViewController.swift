//
//  NearbyMapViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/28/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import MapKit
import AlamofireImage
import Alamofire

class NearbyMapViewController: BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate, ModalDelegate, UIScrollViewDelegate {
    
 
    @IBOutlet weak var currentLocationLbl: UIButton!
    @IBOutlet weak var nearbyMap: MKMapView!
    @IBOutlet weak var topBorder: UIView!
    @IBOutlet weak var giverView: UIView!
    
    var coordinate: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    var current: CLLocation!
    var filterArray: [Int] = []
    var annotationArray: [MKAnnotation] = []
    var filterSidebarButton: UIBarButtonItem = UIBarButtonItem()
    
    var currentAnnotationView: MapPinCallout?
    var spinner: MMMaterialDesignSpinner!
    var alert_array = [AlertModel]()
    var modal_alert: ModalViewController!
    
    var little_size: Bool!
    
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        nearbyMap.delegate = self
        if !(CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined) {
            setNearbyMap()
        } else {
            let background = Utilities.Colors
            background.frame = self.view.bounds
            self.giverView.layer.insertSublayer(background, at: 0)
            self.giverView.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setMapAtCurrent()
    }
    
    func tapMap() {
        if FilterSideViewController.open == true { self.revealViewController().revealToggle(animated: true) }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if FilterSideViewController.open == true { self.revealViewController().revealToggle(animated: true) }
    }
    
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        nearbyMap.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = manager.location!.coordinate
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func currentLocation(_ sender: UIButton) {
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
            "latitude": latitude as AnyObject,
            "longitude": longitude as AnyObject,
            "radio": 15 as AnyObject,
            "filterArray": filterArray as AnyObject
        ]
        
        Utilities.fadeInViewAnimation(self.spinner!, delay: 0, duration: 0.3)
        NearbyMapController.getNearestBranches(params, success: {(branchesData) -> Void in
            let json = branchesData!
            for (_, branch) in json["data"] {
                let branch_id = branch["branch_id"].int
                let company_id = branch["company_id"].int
                let latitude = branch["latitude"].double
                let longitude = branch["longitude"].double
                let address = branch["address"].string!
                let distance = Utilities.roundValue(branch["distance"].double!,numberOfPlaces: 1.0)
                let logo = branch["logo"].string!
                let newLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
                DispatchQueue.main.async {
                    // Drop a pin
                    let dropPin : Annotation = Annotation(coordinate: newLocation, title: branch["name"].string!, subTitle: address, branch_distance: "\(distance)", branch_id: branch_id!, company_id: company_id!, logo: logo)
                    
                    switch branch["category_id"].int! {
                    case 1: dropPin.typeOfAnnotation = "marker-food-icon"
                    case 2: dropPin.typeOfAnnotation = "marker-services-icon"
                    case 3: dropPin.typeOfAnnotation = "marker-entertainment-icon"
                    default: dropPin.typeOfAnnotation = "marker-services-icon"
                        break
                    }
                    
                    self.annotationArray.append(dropPin)
                    self.nearbyMap.addAnnotation(dropPin)
                    
                    Utilities.fadeOutViewAnimation(self.spinner!, delay: 0, duration: 0.3)
                }
            }
            },
            failure:{(branchesData)-> Void in
                Utilities.fadeOutViewAnimation(self.spinner!, delay: 0, duration: 0.3)
                DispatchQueue.main.async(execute: {
                    self.modal_alert = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                    self.modal_alert.willPresentCompletionHandler = { vc in
                        let navigation_controller = vc as! AlertModalViewController
                        navigation_controller.dismiss_button.setTitle("REINTENTAR", for: UIControlState())
                        self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error ☹️"))
                        navigation_controller.setAlert(self.alert_array)
                    }
                    self.modal_alert.present(animated: true, completionHandler: nil)
                    self.modal_alert.delegate = self
                })
        })
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "custom"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if mapView.userLocation == annotation as! NSObject { return nil }
        if (annotationView == nil) {
            annotationView = MapPin(annotation: annotation, reuseIdentifier: reuseId)
            annotationView!.canShowCallout = false
        } else {  annotationView?.annotation = annotation }
        
        let customAnnotation = annotation as! Annotation
        annotationView!.image = UIImage(named: customAnnotation.typeOfAnnotation)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let mapPin = view as? MapPin {
                currentAnnotationView = mapPin.calloutView
                let annotation = view.annotation! as! Annotation

                mapPin.calloutView?.name_label!.text = annotation.title!
                mapPin.calloutView?.address_label!.text = annotation.subtitle!
                mapPin.calloutView?.info_label!.text = "A \(annotation.distance!) km de tu ubicación actual"
                mapPin.calloutView?.button!.tag = annotation.branch_id!
                mapPin.calloutView?.button!.addTarget(self, action: #selector(NearbyMapViewController.goToBranchProfile(_:)), for: .touchUpInside)
                let imageUrl = URL(string: "\(Utilities.dopImagesURL)\(annotation.company_id!)/\(annotation.logo!)")

                mapPin.calloutView?.branch_image.alpha = 0
                mapPin.calloutView?.branch_image.image = UIImage(named: "dop-logo-transparent")
                mapPin.calloutView?.branch_image.alpha = 0.3
            
                Alamofire.request(imageUrl!).responseImage { response in
                    if let image = response.result.value{
                        mapPin.calloutView?.branch_image.image = image;                            Utilities.fadeInViewAnimation((mapPin.calloutView?.branch_image)!, delay:0, duration:0.8)
                    }
                }
                updatePinPosition(mapPin)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        currentAnnotationView!.removeFromSuperview()
    }
    
    func goToBranchProfile(_ sender: UIButton) {
        let view_controller = self.storyboard!.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
        view_controller.branch_id = sender.tag
        self.navigationController?.pushViewController(view_controller, animated: true)
    }


    func updatePinPosition(_ pin:MapPin) {
        let defaultShift:CGFloat = 10
        let pinPosition = CGPoint(x: pin.frame.midX, y: pin.frame.maxY)
        
        let y = pinPosition.y - defaultShift
        
        let controlPoint = CGPoint(x: pinPosition.x, y: y)
        let controlPointCoordinate = nearbyMap.convert(controlPoint, toCoordinateFrom: nearbyMap)
        
        nearbyMap.setCenter(controlPointCoordinate, animated: true)
    }
    
    func pressActionButton(_ modal: ModalViewController) {
        modal_alert.dismiss(animated: true, completionHandler: { (modal) -> Void in
            DispatchQueue.main.async(execute: {
                self.getNearestBranches()
            })
        })
    }
    
    @IBAction func askPermission(_ sender: UIButton) {
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways  {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            setNearbyMap()
        }
    }
    
    func setNearbyMap() {
        self.giverView.isHidden = true
        Utilities.filterArray.removeAll()

        spinner = MMMaterialDesignSpinner(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        spinner.center.x = self.view.center.x
        spinner.center.y = self.view.center.y - 70.0
        spinner.layer.cornerRadius = spinner.frame.width / 2
        spinner.lineWidth = 3.0
        spinner.startAnimating()
        spinner.tintColor = Utilities.dopColor
        spinner.backgroundColor = UIColor.white
        self.view.addSubview(spinner)
        spinner?.startAnimating()
        
        NotificationCenter.default.addObserver(self, selector: #selector(NearbyMapViewController.getNearestBranches), name: NSNotification.Name(rawValue: "filtersChanged"), object: nil)
        
        locationManager.startUpdatingLocation()
        User.coordinate = locationManager.location!.coordinate
        
        if self.revealViewController() != nil {
            filterSidebarButton = UIBarButtonItem(image: UIImage(named: "filter"), style: UIBarButtonItemStyle.plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            self.nearbyMap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NearbyMapViewController.tapMap)))
            self.navigationItem.leftBarButtonItem = filterSidebarButton
        }
        
        let locationArrow:UIImageView = UIImageView(image: UIImage(named: "locationArrow")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        currentLocationLbl.setImage(locationArrow.image, for: UIControlState())
        currentLocationLbl.tintColor = Utilities.dopColor
        currentLocationLbl.backgroundColor = UIColor.white
        
        if UIScreen.main.bounds.width == 320 { self.little_size = true }
        setMapAtCurrent()
        getNearestBranches()
    }
    
    
    
}
