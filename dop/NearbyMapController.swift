//
//  NearbyMapController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/29/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class NearbyMapController {
    
//    class func getNearestBranches(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radio: Int, success: ((branchesData: NSData!) -> Void)) {
//
//        let url = "http://104.236.141.44:5000/api/company/branch/nearest/\(latitude)/\(longitude)/\(radio)/all"
//        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
//            if let urlData = data {
//                success(branchesData: urlData)
//            }
//        })
//    }
    
    class func getNearestBranches(params:[String:AnyObject], success: ((branchesData: NSData!) -> Void)) {
        let latitude: AnyObject! = params["latitude"]
        let longitude: AnyObject! = params["longitude"]
        let radio: AnyObject! = params["radio"]
        println(latitude, longitude, radio)
        let url = "\(Utilities.dopURL)company/branch/nearest/?latitude=\(latitude)&longitude=\(longitude)&radio=\(radio)"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(branchesData: urlData)
                
            }
        })
    }

    
}