//
//  TrophyController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/15/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import Alamofire

class BadgeController {
    class func getAllBadgesWithSuccess(_ user_id: Int, success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/\(user_id)/all/get"
        
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
    
    class func getAllBadgesOffsetWithSuccess(_ user_id: Int, last_badge: Int, offset: Int, success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/\(user_id)/all/\(last_badge)/\(offset)/get"
        
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
    
    class func getAllTrophiesWithSuccess(success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/all/trophy/get"
        
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
    
    class func getAllMedalsWithSuccess(success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/all/medal/get"

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
