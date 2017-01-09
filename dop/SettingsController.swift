//
//  SettingsController.swift
//  dop
//
//  Created by Edgar Allan Glez on 11/12/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import Alamofire

class SettingsController {
    class func setPrivacyWithSuccess(_ url: String, params: [String:AnyObject], success succeed: @escaping ((_ data: JSON?) -> Void),failure errorFound: @escaping ((_ data: NSError?) -> Void)) {
        
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
