//
//  FriendsController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire

class FriendsController: NSObject {
    class func getAllFriendsWithSuccess(success succeed: @escaping ((_ friendsData: JSON?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/get"

        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func deleteFriend(_ params:[String:AnyObject], success: @escaping ((_ friendsData: JSON?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/delete"

        
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                success(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func addFriendWithSuccess(_ params: Parameters, success: @escaping ((_ friendsData: JSON?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/add"
        print(url)

        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                success(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    class func acceptFriendWithSuccess(_ params: Parameters, success: @escaping ((_ friendsData: JSON?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/accept"
        print(url)

        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                success(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    class func declineFriendWithSuccess(_ params:[String:AnyObject], success: @escaping ((_ friendsData: JSON?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/decline"

        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                success(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    class func getAllFollowingWithSuccess(success succeed: @escaping ((_ friendsData: JSON?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/following/get"

        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }

}
