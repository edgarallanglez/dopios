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
    let folio: String!
    let category_id: Int!
    let subcategory_id: Int!
    let facebook_url: String?
    let instagram_url: String?
    
    init(id: Int?, name: String?,  logo: String? ,banner: String?, company_id: Int?, latitude: Double, longitude: Double, following: Bool, folio: String!) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.banner = banner ?? ""
        self.company_id = company_id ?? 0
        self.location = CLLocationCoordinate2DMake(latitude, longitude) 
        self.following = following
        self.folio = folio
        
        self.about = nil
        self.phone = nil
        self.distance = nil
        self.logo = nil
        self.adults_only = nil
        self.address = nil
        self.category_id = nil
        self.facebook_url = nil
        self.instagram_url = nil
        self.subcategory_id = nil
    }
    
    init(id: Int?, name: String?, banner: String?, company_id: Int?, folio: String!) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.banner = banner ?? ""
        self.company_id = company_id ?? 0
        self.folio = folio
        
        self.distance = nil
        self.location = nil
        self.logo = nil
        self.following = nil
        self.about = nil
        self.phone = nil
        self.adults_only = nil
        self.address = nil
        self.facebook_url = nil
        self.instagram_url = nil
        self.category_id = nil
        self.subcategory_id = nil
    }
    
    init(id: Int?, name: String?, banner: String?, company_id: Int?, adults_only: Bool?, folio: String!) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.banner = banner ?? ""
        self.company_id = company_id ?? 0
        self.adults_only = adults_only ?? false
        self.folio = folio
        
        self.distance = nil
        self.location = nil
        self.logo = nil
        self.following = nil
        self.about = nil
        self.phone = nil
        self.address = nil
        self.category_id = nil
        self.subcategory_id = nil
        self.facebook_url = nil
        self.instagram_url = nil
    }
    
    init(id: Int?, name: String?, distance: Double!, folio: String!) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.folio = folio
        
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
        self.category_id = nil
        self.subcategory_id = nil
        self.facebook_url = nil
        self.instagram_url = nil
    }
    
    init(id: Int?, name: String?, banner: String?, company_id: Int?, logo: String!, following: Bool!, about: String?, phone: String?, adults_only: Bool?, address: String?, folio: String!) {
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
        self.folio = folio
        
        self.distance = nil
        self.location = nil
        self.category_id = nil
        self.facebook_url = nil
        self.instagram_url = nil
        self.subcategory_id = nil
    }
    
    init(id: Int?, name: String?, banner: String?, company_id: Int?, logo: String!, following: Bool!, about: String?, phone: String?, adults_only: Bool?, address: String?, folio: String!, category_id: Int!, subcategory_id: Int!, location: CLLocationCoordinate2D) {
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
        self.folio = folio
        self.category_id = category_id
        self.subcategory_id = subcategory_id
        self.location = location
        
        self.distance = nil
        self.facebook_url = nil
        self.instagram_url = nil
    }
    
    init(model: JSON) {
        self.id = model["branch_id"].int!
        let latitude = model["latitude"].double!
        let longitude = model["longitude"].double!
        self.following = model["following"].bool!
        self.name = model["name"].string!
        self.company_id = model["company_id"].int
        self.banner = model["banner"].string
        self.logo = model["logo"].string!
        self.about = model["about"].string ?? ""
        self.phone = model["phone"].string ?? ""
        self.adults_only = model["adults_only"].bool ?? false
        self.address = model["address"].string ?? ""
        self.folio = model["folio"].string!
        self.category_id = model["category_id"].int!
        self.subcategory_id = model["subcategory_id"].int!
        self.facebook_url = model["facebook_url"].string ?? ""
        self.instagram_url = model["instagram_url"].string ?? ""
        
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        self.distance = nil
    }
}
