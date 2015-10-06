//
//  TodayController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class TodayController: NSObject {
    class func getDashboardBranchesWithSuccess(success: ((branchData: NSData!) -> Void)) {
        let url = "\(WidgetUtilities.dopURL)company/branch/dashboard"
        WidgetUtilities.loadDataFromURL(NSURL(string: url)!, completion: {(data, error) -> Void in
            if let urlData = data {
                success(branchData: urlData)
            }
        })
    }
}
