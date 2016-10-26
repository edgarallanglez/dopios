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
    let about: String?
    let phone: String?
    let adults_only: Bool?
    let address: String?
    
    init(id: Int?, name: String?,  logo: String? ,banner: String?, company_id: Int?, latitude: Double, longitude: Double, following: Bool) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.banner = banner ?? ""
        self.company_id = company_id ?? 0
        self.location = CLLocationCoordinate2DMake(latitude, longitude) ?? CLLocationCoordinate2DMake(0.0, 0.0)
        self.following = following
        
        self.about = nil
        self.phone = nil
        self.distance = nil
        self.logo = nil
        self.adults_only = nil
        self.address = nil
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
        self.about = nil
        self.phone = nil
        self.adults_only = nil
        self.address = nil
    }
    
    init(id: Int?, name: String?, banner: String?, company_id: Int?, adults_only: Bool?) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.banner = banner ?? ""
        self.company_id = company_id ?? 0
        self.adults_only = adults_only ?? false
        
        self.distance = nil
        self.location = nil
        self.logo = nil
        self.following = nil
        self.about = nil
        self.phone = nil
        self.address = nil
    }
    
    init(id: Int?, name: String?, distance: Double!) {
        self.id = id ?? 0
        self.name = name ?? ""
        
        if distance == 0.0 { self.distance = String(stringInterpolationSegment: "") } else { self.distance = String(stringInterpolationSegment: "A \(distance!) Km") }
        
        self.logo = nil
        self.banner = nil
        self.company_id = nil
        self.location = nil
        self.following = nil
        self.about = nil
        self.phone = nil
        self.adults_only = nil
        self.address = nil
    }
    
    init(id: Int?, name: String?, banner: String?, company_id: Int?, logo: String!, following: Bool!, about: String?, phone: String?, adults_only: Bool?, address: String?) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.banner = banner ?? ""
        self.company_id = company_id ?? 0
        self.logo = logo
        self.following = following
        self.about = about
        self.phone = phone
        self.adults_only = adults_only
        self.address = address
        
        self.distance = nil
        self.location = nil
    }
}
