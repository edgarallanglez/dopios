//
//  FriendsController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class FriendsController: NSObject {
    class func getAllFriendsWithSuccess(success succeed: ((friendsData: NSData!) -> Void), failure errorFound: ((friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(friendsData: urlData)
            }else{
                errorFound(friendsData: error)
            }
        })
    }
    
    class func deleteFriend(params:[String:AnyObject], success: ((friendsData: NSData!) -> Void), failure errorFound: ((friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/delete"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"PUT",params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(friendsData: urlData)
            }else{
                errorFound(friendsData: error)
            }
        })
    }
    
    class func addFriendWithSuccess(params:[String:AnyObject], success: ((friendsData: NSData!) -> Void), failure errorFound: ((friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/add"
        print(url)
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(friendsData: urlData)
            }else{
                errorFound(friendsData: error)
            }
        })
    }
    
    class func getAllFollowingWithSuccess(success succeed: ((friendsData: NSData!) -> Void), failure errorFound: ((friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/following/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(friendsData: urlData)
            }else{
                errorFound(friendsData: error)
            }
        })
    }

}
