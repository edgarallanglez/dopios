//
//  User.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 13/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class User: NSObject, CLLocationManagerDelegate {
    static var userToken:String = ""
    static var userEmail:String = ""
    static var userName:String = ""
    static var userImageUrl:String = ""
    static var loginType = ""
    static var activeSession = false
    static var userSurnames = ""
    static var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
}
