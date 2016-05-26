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

    func loadItem(notification:Notification, viewController:UIViewController) {
        var string_format = NSMutableAttributedString()

        let launcher_name = "\(notification.launcher_name) \(notification.launcher_surnames)"
        let newsfeed_Activity = "\(notification.newsfeed_activity)"

        decline_btn.hidden = true
        accept_btn.hidden = true


        if notification.type == "newsfeed" {

            let notification_text = "A \(launcher_name) le ha gustado tu actividad en \(newsfeed_Activity)"
            title.text = notification_text
            let nsString = notification_text as NSString
            let launcher_range = nsString.rangeOfString(launcher_name)
            let newsfeed_activity_range = nsString.rangeOfString(newsfeed_Activity)
            let segue = NSURL(string: "userProfile:\(notification.launcher_id)")!
            let branch_segue = NSURL(string: "branchProfile:\(notification.branch_id)")
            title.addLinkToURL(segue, withRange: launcher_range)
            title.addLinkToURL(branch_segue, withRange: newsfeed_activity_range)
        }
        if notification.type == "friend" {
            var notification_text = ""

            if notification.friendship_status == 1 && notification.launcher_friend == User.user_id {
                notification_text = "Ahora sigues a \(launcher_name)"
            }
            if notification.friendship_status == 1 && notification.launcher_friend != User.user_id {
                notification_text = "\(launcher_name) te esta siguiendo"
            }
            if notification.friendship_status == 0 && notification.launcher_friend == User.user_id {
                notification_text = "\(launcher_name) quiere seguirte"
                decline_btn.hidden = false
                accept_btn.hidden = false
            }

            title.text = notification_text
            let nsString = notification_text as NSString
            let launcher_range = nsString.rangeOfString(launcher_name)
            let segue = NSURL(string: "userProfile:\(notification.launcher_id)")!
            title.addLinkToURL(segue, withRange: launcher_range)

        }

        /*if !notification.read {
            notification_view.backgroundColor = Utilities.lightGrayColor
            self.contentView.backgroundColor = Utilities.lightGrayColor
        } else {
            notification_view.backgroundColor = UIColor.whiteColor()
            self.contentView.backgroundColor = UIColor.whiteColor()
        }*/
        
        if notification.friendship_status>=2{
            notification_view.backgroundColor = Utilities.dopColor
            self.contentView.backgroundColor = Utilities.dopColor
        }

        self.date_label.text = Utilities.friendlyDate(notification.date)
        self.notification = notification
    }

    @IBAction func declineFriend(sender: AnyObject) {
        let params:[String: AnyObject] = [
            "notification_id" : self.notification!.notification_id,
            "friends_id": self.notification!.object_id]

            FriendsController.declineFriendWithSuccess(params, success: {(friendsData) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                print("Rechazado")
            })
            }, failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    print("Error")
            })
        })
    }

    @IBAction func acceptFriend(sender: AnyObject) {
        let params:[String: AnyObject] = [
            "notification_id" : self.notification!.notification_id,
            "friends_id": self.notification!.object_id]

            FriendsController.acceptFriendWithSuccess(params, success: {(friendsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                        print("Aceptado")
                })
                }, failure: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Error")
                })
            })
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
