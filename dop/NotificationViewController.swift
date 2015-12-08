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
    var notificationsTemporary = [Notification]()
    var offset:Int = 0
    let limit:Int = 11
    var refreshControl: UIRefreshControl!
    var cachedImages: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        
        self.title = "Notificaciones"
 
        notification_table.alpha = 0
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.notification_table.addSubview(refreshControl)
        
        
        // Set custom indicator
        self.notification_table.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        
        // Set custom indicator margin
        notification_table.infiniteScrollIndicatorMargin = 10
        
        self.offset = self.limit - 1
        
        // Add infinite scroll handler
        notification_table.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            //if(!self!.notifications.isEmpty){
                self!.getNotificationsWithOffset() //offset
            //}
        }

        getNotifications()
        
    }
    func refresh(sender:AnyObject){
        getNotifications()
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! NotificationCell;
        
        if(!notifications.isEmpty){
            let model = self.notifications[indexPath.row]
            cell.loadItem(model, viewController: self)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            var imageUrl:NSURL
            let identifier = "Cell\(indexPath.row)"
            
            
            if(model.type == "newsfeed"){
                imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(model.image_name)")!
            }else{
                imageUrl = NSURL(string: "\(model.image_name)")!
            }
            Utilities.getDataFromUrl(imageUrl) { photo in
                dispatch_async(dispatch_get_main_queue()) {
                    let imageData : NSData = NSData(data:photo!)
                    if tableView.indexPathForCell(cell)?.row == indexPath.row {
                        //self.cachedImages[identifier] = imageData
                        //let image_saved : UIImage = self.cachedImages[identifier]!
                        cell.notification_image.image = UIImage(data: imageData)
                        UIView.animateWithDuration(0.5, animations: {
                            cell.notification_image.alpha = 1
                        })
                    }
                }
            }
        }
        
        return cell

    }
    
    func getNotifications() {
        notificationsTemporary.removeAll(keepCapacity: false)
        
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
                    let read = subJson["readed"].bool ?? false
                    let date = subJson["notification_date"].string ?? ""
                    
                    var image:String
                    if(subJson["user_image"]==nil){
                        image = subJson["branch_image"].string!
                    }else{
                        image = subJson["user_image"].string!
                    }
                   
                    
                    
                    let model = Notification(type: type, notification_id: notification_id, launcher_id: launcher_id, launcher_name: launcher_name, launcher_surnames: launcher_surnames, newsfeed_activity: newsfeed_activity, friendship_status: friendship_status,read: read, date: date, image_name: image)
                    
                    self.notificationsTemporary.append(model)
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    UIView.animateWithDuration(0.3, animations: {
                        self.notifications.removeAll()
                        self.notifications = self.notificationsTemporary
                        
                        self.notification_table.reloadData()
                        self.readNotifications()
                        self.notification_table.finishInfiniteScroll()
                        
                        self.offset = self.limit - 1
                        
                        self.refreshControl.endRefreshing()

                        
                        UIView.animateWithDuration(0.3, animations: {
                            self.notification_table.alpha = 1
                        })
                        
                    })
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    //self.CouponsCollectionView.finishInfiniteScroll()
                })
        })
    }
    func getNotificationsWithOffset() {
        var newData:Bool = false
        var addedValues:Int = 0
        
        var firstNotification = self.notifications.first as Notification!
        
        NotificationController.getNotificationsOffsetWithSuccess(firstNotification.notification_id, offset:offset,
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
                    let read = subJson["readed"].bool ?? false
                    let date = subJson["notification_date"].string ?? ""

                    let image = subJson["user_image"].string! ?? subJson["branch_image"].string!
                    
                    let model = Notification(type: type, notification_id: notification_id, launcher_id: launcher_id, launcher_name: launcher_name, launcher_surnames: launcher_surnames, newsfeed_activity: newsfeed_activity, friendship_status: friendship_status,read: read, date:date, image_name: image)
                    
                    
                    self.notificationsTemporary.append(model)
                    
                    newData = true
                    addedValues++
                }
                dispatch_async(dispatch_get_main_queue(), {
                    UIView.animateWithDuration(0.3, animations: {
                        self.notifications.removeAll()
                        self.notifications = self.notificationsTemporary
                        
                        self.notification_table.reloadData()
                        
                        self.notification_table.finishInfiniteScroll()
                        
                        if(newData){
                            self.offset+=addedValues
                        }
                        
                        UIView.animateWithDuration(0.3, animations: {
                            self.notification_table.alpha = 1
                        })
                        
                    })
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    //self.CouponsCollectionView.finishInfiniteScroll()
                })
        })
    }
    func readNotifications(){
        let params:[String: AnyObject] = [
            "coupon_id" : ""]
        
        NotificationController.setNotificationsReadWithSuccess(params,
            success: { (couponsData) -> Void in
                let json = JSON(data: couponsData)
                print(json)
                for (index, notification) in self.notifications.enumerate() {
                    notification.read = true
                }

                dispatch_async(dispatch_get_main_queue(), {
                    UIView.animateWithDuration(0.3, animations: {
                        self.notification_table.reloadData()
                        
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
