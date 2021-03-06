//
//  User.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 13/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class User: NSObject, CLLocationManagerDelegate {
    static var userToken: [String: String] = [:]
    
    static var user_id: Int = 0
    static var userEmail:String = ""
    static var userName:String = ""
    static var privacy_status: Int = 0
    static var userImageUrl:String = ""
    static var loginType = ""
    static var activeSession = false
    static var userSurnames = ""
    static var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    static var newNotification: Bool = false
    static var deviceToken: String = ""
    static var adult: Bool = false
    static var first_following: Bool = false
    static var first_follower: Bool = false
    static var first_company_fav: Bool = false
    static var first_using: Bool = false
    
    static var newestNotification: [String: AnyObject] = [:]
    
    
}
