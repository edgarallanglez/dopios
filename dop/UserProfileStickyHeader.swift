//
//  UserProfileStickyHeader.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/28/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class UserProfileStickyHeader: UIView {
    
    @IBOutlet weak var follow_button_width: NSLayoutConstraint!
    
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var follow_button: UIButton!
    
    var parent_view: UserProfileStickyController!
    var user_id: Int!
    
    func setView(parent_view_controller: UserProfileStickyController) {
        self.parent_view = parent_view_controller
        self.user_id = self.parent_view.user_id
        self.follow_button.layer.borderColor = Utilities.dopColor.CGColor
        
        if parent_view.user_image?.image != nil {
            user_image.image = parent_view_controller.user_image.image
        } else {
            downloadImage(NSURL(string: parent_view_controller.person.main_image)!)
        }
        
        user_image.layer.cornerRadius = user_image.frame.width / 2
        user_image.layer.masksToBounds = true
        
        user_name.text = self.parent_view.user_name
        if (parent_view.person.is_friend != nil) { setFollowingButton() }
        
    }
    
    @IBAction func followUnfollow(sender: UIButton) {
        let params:[String: AnyObject] = [
            "user_two_id": self.user_id
        ]
        
        UserProfileController.followFriendWithSuccess(params, success: { (data) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.follow_button.setImage(nil, forState: UIControlState.Normal)
                    
                    self.follow_button.backgroundColor = Utilities.dopColor
                    self.follow_button_width.constant = CGFloat(100)
                    self.layoutIfNeeded()
                    }, completion: { (Bool) in
                        self.follow_button.setTitle("SIGUIENDO", forState: UIControlState.Normal)
                        
                })
            })
            },
            failure: { (data) -> Void in
                dispatch_async(dispatch_get_main_queue(), {})
                
        })
        
    }
    
    func setFollowingButton() {
        UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.follow_button.setImage(nil, forState: UIControlState.Normal)
            
            self.follow_button.backgroundColor = Utilities.dopColor
            self.follow_button_width.constant = CGFloat(100)
            self.layoutIfNeeded()
            }, completion: { (Bool) in
                self.follow_button.setTitle("SIGUIENDO", forState: UIControlState.Normal)
                
        })
    }
    
    func downloadImage(url: NSURL) {
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.user_image?.image = UIImage(data: data!)
            }
        }
    }
}