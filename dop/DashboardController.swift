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
    
}