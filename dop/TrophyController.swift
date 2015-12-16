//
//  TrophyController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/15/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class TrophyController {
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
}