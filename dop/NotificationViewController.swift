 //
//  NotificationViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate {
    
    @IBOutlet var notificationButton: UIButton!
    @IBOutlet var mainLoader: MMMaterialDesignSpinner!
    @IBOutlet var notification_table: UITableView!
    @IBOutlet weak var giverView: UIView!
    
    //let socketIO : SocketIO = SocketIO()
    var notifications = [Notification]()
    var notificationsTemporary = [Notification]()
    var offset: Int = 0
    let limit: Int = 11
    var refreshControl: UIRefreshControl!
    var cachedImages: [String: UIImage] = [:]
    var notificationButtonPressed: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        notification_table.rowHeight = UITableViewAutomaticDimension
        notification_table.estimatedRowHeight = 75
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.setNotificationConfig),
            name: NSNotification.Name(rawValue: "notificationsRegistered"),
            object: nil)
        
        if User.deviceToken == "" {
            let background = Utilities.Colors
            background.frame = self.view.bounds
            self.giverView.layer.insertSublayer(background, at: 0)
            self.giverView.isHidden = false
        } else {
            setNotificationConfig()
        }
    }
    
    @IBAction func pressNotificationButton(_ sender: AnyObject) {
        //notification_table.setContentOffset(CGPointMake(0, 0), animated: true)
        notificationButtonPressed = true
        if !refreshControl.isRefreshing { self.getNotifications() }
        Utilities.fadeOutViewAnimation(self.notificationButton, delay: 0, duration: 0.5)
    }

    func refresh(_ sender:AnyObject){
        Utilities.fadeOutViewAnimation(self.notificationButton, delay: 0, duration: 0.5)
        if(notificationButtonPressed == false){
            getNotifications()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        User.newNotification = false

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    override func viewDidLayoutSubviews() {
        self.navigationController?.navigationBar.backItem?.title = " "

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NotificationCell;

        cell.title.delegate = self
        cell.title.linkAttributes = [NSForegroundColorAttributeName: Utilities.dopColor]
        cell.title.activeLinkAttributes = [NSForegroundColorAttributeName : UIColor.black, NSBackgroundColorAttributeName: UIColor.lightGray]
        cell.title.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue

        if !notifications.isEmpty {
            let model = self.notifications[indexPath.row]
            cell.loadItem(model, viewController: self)
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            var imageUrl: URL = URL(string: "http://")!
            let identifier = "Cell\((indexPath as NSIndexPath).row)"
            if model.catcher_id != User.user_id {
                if model.catcher_image != ""{
                    imageUrl = URL(string: "\(model.catcher_image)")!
                }
            }
            else if model.launcher_image != "" {
                imageUrl = URL(string: "\(model.launcher_image)")!
            }

            let color = cell.contentView.backgroundColor
            cell.backgroundColor = color

            if self.cachedImages[identifier] != nil {
                let cell_image_saved : UIImage = self.cachedImages[identifier]!
                cell.notification_image.image = cell_image_saved
                UIView.animate(withDuration: 0.5, animations: {
                    cell.notification_image.alpha = 1
                })

            } else {
                cell.notification_image.alpha = 0.3
                cell.notification_image.image = UIImage(named: "dop-logo-transparent")
                cell.notification_image.backgroundColor = Utilities.lightGrayColor
                Alamofire.request(imageUrl).responseImage { response in
                    if let image = response.result.value {
                        self.cachedImages[identifier] = image
                        cell.notification_image.image = image
                        UIView.animate(withDuration: 0.5, animations: {
                            cell.notification_image.alpha = 3
                        })
                    }
                }
            }
        }

        return cell

    }

    func getNotifications() {
        notificationsTemporary.removeAll()
        cachedImages.removeAll()

        Utilities.fadeInViewAnimation(self.mainLoader, delay: 0, duration: 0.3)

        NotificationController.getNotificationsWithSuccess(
            success: { (data) -> Void in
                let json = data!
                for (_, subJson): (String, JSON) in json["data"]{
                    let type = subJson["type"].string ?? ""
                    let notification_id = subJson["notification_id"].int ?? 0
                    let launcher_id = subJson["launcher_id"].int ?? 0
                    let catcher_id = subJson["catcher_id"].int ?? 0
                    let launcher_name = subJson["launcher_name"].string ?? ""
                    let launcher_surnames = subJson["launcher_surnames"].string ?? ""
                    let catcher_name = subJson["catcher_name"].string ?? ""
                    let catcher_surnames = subJson["catcher_surnames"].string ?? ""
                    let branches_name = subJson["branches_name"].string ?? ""
                    let operation_id = subJson["operation_id"].int ?? 0
                    let read = subJson["read"].bool ?? false
                    let date = subJson["notification_date"].string ?? ""
                    let company_id = subJson["company_id"].int ?? 0
                    let object_id = subJson["object_id"].int ?? 0
                    let catcher_image = subJson["catcher_image"].string ?? ""
                    let launcher_image = subJson["launcher_image"].string ?? ""
                    let branch_id = subJson["branch_id"].int ?? 0
                    let is_friend = subJson["is_friend"].bool!

                    let model = Notification(type: type, notification_id: notification_id, launcher_id: launcher_id, catcher_id: catcher_id, launcher_name: launcher_name, launcher_surnames: launcher_surnames,  catcher_name: catcher_name, catcher_surnames: catcher_surnames, branches_name: branches_name, operation_id: operation_id, read: read, date: date, launcher_image: launcher_image, catcher_image: catcher_image, company_id: company_id, object_id: object_id, branch_id: branch_id, is_friend: is_friend)
                    
                    if !(model.launcher_id == User.user_id && model.type == "friend" && model.operation_id == 0) {
                        self.notificationsTemporary.append(model)
                    }
                }

                DispatchQueue.main.async(execute: {
                    self.notifications.removeAll()
                    self.notifications = self.notificationsTemporary

                    self.notification_table.reloadData()
                    self.notification_table.finishInfiniteScroll()

                    
                    self.view.setNeedsLayout()
                    self.offset = self.limit - 1

                    self.refreshControl.endRefreshing()

                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                    self.notificationButtonPressed = false
                    //Utilities.fadeInViewAnimation(self.notification_table, delay: 0, duration: 1)
                    Utilities.fadeInFromBottomAnimation(self.notification_table, delay: 0, duration: 1, yPosition: 20)
                    self.notification_table.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                });
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    self.notification_table.finishInfiniteScroll()
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)

                })
        })
    }
    
    func getNotificationsWithOffset() {
        var newData: Bool = false
        var addedValues: Int = 0

        let firstNotification = self.notifications.first as Notification!

        NotificationController.getNotificationsOffsetWithSuccess((firstNotification?.notification_id)!, offset:offset,
            success: { (couponsData) -> Void in
                let json = couponsData!
                for (_, subJson): (String, JSON) in json["data"]{
                    let type = subJson["type"].string ?? ""
                    let notification_id = subJson["notification_id"].int ?? 0
                    let launcher_id = subJson["launcher_id"].int ?? 0
                    let catcher_id = subJson["catcher_id"].int ?? 0
                    let launcher_name = subJson["launcher_name"].string ?? ""
                    let launcher_surnames = subJson["launcher_surnames"].string ?? ""
                    let catcher_name = subJson["catcher_name"].string ?? ""
                    let catcher_surnames = subJson["catcher_surnames"].string ?? ""
                    let branches_name = subJson["branches_name"].string ?? ""
                    let operation_id = subJson["operation_id"].int ?? 0
                    let read = subJson["read"].bool ?? false
                    let date = subJson["notification_date"].string ?? ""
                    let company_id = subJson["company_id"].int ?? 0
                    let object_id = subJson["object_id"].int ?? 0
                    let catcher_image = subJson["catcher_image"].string!
                    let launcher_image = subJson["launcher_image"].string!
                    let branch_id = subJson["branch_id"].int ?? 0
                    let is_friend = subJson["is_friend"].bool!
                    
                    
                    let model = Notification(type: type, notification_id: notification_id, launcher_id: launcher_id, catcher_id: catcher_id, launcher_name: launcher_name, launcher_surnames: launcher_surnames,  catcher_name: catcher_name, catcher_surnames: catcher_surnames, branches_name: branches_name, operation_id: operation_id, read: read, date: date, launcher_image: launcher_image, catcher_image: catcher_image, company_id: company_id, object_id: object_id, branch_id: branch_id, is_friend: is_friend)
                    
                    self.notificationsTemporary.append(model)

                    newData = true
                    addedValues += 1
                }
                
                DispatchQueue.main.async(execute: {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.notifications.removeAll()
                        self.notifications = self.notificationsTemporary
                        
                        
                        self.notification_table.reloadData()
                        self.notification_table.finishInfiniteScroll()
                        
                        if newData { self.offset += addedValues }

                    })
                });
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    self.notification_table.finishInfiniteScroll()
                })
        })
    }
    
    func readNotification(_ notification:Notification){
        let params: [String: AnyObject] = [ "notification_id" : notification.notification_id as AnyObject ]

        NotificationController.setNotificationsReadWithSuccess(params,
            success: { (couponsData) -> Void in
               let json = couponsData!

                notification.read = true

                DispatchQueue.main.async(execute: {
                    UIView.animate(withDuration: 0.3, animations: {
                        //self.notification_table.reloadData()
                    })
                });
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    //self.CouponsCollectionView.finishInfiniteScroll()
                })
        })

    }
    
    func showNotificationButton() {
        Utilities.fadeInFromBottomAnimation(notificationButton, delay: 0, duration: 1, yPosition: 20)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = notifications[(indexPath as NSIndexPath).row]
        /*let itemId = selectedItem.notification_id

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
        }*/
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let splitter = String(describing: url!).components(separatedBy: ":")
        
        let segue: String = splitter[0]
        let object_id: Int = Int(splitter[1])!
        if segue == "userProfile" {
                        
            let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            let view_controller = storyboard.instantiateViewController(withIdentifier: "UserProfileStickyController") as! UserProfileStickyController
            let is_friend: Bool = (splitter[2] as NSString!).boolValue
            view_controller.user_id = object_id
            view_controller.is_friend = is_friend

            self.navigationController?.pushViewController(view_controller, animated: true)

        }

        if segue == "branchProfile" {
            let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            let view_controller = storyboard.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.branch_id = object_id
            self.navigationController?.pushViewController(view_controller, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.giverView.isHidden { self.refreshControl.endRefreshing() }
    }
    
    func refreshTableView(_ notification: Foundation.Notification){
        getNotifications()
        self.view.layoutIfNeeded()
    }
    
    func setNotificationConfig() {
     //   self.checkDeviceToken()
        self.title = "Notificaciones"
        notification_table.alpha = 0
        self.giverView.isHidden = true
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(NotificationViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.notification_table.addSubview(refreshControl)
        
        let loader: MMMaterialDesignSpinner = MMMaterialDesignSpinner(frame: CGRect(x: 0,y: 0,width: 24,height: 24))
        
        loader.lineWidth = 2.0
        self.notification_table.infiniteScrollIndicatorView = loader
        self.notification_table.infiniteScrollIndicatorView?.tintColor = Utilities.dopColor
        
        // Set custom indicator
        //self.notification_table.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        
        // Set custom indicator margin
        notification_table.infiniteScrollIndicatorMargin = 10
        
        self.offset = self.limit - 1
        
        // Add infinite scroll handler
        notification_table.addInfiniteScroll { [weak self] (scrollView) -> Void in
            //if(!self!.notifications.isEmpty){
            self!.getNotificationsWithOffset() //offset
            //}
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationViewController.showNotificationButton), name: NSNotification.Name(rawValue: "newNotification"), object: nil)
        
        mainLoader.startAnimating()
        mainLoader.tintColor = Utilities.dopColor
        mainLoader.lineWidth = 3.0
        getNotifications()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NotificationViewController.refreshTableView(_:)),
            name: NSNotification.Name(rawValue: "refreshTableView"),
            object: nil)
    }
    
    @IBAction func askPermission(_ sender: UIButton) {
        var push_asked: Bool = false
        
        if UserDefaults.standard.object(forKey: "push_asked") != nil {
            push_asked = UserDefaults.standard.value(forKeyPath: "push_asked") as! Bool
        }
        if  push_asked {
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(settingsUrl!)
        } else {

            UIApplication.shared.registerForRemoteNotifications()
            UIApplication.shared.registerUserNotificationSettings(
                UIUserNotificationSettings(types: [.alert, .sound, .badge],
                                           categories: nil)
            )
            UserDefaults.standard.setValue(true, forKey: "push_asked")
//            
        }

    }

}
