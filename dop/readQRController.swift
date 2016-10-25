//
//  readQRController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 23/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class readQRController{
    class func sendQRWithSuccess(_ params:[String:AnyObject], success succeed: @escaping ((_ couponsData: Data?) -> Void) ,failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)){
        let url = "\(Utilities.dopURL)coupon/user/redeem"
        Utilities.sendDataToURL(URL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            }else{
                errorFound(error)
            }
        })
    }
    
    class func setActivityPrivacy(_ params:[String:AnyObject], success succeed: @escaping ((_ couponsData: Data?) -> Void) ,failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)){
        let url = "\(Utilities.dopURL)coupon/user/privacy"
        Utilities.sendDataToURL(URL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            }else{
                errorFound(error)
            }
        })
    }
}
