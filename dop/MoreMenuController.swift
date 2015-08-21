//
//  MoreMenuController.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/20/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class MoreMenuController {
    class func getImage(url:String, success: ((imageData: NSData!) -> Void)) {
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(imageData: urlData)
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
