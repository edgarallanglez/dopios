//
//  SettingsController.swift
//  dop
//
//  Created by Edgar Allan Glez on 11/12/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class SettingsController {
    class func setPrivacyWithSuccess(url: String, params: [String:AnyObject], success succeed: ((data: NSData!) -> Void),failure errorFound: ((data: NSError?) -> Void)) {
        
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion: {(data, error) -> Void in
            if let urlData = data {
                succeed(data: urlData)
            }else{
                errorFound(data: error)
            }
        })
    }
}