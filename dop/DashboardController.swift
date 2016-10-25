//
//  BranchProfileController.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/10/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import Alamofire

class DashboardController {
    
    class func getDashboardBranchesWithSuccess(success succeed: @escaping ((_ branchData: JSON?) -> Void), failure errorFound:@escaping ((_ branchData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)company/branch/dashboard"

        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func getTrendingCouponsWithSuccess(success succeed: @escaping ((_ couponsData: JSON?) -> Void), failure errorFound:@escaping ((_ couponsData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)coupon/trending/get/"

    
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    class func getAlmostExpiredCouponsWithSuccess(success succeed: @escaping ((_ couponsData: JSON?) -> Void), failure errorFound:@escaping ((_ couponsData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)coupon/almost/expired/get/"
        print(url)

        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func getNearestCoupons(_ params: Parameters, success succeed: @escaping ((_ branchesData: JSON?) -> Void),failure errorFound: @escaping ((_ branchesData: NSError?) -> Void)) {

        let url = "\(Utilities.dopURL)coupon/nearest/get/?latitude=\(params["latitude"]!)&longitude=\(params["longitude"]!)&radio=\(params["radio"]!)"

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
