//
//  FriendsController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class FriendsController: NSObject {
    class func getAllFriendsWithSuccess(success: ((friendsData: NSData!) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(friendsData: urlData)
            }
        })
    }
    
    class func deleteFriend(params:[String:AnyObject], success: ((couponsData: NSData!) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/delete"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"PUT",params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(couponsData: urlData)
            }
        })
    }
}
