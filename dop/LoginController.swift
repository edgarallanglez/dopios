//
//  LoginController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 14/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class LoginController {
    
    class func loginWithSocial(url:String,params:[String:AnyObject],success: ((couponsData: NSData!) -> Void)) {
        Utilities.sendDataToURL(NSURL(string: url)!,params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(couponsData: urlData)
            }
        })
    }
    
}
