//
//  LoginController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 14/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class LoginController {
    
    class func loginWithSocial(url: String, params: [String:AnyObject], success succeed: ((loginData: NSData!) -> Void),failure errorFound: ((loginData: NSError?) -> Void)) {

        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion: {(data, error) -> Void in
            if let urlData = data {
                succeed(loginData: urlData)
            } else {
                errorFound(loginData: error)
            }
        })
        
    }
    class func getPrivacyInfo(success succeed: ((userData: NSData!) -> Void), failure errorFound:((userData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)user/privacy_status/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion: {(data, error) -> Void in
            if let urlData = data {
                succeed(userData: urlData)
            }else{
                errorFound(userData: error)
            }
        })
    }
    
    
}
