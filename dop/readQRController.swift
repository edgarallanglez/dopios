//
//  readQRController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 23/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class readQRController{
    class func sendQRWithSuccess(params:[String:AnyObject], success succeed: ((couponsData: NSData!) -> Void) ,failure errorFound: ((couponsData: NSError?) -> Void)){
        let url = "\(Utilities.dopURL)coupon/user/use"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
}