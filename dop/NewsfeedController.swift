//
//  NewsfeedController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NewsfeedController: NSObject {
    class func getAllFriendsTakingCouponsWithSuccess(success succeed: ((friendsData: NSData!) -> Void),failure errorFound: ((friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/used/get/user"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(friendsData: urlData)
            } else {
                errorFound(friendsData: error)
            }
        })
    }
    class func getAllFriendsTakingCouponsOffsetWithSuccess(client_coupon_id:Int, offset:Int,success succeed: ((friendsData: NSData!) -> Void),failure errorFound: ((friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/used/get/user/offset/?offset=\(offset)&client_coupon_id=\(client_coupon_id)"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(friendsData: urlData)
            } else {
                errorFound(friendsData: error)
            }
        })
    }
    
    class func likeFriendsActivityWithSuccess(params:[String:AnyObject],success succeed: ((friendsData: NSData!) -> Void),failure errorFound: ((friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/used/like"
        print(url)
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(friendsData: urlData)
            } else {
                errorFound(friendsData: error)
            }
        })
    }
    
}
