//
//  Utilities.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 14/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.

//

import Foundation

class Utilities {
    static var filterArray: [Int] = []
    
    class var dopURL: String {
        return "http://45.55.7.118:5000/api/"
    }
    class var dopImagesURL : String {
        return "http://45.55.7.118/branches/images/"
    }
    class var dopColor: UIColor {
        return UIColor( red: 222.0/255.0 , green: 0.0/255.0 , blue: 120/255.0, alpha:1.0)
    }
    class var lightGrayColor: UIColor {
        return UIColor( red: 250.0/255.0 , green: 250.0/255.0 , blue: 250.0/255.0, alpha:1.0)
    }
    class var Colors:CAGradientLayer {
        let colorBottom = UIColor(red: 217.0/255.0, green: 4.0/255.0, blue: 121.0/255.0, alpha: 1.0).CGColor
        let colorTop = UIColor(red: 248.0/255.0, green: 20.0/255.0, blue: 90.0/255.0, alpha: 1.0).CGColor
        
        let gl: CAGradientLayer
        
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
        
        return gl
    }
    class func roundValue(value:Double,numberOfPlaces:Double)->Double{
        let multiplier = pow(10.0, numberOfPlaces)
        let rounded = round(value * multiplier) / multiplier
        
        return rounded
    }
    
    class func loadDataFromURL(url: NSURL, completion: (data: NSData?, error: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(User.userToken, forHTTPHeaderField: "Authorization")

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
    
    class func sendDataToURL(url: NSURL, method: String,params: [String:AnyObject], completion: (data:NSData?,error:NSError?)->Void) {
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(User.userToken, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = method
        var err: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
        } catch let error as NSError {
            err = error
            request.HTTPBody = nil
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain: "com.dop", code: httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey: "HTTP status code has unexpected value."])
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
            completion(data: NSData(data: data!))
            }.resume()
    }
    
    class func relativeTimeInString(value: NSTimeInterval) -> String {
            func getTimeData(value: NSTimeInterval) -> (count: Int, suffix: String) {
                let count = Int(floor(value))
                let suffix = count != 1 ? "s" : ""
                return (count: count, suffix: suffix)
            }
            
            let value = -value
            switch value {
            case 0...15: return "just now"
                
            case 0..<60:
                let timeData = getTimeData(value)
                return "\(timeData.count) second\(timeData.suffix) ago"
                
            case 0..<3600:
                let timeData = getTimeData(value/60)
                return "\(timeData.count) minute\(timeData.suffix) ago"
                
            case 0..<86400:
                let timeData = getTimeData(value/3600)
                return "\(timeData.count) hour\(timeData.suffix) ago"
                
            case 0..<604800:
                let timeData = getTimeData(value/86400)
                return "\(timeData.count) days\(timeData.suffix) ago"
                
            default:
                let timeData = getTimeData(value/604800)
                return "\(timeData.count) week\(timeData.suffix) ago"
            }
    }
}

/*
let time = NSDate(timeIntervalSince1970: timestamp).timeIntervalSinceNow
let relativeTimeString = NSDate.relativeTimeInString(time)
println(relativeTimeString)
*/
