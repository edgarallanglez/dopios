//
//  BranchProfileAboutView.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/6/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit


class BranchProfileAboutView: UITableViewCell, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var branchLocationMap: MKMapView!
    @IBOutlet weak var branchDescription: UITextView!
    @IBOutlet weak var pinIcon: UIImageView!
    @IBOutlet weak var clockIcon: UIImageView!
    var branchPin: CLLocation!

    let regionRadius: CLLocationDistance = 500
    
    var index: Int = 0
    
    func loadAbout(description: String) {
        branchDescription.text = description
        pinIcon.image = pinIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        pinIcon.tintColor = UIColor.lightGrayColor()
        clockIcon.image = clockIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        clockIcon.tintColor = UIColor.lightGrayColor()
        
        self.branchLocationMap.delegate = self
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                regionRadius * 2.0, regionRadius * 2.0)
        branchLocationMap.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "custom"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
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
