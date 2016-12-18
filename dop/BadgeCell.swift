//
//  BadgeCell.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/18/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BadgeCell: UITableViewCell {
    
    @IBOutlet weak var badge_image: UIImageView!
    @IBOutlet weak var badge_name: UILabel!
    @IBOutlet weak var badge_description: UILabel!
    @IBOutlet weak var badge_locked: UILabel!
    
    var model: BadgeModel!
    
    @IBOutlet weak var labels_view: UIView!
    
    func loadItem(_ model: BadgeModel) {
        self.model = model
        badge_name.text = model.name
        badge_description.text = model.info
    }
    
    func setNotEarned() {
        badge_image.alpha = 0.2
        badge_locked.isHidden = false
        badge_name.textColor = UIColor.darkGray
        badge_description.textColor = UIColor.lightGray
        
        badge_name.alpha = 0.6
        badge_description.alpha = 0.7
        
        labels_view.backgroundColor = Utilities.lightGrayColor
    }
    
    func setEarned() {
        badge_image.alpha = 1
        badge_name.alpha = 1
        badge_description.alpha = 1
        
        badge_description.textColor = UIColor.darkGray
        badge_name.textColor = Utilities.dopColor
        badge_locked.isHidden = true
        labels_view.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
    }
}
