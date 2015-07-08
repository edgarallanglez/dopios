//
//  NewsfeedCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NewsfeedCell: UITableViewCell {

    @IBOutlet var username_button: UIButton!
    @IBOutlet var user_image: UIImageView!
    @IBOutlet var newsfeed_description: UILabel!
    
    var viewController:NewsfeedViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func loadItem(newsfeed_note:NewsfeedNote,viewController:NewsfeedViewController) {
        self.newsfeed_description.text = "utilizó \(newsfeed_note.coupon_name) en \(newsfeed_note.branch_name)"
        
        self.user_image.layer.masksToBounds = true
        self.user_image.layer.cornerRadius = 25
        self.user_image.alpha=0
        self.username_button.setTitle(newsfeed_note.names, forState: UIControlState.Normal)
        self.username_button.addTarget(self, action: "goToUserProfile:", forControlEvents: UIControlEvents.TouchUpInside)
        self.viewController=viewController
        
        let imageUrl = NSURL(string: newsfeed_note.user_image)
        
        
        Utilities.getDataFromUrl(imageUrl!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(imageUrl!.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.user_image.image = UIImage(data: data!)
                
                UIView.animateWithDuration(0.5, animations: {
                    self.user_image.alpha = 1
                })
            }
        }
        
    }
    
    
    func goToUserProfile(UIButton!){
        self.viewController!.performSegueWithIdentifier("userProfile", sender: self)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
