//
//  NewsfeedController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NewsfeedController: NSObject {
    class func getAllFriendsTakingCouponsWithSuccess(success: ((friendsData: NSData!) -> Void)) {
        let url = "http://45.55.7.118:5000/api/coupon/used/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(friendsData: urlData)
            }
        })
    }
    
}
