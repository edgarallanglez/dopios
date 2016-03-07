//
//  FriendCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet var user_image: UIImageView!
    @IBOutlet weak var setFollowButton: UIButton!
    
    var person: PeopleModel!
    
//    @IBOutlet weak var getProfileButton: UIButton!
    
    var friend_id: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func loadItem(person: PeopleModel, viewController: UIViewController) {
        self.person = person
        
        if person.is_friend! {
            self.setFollowButton.backgroundColor = Utilities.dopColor
            self.setFollowButton.setTitle("SIGUIENDO", forState: UIControlState.Normal)
            self.setFollowButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        } else {
            self.setFollowButton.layer.borderWidth = 1
            self.setFollowButton.layer.borderColor = Utilities.dopColor.CGColor
        }
        
        name.text = person.names
        self.friend_id = person.user_id

        user_image.layer.masksToBounds = true
    }
    
    @IBAction func getProfile(sender: UIButton) {
    }
    
    func deleteFriend(){
        let params:[String: Int] = [
            "friends_id": self.friend_id]
        
        FriendsController.deleteFriend(params,
            success:{(data) -> Void in
                let json = JSON(data: data)
                dispatch_async(dispatch_get_main_queue(), {
                    UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                            self.setFollowButton.layer.borderWidth = 1
                            self.setFollowButton.backgroundColor = UIColor.whiteColor()
                            self.setFollowButton.setTitle("SEGUIENDO", forState: UIControlState.Normal)
                            self.setFollowButton.layer.borderColor = Utilities.dopColor.CGColor
                            self.setFollowButton.setTitleColor(Utilities.dopColor, forState: UIControlState.Normal)
                            self.person.is_friend = false
                        }, completion: { (Bool) in
                            
                    })
                })

            },
            failure:{(error) -> Void in
                
            })
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func setFollow(sender: UIButton) {
        
        if !person.is_friend! {
            let params:[String: AnyObject] = [
                "user_two_id": self.friend_id
            ]
            
            UserProfileController.followFriendWithSuccess(params, success: { (data) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        self.setFollowButton.setImage(nil, forState: UIControlState.Normal)
                        
                        self.setFollowButton.backgroundColor = Utilities.dopColor
                        //                    self.follow_button_width.constant = CGFloat(100)
    //                    self.view.layoutIfNeeded()
                        }, completion: { (Bool) in
                            self.person.is_friend = true
                            self.setFollowButton.setTitle("DEJAR DE SEGUIR", forState: UIControlState.Normal)
                            self.setFollowButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    })
                })
                },
                failure: { (data) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {})
                    
            })
        } else {
            deleteFriend()
        }

        
    }
    
}
