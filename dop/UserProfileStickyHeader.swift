//
//  UserProfileStickyHeader.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/28/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class UserProfileStickyHeader: UIView {
    
    @IBOutlet weak var follow_button_width: NSLayoutConstraint!
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var user_level: UILabel!
    @IBOutlet weak var follow_button: UIButton!
    @IBOutlet weak var exp_progress: KAProgressLabel!
    
    var parent_view: UserProfileStickyController!
    var user: PeopleModel! {
        didSet {
            self.setView()
        }
    }
    
    var user_id: Int!
    var percent: Double!
    var progress: Double!
    var user_exp: Double!
    var min_exp: Double!
    var level_up: Double!
    var current_level: Int = 0
    var spinner: MMMaterialDesignSpinner = MMMaterialDesignSpinner()
    var following = false
    
    
    func setView() {
        self.user_image.alpha = 0
        
        if User.user_id == self.user.user_id { self.follow_button.alpha = 0 }
        Utilities.setMaterialDesignButton(self.follow_button, button_size: 46)
        
        self.downloadImage(URL(string: user.main_image)!)
        self.user_exp = user.exp
        current_level = self.user.level ?? 0
        self.min_exp = Constanst.Levels["\(current_level)"].double!
        self.level_up = Constanst.Levels["\(current_level + 1)"].double!
        //setProgressBar()
        
        user_image.layer.cornerRadius = user_image.frame.width / 2
        user_image.layer.masksToBounds = true
        
        user_name.text = self.parent_view.person?.names
        user_level.text = "Nivel \(current_level)"
        
        setFollowingButton(user.is_friend!)
//        self.layoutIfNeeded()
    }
    
    @IBAction func followUnfollow(_ sender: UIButton) {
        self.follow_button.setImage(nil, for: UIControlState())
        
        let params: [String: AnyObject] = [ "user_two_id": self.user.user_id as AnyObject ]
        
        Utilities.setButtonSpinner(self.follow_button, spinner: self.spinner, spinner_size: 16, spinner_width: 1.5, spinner_color: UIColor.white )
        Utilities.fadeInViewAnimation(self.spinner, delay: 0, duration: 0.3)
        
        if !self.following {
            UserProfileController.followFriendWithSuccess(params, success: { (data) -> Void in
                let json:JSON = data!
                
                DispatchQueue.main.async(execute: {
                    UIButton.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                        
                        Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                        switch json["data"]["operation_id"].int! {
                            case 0: self.follow_button.setImage(UIImage(named: "clock-icon"), for: UIControlState())
                                self.following = false
                            case 1: self.follow_button.setImage(UIImage(named: "following-icon"), for: UIControlState())
                                self.following = true
                            default: break
                        }
                        self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(13, 13, 13, 13)
                        self.follow_button.tintColor = Utilities.dopColor
//                        self.layoutIfNeeded()
                        }, completion: { (Bool) in
                           //
                    })
                })
                self.sendPushNotification(params: params)
                },
                failure: { (data) -> Void in
                    DispatchQueue.main.async(execute: {
                        Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                        self.follow_button.setImage(UIImage(named: "follow-icon"), for: UIControlState())
                        self.follow_button.tintColor = Utilities.dop_detail_color
                        self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
                    })
            })
        } else {
            UserProfileController.unfollowFriendWithSuccess(params, success: { (data) -> Void in
                let json: JSON = data!
                self.following = false
                
                DispatchQueue.main.async(execute: {
                    UIButton.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                        Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                            self.follow_button.setImage(UIImage(named: "follow-icon"), for: UIControlState())
                            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
                            self.follow_button.tintColor = Utilities.dop_detail_color
//                            self.layoutIfNeeded()
                        }, completion: { (Bool) in
                            //
                    })
                })
                
                },
                failure: { (data) -> Void in
                    DispatchQueue.main.async(execute: {
                        self.follow_button.setImage(UIImage(named: "following-icon"), for: UIControlState())
                        self.follow_button.tintColor = Utilities.dopColor
                    })
            })
        }
    }
    
    func setFollowingButton(_ is_friend: Bool) {
        self.following = is_friend
        if is_friend {
            UIButton.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.follow_button.setImage(UIImage(named: "following-icon"), for: UIControlState())
                self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(13, 13, 13, 13)
                self.follow_button.tintColor = Utilities.dopColor
//                self.layoutIfNeeded()
                Utilities.fadeInFromBottomAnimation(self.follow_button, delay: 0, duration: 0.7, yPosition: 0)
                }, completion: { (Bool) in
                    
                    
            })
        } else if self.user.operation_id == 0 && self.user.user_id != User.user_id {
            UIButton.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.follow_button.setImage(UIImage(named: "clock-icon"), for: UIControlState())
                self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(13, 13, 13, 13)
                self.follow_button.tintColor = Utilities.dopColor
//                self.layoutIfNeeded()
                 Utilities.fadeInFromBottomAnimation(self.follow_button, delay: 0, duration: 0.7, yPosition: 0)
                }, completion: { (Bool) in
                    
                    
            })
        } else if self.user.operation_id == 4 {
            UIButton.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.follow_button.setImage(UIImage(named: "follow-icon"), for: UIControlState())
                self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
                self.follow_button.tintColor = Utilities.dop_detail_color
//                self.layoutIfNeeded()
                Utilities.fadeInFromBottomAnimation(self.follow_button, delay: 0, duration: 0.7, yPosition: 0)
                }, completion: { (Bool) in
                    
            })
            
        } else if self.user.user_id != User.user_id { Utilities.fadeInFromBottomAnimation(self.follow_button, delay: 0, duration: 0.7, yPosition: 0) }
    }
    
    func downloadImage(_ url: URL) {
        
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value{
                self.user_image?.image = image
                Utilities.fadeInViewAnimation(self.user_image, delay: 0, duration: 0.5)
            } else {
                self.user_image.alpha = 0.3
                self.user_image.image = UIImage(named: "dop-logo-transparent")
                self.user_image.backgroundColor = Utilities.lightGrayColor
            }
            self.setProgressBar()
        }
    }
    
    func setProgressBar() {
        exp_progress.alpha = 1
        exp_progress.startDegree = 0
        exp_progress.progressColor = UIColor(red: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        exp_progress.trackColor = Utilities.lightGrayColor
        exp_progress.trackWidth = 3
        exp_progress.progressWidth = 3
        percent = (((self.user_exp - self.min_exp) / (self.level_up - self.min_exp)))
        progress = 360 * percent
        exp_progress.setEndDegree(CGFloat(progress), timing: TPPropertyAnimationTimingEaseInEaseOut, duration: 1.5, delay: 0)
    }
    
    func sendPushNotification(params: Parameters) {
        UserProfileController.sendPushNotification(params, success: { (data) -> Void in
            },
            failure: { (error) -> Void in
            })
        
    }
    
}
