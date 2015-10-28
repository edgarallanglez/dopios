//
//  NotificationController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 26/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class NotificationController{
    class func getNotificationsWithSuccess(success succeed: ((notificationsData: NSData!) -> Void), failure errorFound:((notificationsData: NSError?) -> Void )) {
        let url = "\(Utilities.dopURL)notification/all/get"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion: {(data, error) -> Void in
            if let urlData = data {
                succeed(notificationsData: urlData)
            }else{
                errorFound(notificationsData: error)
            }
        })
    }
    
    class func getNotificationsOffsetWithSuccess(notification_id:Int,offset:Int,success succeed: ((notificationsData: NSData!) -> Void),failure errorFound: ((notificationsData: NSError?) -> Void)) {
        let url = "\(Utilities.dopURL)coupon/all/for/user/offset/get/?offset=\(offset)&coupon_id=\(notification_id)"
        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(notificationsData: urlData)
            }else{
                errorFound(notificationsData: error)
            }
        })
    }
    
}