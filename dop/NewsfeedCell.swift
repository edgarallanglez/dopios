//
//  NewsfeedCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NewsfeedCell: UITableViewCell {

    @IBOutlet var user_image: UIImageView!
    @IBOutlet var newsfeed_description: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func loadItem(#newsfeed_description: String, user_image: NSURL, friend_id: String, coupon_name:String, branch_name:String) {
        self.newsfeed_description.text = "\(newsfeed_description) utilizó \(coupon_name) en \(branch_name)"
        
        self.user_image.layer.masksToBounds = true
        self.user_image.layer.cornerRadius = 25
        self.user_image.alpha=0
        
        Utilities.getDataFromUrl(user_image) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(user_image.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.user_image.image = UIImage(data: data!)
                
                UIView.animateWithDuration(0.5, animations: {
                    self.user_image.alpha = 1
                })
            }
        }
        
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
