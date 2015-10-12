//
//  BranchProfileController.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/10/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class DashboardController {
    
    class func getDashboardBranchesWithSuccess(success succeed: ((branchData: NSData!) -> Void), failure errorFound:((branchData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)company/branch/dashboard"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion: {(data, error) -> Void in
            if let urlData = data {
                succeed(branchData: urlData)
            }else{
                errorFound(branchData: error)
            }
        })
    }
    
    class func getTrendingCouponsWithSuccess(success succeed: ((couponsData: NSData!) -> Void), failure errorFound:((couponsData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)coupon/trending/get/"
        print(url)
        Utilities.loadDataFromURL(NSURL(string: url)!, completion: {(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    class func getAlmostExpiredCouponsWithSuccess(success succeed: ((couponsData: NSData!) -> Void), failure errorFound:((couponsData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)coupon/almost/expired/get/"
        print(url)
        Utilities.loadDataFromURL(NSURL(string: url)!, completion: {(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func getNearestCoupons(params:[String:AnyObject], success succeed: ((branchesData: NSData!) -> Void),failure errorFound: ((branchesData: NSError?) -> Void)) {
        let latitude: AnyObject! = params["latitude"]
        let longitude: AnyObject! = params["longitude"]
        let radio: AnyObject! = params["radio"]
        print(latitude, longitude, radio)
        let url = "\(Utilities.dopURL)coupon/nearest/get/?latitude=\(latitude)&longitude=\(longitude)&radio=\(radio)"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(branchesData: urlData)
            }else{
                errorFound(branchesData: error)
            }
        })
    }
    
}