//
//  CouponController.swift
//  dop
//

import Foundation


class CouponController {
    typealias ServiceResponse = (NSDictionary?, NSError?) -> Void

  
    class func getAllCouponsWithSuccess(limit:Int,success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/for/user/get/?limit=\(limit)"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func getAllCouponsOffsetWithSuccess(start_date: String,offset: Int,success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/for/user/offset/get"

        let params:[String: AnyObject] = [
            "offset" : String(stringInterpolationSegment: offset),
            "start_date" : String(start_date)]
        
        print(start_date)
        print(offset)
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func getAllCouponsByBranchWithSuccess(branch_id:Int,success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/for/user/by/branch/get/?branch_id=\(branch_id)"
        
        print(url)
        
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func getAllCouponsByBranchOffsetWithSuccess(coupon_id:Int,offset:Int,branch_id:Int,success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/for/user/by/branch/offset/get/?offset=\(offset)&coupon_id=\(coupon_id)&branch_id=\(branch_id)"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func getAllTakenCouponsWithSuccess(limit:Int,success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/taken/for/user/get/?limit=\(limit)"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func getAllTakenCouponsOffsetWithSuccess(taken_date: String,offset:Int,success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/taken/for/user/offset/get"
  
        let params:[String: AnyObject] = [
            "offset" : String(stringInterpolationSegment: offset),
            "taken_date" : String(taken_date)]

        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
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
            } else {
                errorFound(couponsData: error)
            }
        })
    }
    
    class func viewCouponWithSuccess(params:[String:AnyObject], success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/view"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func getAvailables(coupon_id: Int, success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/available/\(coupon_id)"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
    
    class func getPeopleTakingSpecificCouponWithSuccess(params:[String:AnyObject], success succeed: ((couponsData: NSData!) -> Void),failure errorFound: ((couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/used/get/bycoupon"
        Utilities.sendDataToURL(NSURL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(couponsData: urlData)
            }else{
                errorFound(couponsData: error)
            }
        })
    }
}