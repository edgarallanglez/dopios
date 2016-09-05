//
//  UserProfileController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 20/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class UserProfileController: NSObject {
    class func getImage(url:String, success: ((couponsData: NSData!) -> Void)) {
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(couponsData: urlData)
            }
        })
    }
    class func getUserProfile(user_id: Int, success succeed: ((profileData: NSData!) -> Void), failure errorFound: ((profileData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/\(user_id)/profile"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(profileData: urlData)
            }else{
                errorFound(profileData: error)
            }
        })
    }

/*    class func getAllUsedCouponsWithSuccess(limit: Int, success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/used/for/myself/get/?limit=\(limit)"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }

    class func getAllUsedCouponsOffsetWithSuccess(coupon_id: Int, offset: Int, success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/used/for/myself/offset/get/?offset=\(offset)&coupon_id=\(coupon_id)"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }*/

    class func getAllTakingCouponsWithSuccess(user_id: Int, limit: Int, success succeed: ((friendsData: NSData!) -> Void), failure errorFound: ((friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/activity/get/user/?user_profile_id=\(user_id)&limit=\(limit)"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(friendsData: urlData)
            } else {
                errorFound(friendsData: error)
            }
        })
    }

    class func getAllTakingCouponsOffsetWithSuccess(params:[String:AnyObject], success succeed: ((friendsData: NSData!) -> Void),failure errorFound: ((friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/activity/get/user/offset"

        Utilities.sendDataToURL(NSURL(string: url)!, method: "POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(friendsData: urlData)
            } else {
                errorFound(friendsData: error)
            }
        })
    }

    class func followFriendWithSuccess(params: [String:AnyObject], success succeed: ((data: NSData!) -> Void), failure errorFound: ((data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/add"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(data: urlData)
            }else{
                errorFound(data: error)
            }
        })
    }

    class func unfollowFriendWithSuccess(params: [String:AnyObject], success succeed: ((data: NSData!) -> Void), failure errorFound: ((data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/unfollow"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(data: urlData)
            }else{
                errorFound(data: error)
            }
        })
    }

    class func getAllBranchesFollowedWithSuccess(user_id: Int, success succeed: ((data: NSData!) -> Void), failure errorFound: ((data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/\(user_id)/following/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(data: urlData)
            } else {
                errorFound(data: error)
            }
        })
    }

    class func getAllBranchesFollowedOffsetWithSuccess(user_id: Int, last_branch: Int, offset: Int, success succeed: ((data: NSData!) -> Void), failure errorFound: ((data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/\(user_id)/following/\(last_branch)/\(offset)/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(data: urlData)
            } else {
                errorFound(data: error)
            }
        })
    }
}
