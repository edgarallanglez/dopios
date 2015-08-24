//
//  CouponController.swift
//  dop
//

import Foundation


class CouponController {
    typealias ServiceResponse = (NSDictionary?, NSError?) -> Void

  
    class func getAllCouponsWithSuccess(success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/get/user"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func takeCouponWithSuccess(params:[String:AnyObject], success succeed: ((couponsData: NSData!) -> Void) ,failure errorFound: ((couponsData: NSError?) -> Void)){
        let url = "\(Utilities.dopURL)coupon/user/take"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func likeCouponWithSuccess(params:[String:AnyObject], success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/like"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
}