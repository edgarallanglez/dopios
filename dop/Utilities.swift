//
//  Utilities.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 14/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class Utilities {
    class func loadDataFromURL(url: NSURL, completion: (data: NSData?, error: NSError?) -> Void) {
        var session = NSURLSession.sharedSession()
        
        let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    var statusError = NSError(domain: "com.dop", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey: "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                    
                }
            }
        })
        
        loadDataTask.resume()
    }
    
    class func sendDataToURL(url: NSURL,params: [String:AnyObject], completion: (data:NSData?,error:NSError?)->Void) {
        
        var session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(User.userToken, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.allZeros, error: &err)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    var statusError = NSError(domain: "com.dop", code: httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey: "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                    
                }
            }

            
        })
        task.resume()
    }
    class func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }
}
