//
//  NotificationViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit




class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    let socketIO : SocketIO = SocketIO()
    var notifications = [Notification]()

    
    
    override func viewDidLoad() {
 
        
    }
    override func viewDidAppear(animated: Bool) {
        getNotifications()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! NotificationCell;
        cell.title.text = "Te han agregado como amigo"
        //cell.loadItem(model, viewController: self)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell

    }
    
    func getNotifications() {
        

        
        UIView.animateWithDuration(0.3, animations: {
            //self.CouponsCollectionView.alpha = 0
        })
        
        NotificationController.getNotificationsWithSuccess(
            success: { (couponsData) -> Void in
                let json = JSON(data: couponsData)
                print(json)
                for (_, subJson): (String, JSON) in json["data"]{
                   /* let coupon_id = subJson["coupon_id"].int!
                    let coupon_name = subJson["name"].string!
                    let coupon_description = subJson["description"].string!
                    let coupon_limit = subJson["limit"].string
                    let coupon_exp = "2015-09-30"
                    let coupon_logo = subJson["logo"].string!
                    let branch_id = subJson["branch_id"].int!
                    let company_id = subJson["company_id"].int!
                    let total_likes = subJson["total_likes"].int!
                    let user_like = subJson["user_like"].int!
                    let latitude = subJson["latitude"].double!
                    let longitude = subJson["longitude"].double!
                    let banner = subJson["banner"].string ?? ""
                    let category_id = subJson["category_id"].int!*/
                    
                    
                    //let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id)
                    
                    //self.notifications.append(model)
                    
                    
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    UIView.animateWithDuration(0.3, animations: {
                        //self.CouponsCollectionView.alpha = 1
                        
                    })
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    //self.CouponsCollectionView.finishInfiniteScroll()
                })
        })
    }
   
}
