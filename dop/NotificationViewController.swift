//
//  NotificationViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit




class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var notification_table: UITableView!
    let socketIO : SocketIO = SocketIO()
    var notifications = [Notification]()

    
    
    override func viewDidLoad() {
 
        
    }
    override func viewDidAppear(animated: Bool) {
        getNotifications()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! NotificationCell;
        
        let model = self.notifications[indexPath.row]
        cell.loadItem(model, viewController: self)
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
                    let type = subJson["type"].string ?? ""
                    let notification_id = subJson["notification_id"].int ?? 0
                    let launcher_id = subJson["launcher_id"].int ?? 0
                    let launcher_name = subJson["launcher_name"].string ?? ""
                    let launcher_surnames = subJson["launcher_surnames"].string ?? ""
                    let newsfeed_activity = subJson["newsfeed_activity"].string ?? ""
                    let friendship_status = subJson["friendship_status"].int ?? 0
                    
                    let model = Notification(type: type, notification_id: notification_id, launcher_id: launcher_id, launcher_name: launcher_name, launcher_surnames: launcher_surnames, newsfeed_activity: newsfeed_activity, friendship_status: friendship_status)
                    
                    self.notifications.append(model)
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    UIView.animateWithDuration(0.3, animations: {
                        self.notification_table.reloadData()
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
