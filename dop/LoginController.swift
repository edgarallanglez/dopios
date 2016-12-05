//
//  LoginController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 14/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import Alamofire

class LoginController {
    
    class func loginWithSocial(_ url: String, params: [String:AnyObject], success succeed: @escaping ((_ loginData: JSON?) -> Void),failure errorFound: @escaping ((_ loginData: NSError?) -> Void)) {

        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
        
    }
    class func getPrivacyInfo(success succeed: @escaping ((_ userData: JSON?) -> Void), failure errorFound:@escaping ((_ userData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)user/flags/get"

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
