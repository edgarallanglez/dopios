//
//  SettingsController.swift
//  dop
//
//  Created by Edgar Allan Glez on 11/12/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class SettingsController {
    class func setPrivacyWithSuccess(_ url: String, params: [String:AnyObject], success succeed: @escaping ((_ data: Data?) -> Void),failure errorFound: @escaping ((_ data: NSError?) -> Void)) {
        
        Utilities.sendDataToURL(URL(string: url)!, method:"POST", params: params, completion: {(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            }else{
                errorFound(error)
            }
        })
    }
}
