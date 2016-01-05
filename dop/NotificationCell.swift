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
            
           /* let notification_text = "A \(notification.launcher_name) \(notification.launcher_surnames) le a gustado tu actividad en \(notification.newsfeed_activity)"
            let name_lenght = notification.launcher_name.characters.count + notification.launcher_surnames.characters.count + 1
            string_format = NSMutableAttributedString(string: notification_text as String)
            string_format.addAttribute(NSForegroundColorAttributeName, value: Utilities.dopColor, range: NSRange(location:2,length:name_lenght))
            self.title.attributedText = string_format */
            
        
        }
        if(notification.type == "friend"){
            /*let notification_text = "\(notification.launcher_name) \(notification.launcher_surnames) te envió una solicitud de amistad"
            let name_lenght = notification.launcher_name.characters.count + notification.launcher_surnames.characters.count + 1
            string_format = NSMutableAttributedString(string: notification_text as String)
            string_format.addAttribute(NSForegroundColorAttributeName, value: Utilities.dopColor, range: NSRange(location:0,length:name_lenght))
            self.title.attributedText = string_format*/
            
            let notification_text = "A \(launcher_name) te envió una solicitud de amistad"
            
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
