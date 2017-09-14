//
//  CouponController.swift
//  dop
//

import Foundation
import Alamofire

class CouponController {
    typealias ServiceResponse = (NSDictionary?, NSError?) -> Void

  
    class func getAllCouponsWithSuccess(_ limit: Int, success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/for/user/get/?limit=\(limit)"

        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
        
    }
    
    class func getAllCouponsOffsetWithSuccess(_ start_date: String, offset: Int,success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/for/user/offset/get"

        let params: Parameters = [
            "offset" : String(stringInterpolationSegment: offset) as AnyObject,
            "start_date" : String(start_date) as AnyObject]
        
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func getFavoriteCouponsWithSuccess(success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/favorites/for/user/get"
        
        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
        
    }
    
    class func getLoyaltyTimeline(_ limit: Int, success: @escaping ((_ data: JSON?) -> Void), failure: @escaping ((_ data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)loyalty/all/get/?limit=\(limit)"
        
        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                success(JSON(response.result.value))
            case .failure(let error):
                print(error)
                failure(error as NSError)
            }
        }
    }
    
    class func getAllCouponsByBranchWithSuccess(_ branch_id:Int,success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/for/user/by/branch/\(branch_id)/get"
        
        
        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func getAllCouponsByBranchOffsetWithSuccess(_ coupon_id:Int,offset:Int,branch_id:Int,success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/for/user/by/branch/offset/get/?offset=\(offset)&coupon_id=\(coupon_id)&branch_id=\(branch_id)"

        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func getAllTakenCouponsWithSuccess(_ limit:Int,success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/taken/for/user/get/?limit=\(limit)"
        
        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func getAllTakenCouponsOffsetWithSuccess(_ taken_date: String,offset:Int,success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/taken/for/user/offset/get"
  
        let params:[String: AnyObject] = [
            "offset" : String(stringInterpolationSegment: offset) as AnyObject,
            "taken_date" : String(taken_date) as AnyObject]

        
        Alamofire.request(url, method: .get, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func takeCouponWithSuccess(_ params:[String:AnyObject], success succeed: @escaping ((_ couponsData: JSON?) -> Void) ,failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)){
        let url = "\(Utilities.dopURL)coupon/user/take"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func likeCouponWithSuccess(_ params:[String:AnyObject], success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/like"

        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func viewCouponWithSuccess(_ params:[String:AnyObject], success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/view"

        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func viewLoyaltyWithSuccess(_ params:[String:AnyObject],
                                     success succeed: @escaping ((_ data: JSON?) -> Void),
                                     failure errorFound: @escaping ((_ data: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)loyalty/view"
        
        Alamofire.request(url, method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func getAvailables(_ coupon_id: Int, success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/available/\(coupon_id)"

        
        Alamofire.request(url, method: .get ,headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func getPeopleTakingSpecificCouponWithSuccess(_ params:[String:AnyObject], success succeed: @escaping ((_ couponsData: JSON?) -> Void),failure errorFound: @escaping ((_ couponsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/used/get/bycoupon"

        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default ,headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
}
