//
//  BranchAboutViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit

protocol AboutPageDelegate {
    func resizeAboutView(_ dynamic_height: CGFloat)
    func setFollow(_ branch: Branch)
}

class BranchAboutViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var delegate: AboutPageDelegate?
    
    @IBOutlet var phone_view: UIView!
    @IBOutlet var address_view: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var branch_location_map: MKMapView!
    @IBOutlet weak var branch_description: UITextView!
    @IBOutlet weak var pin_icon: UIImageView!
    @IBOutlet weak var clock_icon: UIImageView!
    
    var parent_view: BranchProfileStickyController!
    var branch_pin: CLLocation!
    let regions_radius: CLLocationDistance = 500
    var loader: MMMaterialDesignSpinner!
    @IBOutlet var phone: UILabel!
    
    @IBOutlet var address: UILabel!
    override func viewDidLoad() {
        setupLoader()
//        branch_description.text = description
        pin_icon.image = pin_icon.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        pin_icon.tintColor = UIColor.lightGray
        clock_icon.image = clock_icon.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        clock_icon.tintColor = UIColor.lightGray
        
        self.branch_location_map.delegate = self
        self.view.frame.size.width = UIScreen.main.bounds.width
        self.view.frame.size.height = 350
        getBranchProfile()
        
        if self.branch_location_map != nil {
            let tap_map = UITapGestureRecognizer(target: self, action: #selector(BranchAboutViewController.pressMap(_:)))
            let tap_address = UITapGestureRecognizer(target: self, action: #selector(BranchAboutViewController.pressMap(_:)))
            self.branch_location_map.addGestureRecognizer(tap_map)
            self.address_view.addGestureRecognizer(tap_address)
        }

        
    }
    
    func setupLoader(){
        loader = MMMaterialDesignSpinner(frame: CGRect(x: 0,y: 70,width: 50,height: 50))
        loader.center.x = self.view.center.x
        loader.lineWidth = 3.0
        loader.startAnimating()
        loader.tintColor = Utilities.dopColor
        self.view.addSubview(loader)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        parent_view.view.setNeedsLayout()
    }
    
    func setFrame() {
        let dynamic_height: CGFloat = 330
        delegate?.resizeAboutView(dynamic_height)
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinate_region = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regions_radius * 2.0, regions_radius * 2.0)
        branch_location_map.setRegion(coordinate_region, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuse_id = "custom"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuse_id)
        if mapView.userLocation == annotation as! NSObject { return nil }
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuse_id)
            annotationView!.canShowCallout = true
            
        } else { annotationView?.annotation = annotation }
        
        let customAnnotation = annotation as! Annotation
        annotationView!.image = UIImage(named: customAnnotation.typeOfAnnotation)
        
        return annotationView
    }

    
    func getBranchProfile() {
        BranchProfileController.getBranchProfileWithSuccess(parent_view.branch_id, success: { (data) -> Void in
            let data = data!
            var json = data["data"]
            print(json)
            json = json[0]
            let branch_id = json["branch_id"].int!
            let latitude = json["latitude"].double
            let longitude = json["longitude"].double
            let following = json["following"].bool!
            let branch_name = json["name"].string
            let company_id = json["company_id"].int
            let banner = json["banner"].string
            let logo = json["logo"].string!
            let about = json["about"].string ?? ""
            let phone = json["phone"].string ?? ""
            let adults_only = json["adults_only"].bool ?? false
            let address = json["address"].string ?? ""
            let folio = json["folio"].string!

            let model = Branch(id: branch_id, name: branch_name, banner: banner, company_id: company_id, logo: logo, following: following, about: about, phone: phone, adults_only: adults_only, address: address, folio: folio)
            
            
            self.branch_pin = CLLocation(latitude: latitude!, longitude: longitude!)
            let new_location = CLLocationCoordinate2DMake(latitude!, longitude!)
            self.centerMapOnLocation(self.branch_pin)
            
            DispatchQueue.main.async(execute: {
                let drop_pin = Annotation(coordinate: new_location, title: json["name"].string!, subTitle: "", branch_distance: "4.3", branch_id: branch_id, company_id: 0, logo: "")
                
                switch json["category_id"].int! {
                    case 0: drop_pin.typeOfAnnotation = "marker-services-icon"
                    case 1: drop_pin.typeOfAnnotation = "marker-food-icon"
                    case 2: drop_pin.typeOfAnnotation = "marker-services-icon"
                    case 3: drop_pin.typeOfAnnotation = "marker-entertainment-icon"
                default: drop_pin.typeOfAnnotation = "marker-services-icon"
                        break
                }
                self.branch_description.text = model.about
                self.phone.text = model.phone
                self.branch_location_map.addAnnotation(drop_pin)
                self.address.text = model.address
                
                
                self.phone_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BranchAboutViewController.callToBranch(_:))))

                Utilities.fadeInFromBottomAnimation(self.contentView, delay: 0, duration: 1, yPosition: 20)
                
                Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)

                self.delegate!.setFollow(model)
                
                if model.adults_only! {
                    
                }
            })
            
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    print(error)
                    Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)

                })
        })
    }
    func callToBranch(_ sender: UITapGestureRecognizer){
        UIApplication.shared.openURL(URL(string: "tel://\(phone.text!)")!)
    }
    
    func reloadWithOffset(_ parent_scroll: UICollectionView) {
        parent_scroll.finishInfiniteScroll()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.frame.size.width = UIScreen.main.bounds.width
    }
    
    func pressMap(_ sender: UITapGestureRecognizer){
        //If Google Maps is installed...
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let googleMaps = UIAlertAction(title: "Google Maps", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.openGoogleMaps()
            })
            let appleMaps = UIAlertAction(title: "Apple Maps", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.openAppleMaps()
            })
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(googleMaps)
            optionMenu.addAction(appleMaps)
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            self.openAppleMaps()
        }
    }
    
    func openGoogleMaps(){
        let customURL = "comgooglemaps://?daddr=\(self.branch_pin!.coordinate.latitude),\(self.branch_pin!.coordinate.longitude)&directionsmode=driving"
        
        UIApplication.shared.openURL(URL(string: customURL)!)
    }
    
    func openAppleMaps() {
        
        let latitute:CLLocationDegrees =  (self.branch_pin!.coordinate.latitude)
        let longitute:CLLocationDegrees =  (self.branch_pin!.coordinate.longitude)
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        //mapItem.name = "\(self.coupon!.name)"
        mapItem.openInMaps(launchOptions: options)
    }
}
