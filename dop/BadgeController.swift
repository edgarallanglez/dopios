//
//  TrophyController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/15/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class BadgeController {
    class func getAllBadgesWithSuccess(success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/all/get"
        
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func getAllTrophiesWithSuccess(success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/all/trophy/get"
        
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func getAllMedalsWithSuccess(success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)badge/all/medal/get"
        
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
}