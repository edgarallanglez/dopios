//
//  NotificationCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 26/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    
    @IBOutlet var notification_view: UIView!
    @IBOutlet var notification_image: UIImageView!
    @IBOutlet var title: UILabel!
    
    var viewController:UIViewController?
    var notification:Notification?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadItem(notification:Notification, viewController:UIViewController) {
        
        if(notification.type == "newsfeed"){
            self.title.text = "A \(notification.launcher_name) \(notification.launcher_surnames) le a gustado tu actividad en \(notification.newsfeed_activity)"
            self.notification_image.image = UIImage(named: "news-icon")
        }
        if(notification.type == "friend"){
            self.title.text = "\(notification.launcher_name) \(notification.launcher_surnames) te envió una solicitud de amistad"
            self.notification_image.image = UIImage(named: "request-icon")
        }
        if(notification.read == false){
            notification_view.backgroundColor = Utilities.lightGrayColor
        }else{
            /*UIView.animateWithDuration(3, animations: {
                self.notification_view.backgroundColor = UIColor.whiteColor()
            })*/
        }
        
        
        self.notification = notification
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
