//
//  CouponController.swift
//  dop
//

import Foundation


class CouponController {
    
  
    class func getAllCouponsWithSuccess(success: ((couponsData: NSData!) -> Void)) {
        let url = "\(Utilities.dopURL)api/coupon/all/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(couponsData: urlData)
            }
        })
    }
    
    class func takeCouponWithSuccess(params:[String:AnyObject], success: ((couponsData: NSData!) -> Void)) {
        let url = "\(Utilities.dopURL)api/coupon/user/take"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(couponsData: urlData)
            }
        })
    }
    class func likeCouponWithSuccess(params:[String:AnyObject], success: ((couponsData: NSData!) -> Void)) {
        let url = "\(Utilities.dopURL)api/coupon/like"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                success(couponsData: urlData)
            }
        })
    }
    
}