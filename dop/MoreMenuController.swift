//
//  MoreMenuController.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/20/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import Alamofire

class MoreMenuController {
    
    class func getUserProfile(_ url:String, success: @escaping ((_ profileData: JSON?) -> Void)) {

        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            default:
                success(JSON(response.result.value))
            }
        }
    }
}
