//
//  Annotation.swift
//  dop
//
//  Created by Edgar Allan Glez on 9/22/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
    var currentLocation: CLLocationCoordinate2D
    var _title : String
    var subTitle : String
    var direction : CLLocationDirection!
    var typeOfAnnotation : String!
    var branch_distance: String?
    
    init(coordinate: CLLocationCoordinate2D, title : String, subTitle : String, branch_distance: String) {
        self.currentLocation = coordinate
        self._title = title
        self.subTitle = subTitle
        self.branch_distance = branch_distance
    }
    
    func getLocation() -> CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    var coordinate: CLLocationCoordinate2D {
        return self.currentLocation
    }
    
    var title: String? {
        return self._title
    }
    
    var subtitle: String? {
        return self.subTitle
    }
    
    var distance: String? {
        return self.branch_distance
    }
    
}