//
//  NotificationViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit




class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate {
    @IBOutlet var notificationButton: UIButton!

    
    @IBOutlet var mainLoader: UIActivityIndicatorView!
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

        
        let loader:MMMaterialDesignSpinner = MMMaterialDesignSpinner(frame: CGRectMake(0,0,24,24))
        
        loader.lineWidth = 2.0
        self.notification_table.infiniteScrollIndicatorView = loader
        self.notification_table.infiniteScrollIndicatorView?.tintColor = Utilities.dopColor
        
        
        // Set custom indicator
        //self.notification_table.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        
        // Set custom indicator margin
        notification_table.infiniteScrollIndicatorMargin = 10
        
        self.offset = self.limit - 1
        
        // Add infinite scroll handler
        notification_table.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            //if(!self!.notifications.isEmpty){
                self!.getNotificationsWithOffset() //offset
            //}
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showNotificationButton", name: "newNotification", object: nil)

        getNotifications()
        
    }
    @IBAction func pressNotificationButton(sender: AnyObject) {
        //notification_table.setContentOffset(CGPointMake(0, 0), animated: true)
        self.getNotifications()
        Utilities.fadeOutViewAnimation(self.notificationButton, delay: 0, duration: 0.5)
    }
    func refresh(sender:AnyObject){
        getNotifications()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        User.newNotification = false
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! NotificationCell;
        
        cell.title.delegate = self
        
        cell.title.linkAttributes = [NSForegroundColorAttributeName: Utilities.dopColor]
        cell.title.activeLinkAttributes = [NSForegroundColorAttributeName : UIColor.blackColor(), NSBackgroundColorAttributeName: UIColor.lightGrayColor()]
        cell.title.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue

        
        
        if(!notifications.isEmpty){
            let model = self.notifications[indexPath.row]
            cell.loadItem(model, viewController: self)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            var imageUrl:NSURL
            let identifier = "Cell\(indexPath.row)"
            
            

            imageUrl = NSURL(string: "\(model.image_name)")!
            
            
            let color = cell.contentView.backgroundColor
            cell.backgroundColor = color
            
            
            cell.notification_image.layer.cornerRadius = cell.notification_image.frame.width/2

            if (self.cachedImages[identifier] != nil){
                let cell_image_saved : UIImage = self.cachedImages[identifier]!
                cell.notification_image.image = cell_image_saved
                UIView.animateWithDuration(0.5, animations: {
                    cell.notification_image.alpha = 1
                })
                
            } else {
                cell.notification_image.alpha=0
                Utilities.getDataFromUrl(imageUrl) { photo, error in
                    dispatch_async(dispatch_get_main_queue()) {
                        let imageData : NSData = NSData(data:photo!)
                        if tableView.indexPathForCell(cell)?.row == indexPath.row {
                            self.cachedImages[identifier] = UIImage(data: imageData)
                            //self.cachedImages[identifier] = imageData
                            let image_saved : UIImage = self.cachedImages[identifier]!
                            cell.notification_image.image = image_saved
                            UIView.animateWithDuration(0.5, animations: {
                                cell.notification_image.alpha = 1
                            })
                        }
                    }
                }
            }
        }
        
        return cell

    }
    
    func getNotifications() {
        notificationsTemporary.removeAll(keepCapacity: false)
        cachedImages.removeAll(keepCapacity: false)
        
        Utilities.fadeInViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
        
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
                    let read = subJson["read"].bool ?? false
                    let date = subJson["notification_date"].string ?? ""
                    let company_id = subJson["company_id"].int ?? 0
                    let object_id = subJson["object_id"].int ?? 0
                    let launcher_friend = subJson["launcher_friend"].int ?? 0
                    let image = subJson["user_image"].string!
                    let branch_id = subJson["branch_id"].int ?? 0
                    
                    
                    let model = Notification(type: type, notification_id: notification_id, launcher_id: launcher_id, launcher_name: launcher_name, launcher_surnames: launcher_surnames, newsfeed_activity: newsfeed_activity, friendship_status: friendship_status,read: read, date: date, image_name: image, company_id: company_id, object_id: object_id, launcher_friend: launcher_friend, branch_id: branch_id)
                    
                    self.notificationsTemporary.append(model)
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.notifications.removeAll()
                    self.notifications = self.notificationsTemporary
                    
                    self.notification_table.reloadData()
                    self.notification_table.finishInfiniteScroll()
                    
                    self.offset = self.limit - 1
                    
                    self.refreshControl.endRefreshing()

                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                    
                    //Utilities.fadeInViewAnimation(self.notification_table, delay: 0, duration: 1)
                    Utilities.fadeInFromBottomAnimation(self.notification_table, delay: 0, duration: 1, yPosition: 20)
                    self.notification_table.setContentOffset(CGPointMake(0, 0), animated: true)
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.notification_table.finishInfiniteScroll()
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)

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
                    let read = subJson["read"].bool ?? false
                    let date = subJson["notification_date"].string ?? ""
                    let company_id = subJson["company_id"].int ?? 0
                    let object_id = subJson["object_id"].int ?? 0
                    let launcher_friend = subJson["launcher_friend"].int ?? 0
                    let image = subJson["user_image"].string!
                    let branch_id = subJson["branch_id"].int ?? 0

                    let model = Notification(type: type, notification_id: notification_id, launcher_id: launcher_id, launcher_name: launcher_name, launcher_surnames: launcher_surnames, newsfeed_activity: newsfeed_activity, friendship_status: friendship_status,read: read, date:date, image_name: image, company_id: company_id, object_id: object_id, launcher_friend: launcher_friend, branch_id: branch_id)
                    
                    
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
                        
                        if newData {
                            self.offset += addedValues
                        }
                        
                        /*UIView.animateWithDuration(0.3, animations: {
                            self.notification_table.alpha = 1
                        })*/
                        
                    })
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.notification_table.finishInfiniteScroll()
                })
        })
    }
    func readNotification(notification:Notification){
        
        
        let params:[String: AnyObject] = [
            "notification_id" : notification.notification_id]
        
        NotificationController.setNotificationsReadWithSuccess(params,
            success: { (couponsData) -> Void in
               let json = JSON(data: couponsData)
                
                notification.read = true

                dispatch_async(dispatch_get_main_queue(), {
                    UIView.animateWithDuration(0.3, animations: {
                        //self.notification_table.reloadData()
                    })
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    //self.CouponsCollectionView.finishInfiniteScroll()
                })
        })

    }
    func showNotificationButton(){
        Utilities.fadeInFromBottomAnimation(notificationButton, delay: 0, duration: 1, yPosition: 20)
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = notifications[indexPath.row]
        let itemId = selectedItem.notification_id
        
        let cell: NotificationCell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationCell
        
        let params:[String: AnyObject] = [
            "notification_id" : selectedItem.notification_id,
            "friends_id": selectedItem.object_id]
        print(selectedItem.object_id)
            if(selectedItem.type == "friend"){
                FriendsController.acceptFriendWithSuccess(params, success: {(friendsData) -> Void in
                        dispatch_async(dispatch_get_main_queue(), {
                            print("Aceptado")
                        })
                    }, failure: { (error) -> Void in
                        dispatch_async(dispatch_get_main_queue(), {
                            print("Error")
                        })
                })
            if(selectedItem.type == "newsfeed"){
            }
        }
    }
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        let splitter = String(url).componentsSeparatedByString(":")
        let segue: String = splitter[0]
        let object_id: Int = Int(splitter[1])!
        
        if segue == "userProfile" {
            let view_controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileStickyController") as! UserProfileStickyController
            view_controller.user_id = object_id
            self.navigationController?.pushViewController(view_controller, animated: true)
        }
        if segue == "branchProfile" {
            let view_controller = self.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.branch_id = object_id
            self.navigationController?.pushViewController(view_controller, animated: true)
        }
    }


}
