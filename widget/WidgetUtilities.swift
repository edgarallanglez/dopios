//
//  WidgetUtilities.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class WidgetUtilities{
    class var dopURL: String {
        return "http://45.55.7.118:5000/api/"
    }
    class var dopImagesURL : String {
        return "http://45.55.7.118/branches/images/"
    }
    
    class func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: NSData(data: data!))
            }.resume()
    }
    
    class func loadDataFromURL(url: NSURL, completion: (data: NSData?, error: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        
        let loadDataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain: "com.dop", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey: "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                    
                }
            }
        })
        
        loadDataTask.resume()
    }
    
}