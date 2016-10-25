//
//  TrophyController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/15/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class BadgeController {
    class func getAllBadgesWithSuccess(_ user_id: Int, success succeed: @escaping ((_ couponsData: Data?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/\(user_id)/all/get"
        
        Utilities.loadDataFromURL(URL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            }else{
                errorFound(error)
            }
        })
    }
    
    class func getAllBadgesOffsetWithSuccess(_ user_id: Int, last_badge: Int, offset: Int, success succeed: @escaping ((_ couponsData: Data?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/\(user_id)/all/\(last_badge)/\(offset)/get"
        
        Utilities.loadDataFromURL(URL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            }else{
                errorFound(error)
            }
        })
    }
    
    class func getAllTrophiesWithSuccess(success succeed: @escaping ((_ couponsData: Data?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/all/trophy/get"
        
        Utilities.loadDataFromURL(URL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            }else{
                errorFound(error)
            }
        })
    }
    
    class func getAllMedalsWithSuccess(success succeed: @escaping ((_ couponsData: Data?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/all/medal/get"
        
        Utilities.loadDataFromURL(URL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            }else{
                errorFound(error)
            }
        })
    }
    
}
