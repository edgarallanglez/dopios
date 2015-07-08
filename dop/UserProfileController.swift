//
//  UserProfileController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 20/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class UserProfileController: NSObject {
    class func getImage(url:String, success: ((couponsData: NSData!) -> Void)) {
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(couponsData: urlData)
            }
        })
    }
    class func getUserProfile(url:String, success: ((profileData: NSData!) -> Void)) {
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(profileData: urlData)
            }
        })
    }
}
