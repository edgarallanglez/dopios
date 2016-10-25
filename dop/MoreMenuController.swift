//
//  MoreMenuController.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/20/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class MoreMenuController {
    class func getImage(_ url:String, success: @escaping ((_ imageData: Data?) -> Void)) {
        Utilities.loadDataFromURL(URL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(urlData)
            }
        })
    }
    
    class func getUserProfile(_ url:String, success: @escaping ((_ profileData: Data?) -> Void)) {
        Utilities.loadDataFromURL(URL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(urlData)
            }
        })
    }
}
