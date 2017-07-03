//
//  readQRController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 23/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import Alamofire

class ReadQRController{
    class func sendQRWithSuccess(_ params:[String: AnyObject],
                                   success succeed: @escaping ((_ data: JSON?) -> Void),
                                   failure error_found: @escaping ((_ error_data: Error?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/user/redeem"
        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: User.userToken).validate()
            .responseJSON { response in
                switch response.result {
                    case .success:
                        succeed(JSON(response.result.value!))
                    case .failure(let error):
                        error_found(error as Error)
                }
        }
    }
    
    class func setActivityPrivacy(_ params:[String: AnyObject],
                                    success succeed: @escaping ((_ data: JSON?) -> Void),
                                    failure error_found: @escaping ((_ error_data: Error?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/user/privacy"
        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: User.userToken).validate()
            .responseJSON { response in
                switch response.result {
                    case .success:
                        succeed(JSON(response.result.value!))
                    case .failure(let error):
                        error_found(error as Error)
                }
        }
    }
    
    class func sendReport(_ url: String,
                            params: [String: AnyObject],
                            success succeed: @escaping ((_ report_data: JSON?) -> Void),
                            failure error_found: @escaping ((_ error_data: Error?) -> Void)) {
        
        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: User.userToken).validate()
                 .responseJSON { response in
                    switch response.result {
                        case .success:
                            succeed(JSON(response.result.value!))
                        case .failure(let error):
                            error_found(error as Error)
                    }
                 }
    }
}
