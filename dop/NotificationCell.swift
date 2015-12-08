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
    @IBOutlet var title: UILabel!
    
    var viewController:UIViewController?
    var notification:Notification?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadItem(notification:Notification, viewController:UIViewController) {
        var string_format = NSMutableAttributedString()
        
        let linex = notification.date
        let separators = NSCharacterSet(charactersInString: "T.")
        let parts = linex.componentsSeparatedByCharactersInSet(separators)
        var fecha = NSDate(dateString: "\(parts[0]) \(parts[1])").timeAgo
        
        
        
        if(notification.type == "newsfeed"){
            let notification_text = "A \(notification.launcher_name) \(notification.launcher_surnames) le a gustado tu actividad en \(notification.newsfeed_activity)"
            
            let name_lenght = notification.launcher_name.characters.count + notification.launcher_surnames.characters.count + 1
            
            string_format = NSMutableAttributedString(string: notification_text as String)
            
            string_format.addAttribute(NSForegroundColorAttributeName, value: Utilities.dopColor, range: NSRange(location:2,length:name_lenght))
            
            
            print("FECHA NOTIFICACION \(fecha)")
            
            
            self.notification_image.image = UIImage(named: "news-icon")
            
            self.title.attributedText = string_format
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
        
        self.date_label.text = fecha

        self.notification = notification
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
