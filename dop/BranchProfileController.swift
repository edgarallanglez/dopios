//
//  BranchProfileController.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/10/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class BranchProfileController {
    
    class func getAllCouponsWithSuccess(success: ((couponsData: NSData!) -> Void)) {
        let url = "http://104.236.141.44:5000/api/coupon/all/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(couponsData: urlData)
            }
        })
    }
}