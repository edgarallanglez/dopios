//
//  NotificationController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 26/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import Alamofire

class NotificationController{
    class func getNotificationsWithSuccess(success succeed: @escaping ((_ notificationsData: JSON?) -> Void), failure errorFound:@escaping ((_ notificationsData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)notification/all/get"

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
    
    class func getNotificationsOffsetWithSuccess(_ notification_id:Int,offset:Int,success succeed: @escaping ((_ notificationsData: JSON?) -> Void),failure errorFound: @escaping ((_ notificationsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)notification/all/offset/get/?offset=\(offset)&notification_id=\(notification_id)"

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
    
    class func setNotificationsReadWithSuccess(_ params:[String:AnyObject],success succeed: @escaping ((_ notificationsData: JSON?) -> Void), failure errorFound:@escaping ((_ notificationsData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)notification/set/read"

        Alamofire.request(url, method: .put, headers: User.userToken).validate().responseJSON { response in
            
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
