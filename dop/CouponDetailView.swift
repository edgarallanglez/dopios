//
//  CouponDetailView.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit
class CouponDetailView: UIView, MKMapViewDelegate {

    @IBOutlet var branch_cover: UIImageView!
    @IBOutlet var branch_category: UILabel!
    @IBOutlet var location: MKMapView!
    @IBOutlet weak var couponsName: UIButton!
    @IBOutlet weak var couponsDescription: UITextView!


    
    var couponId: Int!
    var branchId: Int!
    var categoryId: Int!
    
    var coordinate: CLLocationCoordinate2D?

    var viewController: UIViewController?
    let regionRadius: CLLocationDistance = 1000
    
    var readQRView: ReadQRViewController?
    
    @IBAction func triggerSegue(_ sender: UIButton) {
        self.viewController!.performSegue(withIdentifier: "branchProfile", sender: self)
    }
    
    func loadView(_ viewController: UIViewController) {
        self.viewController = viewController
        self.location.delegate = self
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        readQRView = storyboard.instantiateViewController(withIdentifier: "readQRView") as! ReadQRViewController
    }
    
    func centerMapOnLocation(_ location: CLLocationCoordinate2D) {
        let centerPin = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(centerPin.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        self.location.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func dopixCoupon(_ sender: UIButton) {
        /*let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let folioDate = dateFormatter.stringFromDate(NSDate())
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let date = dateFormatter.stringFromDate(NSDate())
        
        let params:[String: AnyObject] = [
            "coupon_id" : self.couponId,
            "branch_id": self.branchId,
            "taken_date" : date,
            "folio_date": folioDate,
            "latitude": coordinate?.latitude ?? 0,
            "longitude": coordinate?.longitude ?? 0]
        
        
        CouponController.takeCouponWithSuccess(params,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: couponsData)
                    print(json)
                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    print(error)
                })
            }
        )*/
        
        //self.viewController!.performSegueWithIdentifier("readQR", sender: self)
        
        readQRView?.coupon_id = 5
        self.viewController!.present(readQRView!,
            animated: true,
            completion: nil)
                
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "custom"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if mapView.userLocation == annotation as! NSObject { return nil }
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView!.canShowCallout = true
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let customAnnotation = annotation as! Annotation
        annotationView!.image = UIImage(named: customAnnotation.typeOfAnnotation)
        
        return annotationView
    }
    
  
}
