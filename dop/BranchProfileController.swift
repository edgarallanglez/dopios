//
//  BranchProfileController.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/10/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class BranchProfileController {
    
    class func getBranchProfileWithSuccess(branchId: Int, success: ((branchData: NSData!) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/\(branchId)/profile/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion: {(data, error) -> Void in
            if let urlData = data {
                success(branchData: urlData)
            }
        })
    }
    
    class func getBranchCouponTimeline(branchId: Int, success: ((branchData: NSData!) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/\(branchId)/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion: {(data, error) -> Void in
            if let urlData = data {
                success(branchData: urlData)
            }
        })
    }
    
    class func likeBranchWithSuccess(params: [String:AnyObject], success succeed: ((branchData: NSData!) -> Void),failure errorFound: ((branchData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/like"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion: {(data, error) -> Void in
            if let urlData = data {
                succeed(branchData: urlData)
            }else{
                errorFound(branchData: error)
            }
        })
    }
}