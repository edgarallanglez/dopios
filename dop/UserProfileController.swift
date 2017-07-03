//
//  UserProfileController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 20/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire

class UserProfileController: NSObject {
    /*class func getImage(_ url:String, success: @escaping ((_ couponsData: JSON?) -> Void)) {
        /*Utilities.loadDataFromURL(URL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(urlData)
            }
        })
        
        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }*/
    }*/
    class func getUserProfile(_ user_id: Int, success succeed: @escaping ((_ profileData: JSON?) -> Void), failure errorFound: @escaping ((_ profileData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/\(user_id)/profile"
        
        
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

    class func getAllTakingCouponsWithSuccess(_ user_id: Int, limit: Int, success succeed: @escaping ((_ friendsData: JSON?) -> Void), failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/activity/get/user/?user_profile_id=\(user_id)&limit=\(limit)"

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

    class func getAllTakingCouponsOffsetWithSuccess(_ params: Parameters, success succeed: @escaping ((_ friendsData: JSON?) -> Void),failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/activity/get/user/offset"

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

    class func followFriendWithSuccess(_ params: Parameters, success succeed: @escaping ((_ data: JSON?) -> Void), failure errorFound: @escaping ((_ data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/add"

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

    class func unfollowFriendWithSuccess(_ params: Parameters, success succeed: @escaping ((_ data: JSON?) -> Void), failure errorFound: @escaping ((_ data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)user/friends/unfollow"
        
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

    class func getAllBranchesFollowedWithSuccess(_ user_id: Int, success succeed: @escaping ((_ data: JSON?) -> Void), failure errorFound: @escaping ((_ data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/\(user_id)/following/get"

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

    class func getAllBranchesFollowedOffsetWithSuccess(_ user_id: Int, last_branch: Int, offset: Int, success succeed: @escaping ((_ data: JSON?) -> Void), failure errorFound: @escaping ((_ data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/\(user_id)/following/\(last_branch)/\(offset)/get"

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
    
    class func sendPushNotification(_ params: Parameters, success succeed: @escaping ((_ data: JSON?) -> Void), failure errorFound: @escaping ((_ data: Error?) -> Void)) {
        let url = "\(Utilities.dopURL)notification/push/follow"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error)
            }
        }
        
    }
    
    class func sendLikePushNotification(_ params: Parameters, success succeed: @escaping ((_ data: JSON?) -> Void), failure errorFound: @escaping ((_ data: Error?) -> Void)) {
        let url = "\(Utilities.dopURL)notification/push/like"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error)
            }
        }
        
    }
    
    class func getAlikePeople(_ user_id: Int, success succeed: @escaping ((_ data: JSON?) -> Void), failure errorFound: @escaping ((_ data: Error?) -> Void)) {
            let url = "\(Utilities.dopURL)user/\(user_id)/similar/people"
            
            Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: User.userToken).validate().responseJSON { response in
                switch response.result {
                case .success:
                    succeed(JSON(response.result.value))
                case .failure(let error):
                    print(error)
                    errorFound(error as Error)
                }
            }

    }
}
