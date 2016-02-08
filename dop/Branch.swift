//
//  Branch.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 21/09/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
struct Branch {
    let id:Int
    let name:String
    let logo: String?
    let banner:String?
    let company_id: Int?
    let location: CLLocationCoordinate2D?
    let following: Bool?
    let distance:String?
    
    init(id: Int?, name: String?,  logo: String? ,banner: String?, company_id: Int?, latitude: Double, longitude: Double, following: Bool) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.banner = banner ?? ""
        self.company_id = company_id ?? 0
        self.location = CLLocationCoordinate2DMake(latitude, longitude) ?? CLLocationCoordinate2DMake(0.0, 0.0)
        self.following = following
        
        self.distance = nil
        self.logo = nil
    }
    
    init(id: Int?, name: String?, banner: String?, company_id: Int?) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.banner = banner ?? ""
        self.company_id = company_id ?? 0
        
        self.distance = nil
        self.location = nil
        self.logo = nil
        self.following = nil
    }
    
    init(id: Int?, name: String?, distance: Double!) {
        self.id = id ?? 0
        self.name = name ?? ""
        if(distance == 0.0){
            self.distance = String(stringInterpolationSegment: "")
        }else{
            self.distance = String(stringInterpolationSegment: "A \(distance) Km")
        }
        
        self.logo = nil
        self.banner = nil
        self.company_id = nil
        self.location = nil
        self.following = nil
    }
}
