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
    var current_level: Int = 0
    var spinner: MMMaterialDesignSpinner = MMMaterialDesignSpinner()
    var following = false
    
    
    func setView(parent_view_controller: UserProfileStickyController) {
        self.parent_view = parent_view_controller
        self.user_id = self.parent_view.user_id
        
        if User.user_id == self.parent_view.user_id { self.follow_button.alpha = 0 }
        Utilities.setMaterialDesignButton(self.follow_button, button_size: 50)
        
        if parent_view.person != nil {
            
            if parent_view.user_image?.image != nil { user_image.image = parent_view_controller.user_image.image }
            else { downloadImage(NSURL(string: parent_view_controller.person.main_image)!) }
            
            self.user_exp = parent_view.person.exp
            current_level = (self.parent_view.person?.level ?? 0)!
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
        self.follow_button.setImage(nil, forState: UIControlState.Normal)
        
        let params:[String: AnyObject] = [ "user_two_id": self.user_id ]
        
        Utilities.setButtonSpinner(self.follow_button, spinner: self.spinner, spinner_size: 18, spinner_width: 1.5, spinner_color: UIColor.whiteColor() )
        Utilities.fadeInViewAnimation(self.spinner, delay: 0, duration: 0.3)
        
        if !self.following {
            UserProfileController.followFriendWithSuccess(params, success: { (data) -> Void in
                let json: JSON = JSON(data: data)
                
                print(json)
                dispatch_async(dispatch_get_main_queue(), {
                    UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        
                        Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                        switch json["data"]["operation_id"].int! {
                            case 0: self.follow_button.setImage(UIImage(named: "clock-icon"), forState: UIControlState.Normal)
                                self.following = false
                            case 1: self.follow_button.setImage(UIImage(named: "following-icon"), forState: UIControlState.Normal)
                                self.following = true
                            default: break
                        }
                        self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
                        self.follow_button.backgroundColor = Utilities.dopColor
                        self.layoutIfNeeded()
                        }, completion: { (Bool) in
                           //
                            
                    })
                })
                
                },
                failure: { (data) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                        self.follow_button.setImage(UIImage(named: "follow-icon"), forState: .Normal)
                        self.follow_button.backgroundColor = Utilities.dop_detail_color
                        self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(18, 18, 18, 18)
                    })
                    
            })
        } else {
            UserProfileController.unfollowFriendWithSuccess(params, success: { (data) -> Void in
                let json: JSON = JSON(data: data)
                self.following = false
                
                dispatch_async(dispatch_get_main_queue(), {
                    UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                            self.follow_button.setImage(UIImage(named: "follow-icon"), forState: UIControlState.Normal)
                            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(18, 18, 18, 18)
                            self.follow_button.backgroundColor = Utilities.dop_detail_color
                            self.layoutIfNeeded()
                        }, completion: { (Bool) in
                            //
                            
                    })
                })
                
                },
                failure: { (data) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.follow_button.setImage(UIImage(named: "following-icon"), forState: .Normal)
                        self.follow_button.backgroundColor = Utilities.dopColor
                    })
                    
            })
        }
        
    }
    
    func setFollowingButton(is_friend: Bool) {
        self.following = is_friend
        if is_friend {
            UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.follow_button.setImage(UIImage(named: "following-icon"), forState: UIControlState.Normal)
                self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
                self.follow_button.backgroundColor = Utilities.dopColor
                self.layoutIfNeeded()
                Utilities.fadeInFromBottomAnimation(self.follow_button, delay: 0, duration: 0.7, yPosition: 0)
                }, completion: { (Bool) in
                    
                    
            })
        } else if self.parent_view.operation_id == 0 && self.user_id != User.user_id {
            UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.follow_button.setImage(UIImage(named: "clock-icon"), forState: UIControlState.Normal)
                self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
                self.follow_button.backgroundColor = Utilities.dopColor
                self.layoutIfNeeded()
                 Utilities.fadeInFromBottomAnimation(self.follow_button, delay: 0, duration: 0.7, yPosition: 0)
                }, completion: { (Bool) in
                    
                    
            })
        } else if self.parent_view.operation_id == 4 {
            UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.follow_button.setImage(UIImage(named: "follow-icon"), forState: UIControlState.Normal)
                self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(18, 18, 18, 18)
                self.follow_button.backgroundColor = Utilities.dop_detail_color
                self.layoutIfNeeded()
                Utilities.fadeInFromBottomAnimation(self.follow_button, delay: 0, duration: 0.7, yPosition: 0)
                }, completion: { (Bool) in
                    
                    
            })
            
        } else if self.user_id != User.user_id { Utilities.fadeInFromBottomAnimation(self.follow_button, delay: 0, duration: 0.7, yPosition: 0) }
    }
    
    func downloadImage(url: NSURL) {
        Utilities.downloadImage(url, completion: {(data, error) -> Void in
            if let image = data{
                dispatch_async(dispatch_get_main_queue()) {
                    self.user_image?.image = UIImage(data: image)
                    self.setProgressBar()
                }
                
            } else {
                print("Error")
            }
        })
    }
    
    func setProgressBar () {
        exp_progress.alpha = 1
        exp_progress.startDegree = 0
        exp_progress.progressColor = UIColor(red: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        exp_progress.trackColor = Utilities.lightGrayColor
        exp_progress.trackWidth = 3
        exp_progress.progressWidth = 3
        percent = (((user_exp - min_exp) / (level_up - min_exp)))
        progress = 360 * percent
        exp_progress.setEndDegree(CGFloat(progress), timing: TPPropertyAnimationTimingEaseInEaseOut, duration: 1.5, delay: 0)
    }
    
}