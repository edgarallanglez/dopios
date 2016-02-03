//
//  Branch.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 21/09/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class Branch: NSObject {
    let id:Int
    let name:String
    let logo: String
    let banner:String
    let company_id: Int
    var total_likes: Int
    var user_like: Int
    let location: CLLocationCoordinate2D
    let following: Bool
    
    init(id: Int?, name: String?,  logo: String? ,banner: String?, company_id: Int?, total_likes: Int?, user_like: Int?, latitude: Double, longitude: Double, following: Bool) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.logo = logo ?? ""
        self.banner = banner ?? ""
        self.company_id = company_id ?? 0
        self.total_likes = total_likes ?? 0
        self.user_like = user_like ?? 0
        self.location = CLLocationCoordinate2DMake(latitude, longitude) ?? CLLocationCoordinate2DMake(0.0, 0.0)
        self.following = following
    }
}
