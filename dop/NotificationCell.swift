//
//  NotificationCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 26/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    
    @IBOutlet var title: UILabel!
    
    var viewController:UIViewController?
    var notification:Notification?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadItem(notification:Notification, viewController:UIViewController) {
        
        self.title.text = notification.type
        
        
        self.notification = notification
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
