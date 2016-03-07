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
    @IBOutlet weak var user_level: UILabel!
    
    @IBOutlet weak var follow_button: UIButton!
    @IBOutlet weak var exp_progress: KAProgressLabel!
    
    var parent_view: UserProfileStickyController!
    var user_id: Int!
    var percent: Double!
    var progress: Double!
    var user_exp: Double!
    var min_exp: Double!
    var level_up: Double!
    var current_level: Int!
    
    func setView(parent_view_controller: UserProfileStickyController) {
        self.parent_view = parent_view_controller
        self.user_id = self.parent_view.user_id
        
        if User.user_id == self.parent_view.user_id { self.follow_button.hidden = true }
    
        self.follow_button.layer.borderColor = Utilities.dopColor.CGColor
        
        if parent_view.person != nil {
            
            if parent_view.user_image?.image != nil {
                user_image.image = parent_view_controller.user_image.image
            } else { downloadImage(NSURL(string: parent_view_controller.person.main_image)!) }
            
            self.user_exp = parent_view.person.exp
            current_level = (self.parent_view.person?.level!)!
            self.min_exp = Constanst.Levels["\(current_level)"].double!
            self.level_up = Constanst.Levels["\(current_level + 1)"].double!
            setProgressBar()
        }
        
        user_image.layer.cornerRadius = user_image.frame.width / 2
        user_image.layer.masksToBounds = true
        
        user_name.text = self.parent_view.person?.names
        user_level.text = "Nivel \(current_level)"
        
        if (parent_view.person?.is_friend != nil) { setFollowingButton((parent_view.person?.is_friend)!) }
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
    
    func setFollowingButton(is_friend: Bool) {
        
        if is_friend {
            UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.follow_button.setImage(nil, forState: UIControlState.Normal)
                
                self.follow_button.backgroundColor = Utilities.dopColor
                self.follow_button_width.constant = CGFloat(100)
                self.layoutIfNeeded()
                }, completion: { (Bool) in
                    self.follow_button.setTitle("SIGUIENDO", forState: UIControlState.Normal)
                    
            })
        }
    }
    
    func downloadImage(url: NSURL) {
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.user_image?.image = UIImage(data: data!)
            }
        }
    }
    
    func setProgressBar () {
        exp_progress.startDegree = 0
        exp_progress.progressColor = Utilities.dopColor
        exp_progress.trackColor = Utilities.lightGrayColor
        exp_progress.trackWidth = 2.2
        exp_progress.progressWidth = 2
        percent = (((user_exp - min_exp) / (level_up - min_exp)))
        progress = 360 * percent
        exp_progress.setEndDegree(CGFloat(progress), timing: TPPropertyAnimationTimingEaseInEaseOut, duration: 1.5, delay: 0)
    }
    
}