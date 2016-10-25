//
//  FriendsController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class FriendsController: NSObject {
    class func getAllFriendsWithSuccess(success succeed: @escaping ((_ friendsData: Data?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/get"
        Utilities.loadDataFromURL(URL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            }else{
                errorFound(error)
            }
        })
    }
    
    class func deleteFriend(_ params:[String:AnyObject], success: @escaping ((_ friendsData: Data?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/delete"
        Utilities.sendDataToURL(URL(string: url)!, method:"PUT",params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(urlData)
            }else{
                errorFound(error)
            }
        })
    }
    
    class func addFriendWithSuccess(_ params:[String:AnyObject], success: @escaping ((_ friendsData: Data?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/add"
        print(url)
        Utilities.sendDataToURL(URL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(urlData)
            }else{
                errorFound(error)
            }
        })
    }
    class func acceptFriendWithSuccess(_ params:[String:AnyObject], success: @escaping ((_ friendsData: Data?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/accept"
        print(url)
        Utilities.sendDataToURL(URL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(urlData)
            } else {
                errorFound(error)
            }
        })
    }
    class func declineFriendWithSuccess(_ params:[String:AnyObject], success: @escaping ((_ friendsData: Data?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/decline"
        print(url)
        Utilities.sendDataToURL(URL(string: url)!, method:"PUT", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(urlData)
            } else {
                errorFound(error)
            }
        })
    }
    class func getAllFollowingWithSuccess(success succeed: @escaping ((_ friendsData: Data?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/following/get"
        Utilities.loadDataFromURL(URL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            }else{
                errorFound(error)
            }
        })
    }

}
