//
//  NotificationCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 26/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {


    @IBOutlet var date_label: UILabel!
    @IBOutlet var notification_view: UIView!
    @IBOutlet var notification_image: UIImageView!
    @IBOutlet var title: TTTAttributedLabel!

    var viewController:UIViewController?
    var notification:Notification?

    @IBOutlet var decline_btn: UIButton!
    @IBOutlet var accept_btn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func loadItem(_ notification: Notification, viewController:UIViewController) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TrendingCoupon.updateLikeAndTaken(_:)),
            name: NSNotification.Name(rawValue: "takenOrLikeStatus"),
            object: nil)
        
        
        var string_format = NSMutableAttributedString()

        let launcher_name = "\(notification.launcher_name) \(notification.launcher_surnames)"
        let catcher_name = "\(notification.catcher_name) \(notification.catcher_surnames)"
        let newsfeed_activity = "\(notification.branches_name)"
        
        decline_btn.isHidden = true
        accept_btn.isHidden = true


        if notification.type == "newsfeed" {

            let notification_text = "A \(launcher_name) le ha gustado tu actividad en \(newsfeed_activity)"
            title.text = notification_text
            let nsString = notification_text as NSString
            let launcher_range = nsString.range(of: launcher_name)
            let newsfeed_activity_range = nsString.range(of: newsfeed_activity)
            let segue = URL(string: "userProfile:\(notification.launcher_id):\(notification.is_friend)")!
            let branch_segue = URL(string: "branchProfile:\(notification.branch_id)")
            title.addLink(to: segue, with: launcher_range)
            title.addLink(to: branch_segue, with: newsfeed_activity_range)
        }

        if notification.type == "friend" {
            var notification_text = ""
            
            switch notification.operation_id {
                case 0:
                    notification_text = "\(launcher_name) quiere seguirte"

                    let nsString = notification_text as NSString
                    let launcher_range = nsString.range(of: launcher_name)
                    let segue = URL(string: "userProfile:\(notification.launcher_id):\(notification.is_friend)")!
                    title.text = notification_text
                    title.addLink(to: segue, with: launcher_range)
                    decline_btn.isHidden = false
                    accept_btn.isHidden = false

                    break
                case 1:
                    if notification.catcher_id == User.user_id {
                        notification_text = "\(launcher_name) te esta siguiendo"
                        let nsString = notification_text as NSString
                        let launcher_range = nsString.range(of: launcher_name)
                        let segue = URL(string: "userProfile:\(notification.launcher_id):\(notification.is_friend)")!
                        title.text = notification_text
                        title.addLink(to: segue, with: launcher_range)
                    }
                    else {
                        notification_text = "Ahora sigues a \(catcher_name)"
                        let nsString = notification_text as NSString
                        let catcher_range = nsString.range(of: catcher_name)
                        let segue = URL(string: "userProfile:\(notification.catcher_id):\(notification.is_friend)")!
                        title.text = notification_text
                        title.addLink(to: segue, with: catcher_range)
                    }
                    break
            default: print(notification.operation_id)
            }
        }

        /*if !notification.read {
            notification_view.backgroundColor = Utilities.lightGrayColor
            self.contentView.backgroundColor = Utilities.lightGrayColor
        } else {
            notification_view.backgroundColor = UIColor.whiteColor()
            self.contentView.backgroundColor = UIColor.whiteColor()
        }*/

//        if notification.operation_id >= 2{
//            notification_view.backgroundColor = Utilities.dopColor
//            self.contentView.backgroundColor = Utilities.dopColor
//        }

        self.date_label.text = Utilities.friendlyDate(notification.date)
        self.notification = notification
    }

    @IBAction func declineFriend(_ sender: AnyObject) {
        let params:[String: AnyObject] = [
            "notification_id" : self.notification!.notification_id as AnyObject,
            "friends_id": self.notification!.object_id as AnyObject]

            FriendsController.declineFriendWithSuccess(params, success: {(friendsData) -> Void in
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "refreshTableView"), object: nil)

            DispatchQueue.main.async(execute: {
                print("Rechazado")
            })
            }, failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    print("Error")
            })
        })
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.notification_image.layer.cornerRadius = self.notification_image.frame.width/2
        self.notification_image.layer.masksToBounds = true
    }

    @IBAction func acceptFriend(_ sender: AnyObject) {
        let params:[String: AnyObject] = [
            "notification_id" : self.notification!.notification_id as AnyObject,
            "friends_id": self.notification!.object_id as AnyObject ]

            FriendsController.acceptFriendWithSuccess(params, success: {(friendsData) -> Void in
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "refreshTableView"), object: nil)
                })
                }, failure: { (error) -> Void in
                    DispatchQueue.main.async(execute: {
                        print("Error")
                })
            })
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
