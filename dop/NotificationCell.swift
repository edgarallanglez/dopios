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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadItem(notification:Notification, viewController:UIViewController) {
        var string_format = NSMutableAttributedString()
        
        let launcher_name = "\(notification.launcher_name) \(notification.launcher_surnames)"
        let newsfeed_Activity = "\(notification.newsfeed_activity)"
        
        if(notification.type == "newsfeed"){
            let notification_text = "A \(launcher_name) le a gustado tu actividad en \(newsfeed_Activity)"
            title.text = notification_text
            let nsString = notification_text as NSString
            let launcher_range = nsString.rangeOfString(launcher_name)
            let newsfeed_activity_range = nsString.rangeOfString(newsfeed_Activity)
            let segue = NSURL(string: "userProfile")!
            title.addLinkToURL(segue, withRange: launcher_range)
            title.addLinkToURL(segue, withRange: newsfeed_activity_range)
        }
        if(notification.type == "friend"){
            var notification_text = ""
            
            if(notification.friendship_status == 0 ){
                notification_text = "\(launcher_name) quiere seguirte"
            }
            if(notification.friendship_status == 1 && notification.launcher_id == User.user_id){
                notification_text = "Ahora sigues a \(launcher_name)"
            }else{
                notification_text = "\(launcher_name) te esta siguiendo"
            }
            
            title.text = notification_text
            let nsString = notification_text as NSString
            let launcher_range = nsString.rangeOfString(launcher_name)
            let segue = NSURL(string: "userProfile")!
            title.addLinkToURL(segue, withRange: launcher_range)
        }
        if(notification.read == false){
            notification_view.backgroundColor = Utilities.lightGrayColor
            self.contentView.backgroundColor = Utilities.lightGrayColor

        }else{
            notification_view.backgroundColor = UIColor.whiteColor()
            self.contentView.backgroundColor = UIColor.whiteColor()
        }
        
        self.date_label.text = Utilities.friendlyDate(notification.date)
        
        self.notification = notification
        

    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
