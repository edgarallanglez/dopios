//
//  NewsfeedController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire

class NewsfeedController: NSObject {
    class func getAllFriendsTakingCouponsWithSuccess(success succeed: @escaping ((_ friendsData: JSON?) -> Void),failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/used/get/user"

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
    
    class func getAllFriendsTakingCouponsOffsetWithSuccess(_ params: Parameters, success succeed: @escaping ((_ friendsData: JSON?) -> Void),failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/used/get/user/offset"
        
       /* Utilities.sendDataToURL(URL(string: url)!, method: "POST", params: params, completion:{(data, error) -> Void in
                if let urlData = data {
                    succeed(urlData)
                } else {
                    errorFound(error)
                }
            })*/
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func likeFriendsActivityWithSuccess(_ params: Parameters,success succeed: @escaping ((_ friendsData: JSON?) -> Void),failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/used/like"
        print(url)
        /*Utilities.sendDataToURL(URL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            } else {
                errorFound(error)
            }
        })*/
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
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
