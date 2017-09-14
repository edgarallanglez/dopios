//
//  BranchProfileController.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/10/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import Alamofire

class BranchProfileController {
    
    class func getBranchProfileWithSuccess(_ branchId: Int, success: @escaping ((_ branchData: JSON?) -> Void),failure errorFound: @escaping ((_ branchData: NSError?) -> Void)) {

        let url = "\(Utilities.dopURL)company/branch/\(branchId)/profile/get"

        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                success(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func viewSocialWithSuccess(_ params:[String: AnyObject],
                                      success succeed: @escaping ((_ data: JSON?) -> Void),
                                      failure errorFound: @escaping ((_ data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/social/view"
        
        Alamofire.request(url, method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: User.userToken).validate().responseJSON { response in
                            
                            switch response.result {
                            case .success:
                                succeed(JSON(response.result.value))
                            case .failure(let error):
                                print(error)
                                errorFound(error as NSError)
                            }
        }
    }
    
    class func getBranchCouponTimeline(_ branchId: Int, success: @escaping ((_ branchData: JSON?) -> Void), failure: @escaping ((_ branchData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/\(branchId)/get"

        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                success(JSON(response.result.value))
            case .failure(let error):
                print(error)
                failure(error as NSError)
            }
        }
    }
    
    class func getBranchLoyaltyTimeline(_ branchId: Int, success: @escaping ((_ branchData: JSON?) -> Void), failure: @escaping ((_ branchData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)loyalty/\(branchId)/get"
        
        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                success(JSON(response.result.value))
            case .failure(let error):
                print(error)
                failure(error as NSError)
            }
        }
    }
    
    class func followBranchWithSuccess(_ params: Parameters, success succeed: @escaping ((_ branchData: JSON?) -> Void),failure errorFound: @escaping ((_ branchData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/follow"

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
    
    class func getBranchProfileRankingWithSuccess(_ branch_id: Int, success: @escaping ((_ data: JSON?) -> Void), failure: @escaping ((_ data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/\(branch_id)/ranking/get"
        
        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                success(JSON(response.result.value))
            case .failure(let error):
                print(error)
                failure(error as NSError)
            }
        }
    }
    
    class func getBranchProfileRankingOffsetWithSuccess(_ last_ranked_id: Int, branch_id: Int, offset: Int, success: @escaping ((_ data: JSON?) -> Void), failure: @escaping ((_ data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)company/branch/\(branch_id)/ranking/\(offset)/\(last_ranked_id)/get"

        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                success(JSON(response.result.value))
            case .failure(let error):
                print(error)
                failure(error as NSError)
            }
        }
    }
}
