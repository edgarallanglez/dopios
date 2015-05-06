//
//  CouponController.swift
//  dop
//
//  Created by Dani Arnaout on 9/2/14.
//  Edited by Eric Cerney on 9/27/14.
//  Copyright (c) 2014 Ray Wenderlich All rights reserved.
//

import Foundation

let getCoupons = "http://104.236.141.44:5000/api/coupon/all/get"

class CouponController {
    
  
  class func getAllCouponsWithSuccess(success: ((couponsData: NSData!) -> Void)) {
    loadDataFromURL(NSURL(string: getCoupons)!, completion:{(data, error) -> Void in
        if let urlData = data {
            success(couponsData: urlData)
        }
    })
  }

  
    class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
    var session = NSURLSession.sharedSession()
    
    let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
      if let responseError = error {
        completion(data: nil, error: responseError)
      } else if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode != 200 {
          var statusError = NSError(domain:"com.dop", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
          completion(data: nil, error: statusError)
        } else {
          completion(data: data, error: nil)
            
        }
      }
    })
    
    loadDataTask.resume()
  }
}