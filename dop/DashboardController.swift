//
//  BranchProfileController.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/10/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class DashboardController {
    
    class func getDashboardBranchesWithSuccess(success: ((branchData: NSData!) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/dashboard"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion: {(data, error) -> Void in
            if let urlData = data {
                success(branchData: urlData)
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
    
/*    class func getTrendingCouponsWithSuccess(success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/trending/get"

        Utilities.getDataFromUrl(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(friendsData: urlData)
            }else{
                errorFound(friendsData: error)
            }
        })
    }
*/
    
}