//
//  SearchController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 04/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class SearchController: NSObject {
    class func searchWithSuccess(params:[String:AnyObject],success succeed: ((friendsData: NSData!) -> Void),failure errorFound: ((friendsData: NSError?) -> Void)) {
        let latitude: AnyObject! = params["latitude"]
        let longitude: AnyObject! = params["longitude"]
        let text: AnyObject! = params["text"]
        
        

        let url = "\(Utilities.dopURL)company/branch/search/?latitude=\(latitude)&longitude=\(longitude)&text=\(text)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        print(url)
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(friendsData: urlData)
            }else{
                errorFound(friendsData: error)
            }
        })
    }
}
