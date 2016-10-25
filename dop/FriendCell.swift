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
    
    func loadItem(_ person: PeopleModel, viewController: UIViewController) {
        self.person = person
        
        if person.is_friend! {
            self.setFollowButton.backgroundColor = Utilities.dopColor
            self.setFollowButton.setTitle("SIGUIENDO", for: UIControlState())
            self.setFollowButton.setTitleColor(UIColor.white, for: UIControlState())
        } else {
            self.setFollowButton.layer.borderWidth = 1
            self.setFollowButton.layer.borderColor = Utilities.dopColor.cgColor
        }
        
        name.text = person.names
        self.friend_id = person.user_id

        user_image.layer.masksToBounds = true
    }
    
    @IBAction func getProfile(_ sender: UIButton) {
    }
    
    func deleteFriend(){
        let params:[String: Int] = [
            "friends_id": self.friend_id]
        
        FriendsController.deleteFriend(params as [String : AnyObject],
            success:{(data) -> Void in
                let json = JSON(data: data!)
                DispatchQueue.main.async(execute: {
                    UIButton.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                            self.setFollowButton.layer.borderWidth = 1
                            self.setFollowButton.backgroundColor = UIColor.white
                            self.setFollowButton.setTitle("SEGUIENDO", for: UIControlState())
                            self.setFollowButton.layer.borderColor = Utilities.dopColor.cgColor
                            self.setFollowButton.setTitleColor(Utilities.dopColor, for: UIControlState())
                            self.person.is_friend = false
                        }, completion: { (Bool) in
                            
                    })
                })

            },
            failure:{(error) -> Void in
                
            })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func setFollow(_ sender: UIButton) {
        
        if !person.is_friend! {
            let params:[String: AnyObject] = [
                "user_two_id": self.friend_id as AnyObject
            ]
            
            UserProfileController.followFriendWithSuccess(params, success: { (data) -> Void in
                DispatchQueue.main.async(execute: {
                    UIButton.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                        self.setFollowButton.setImage(nil, for: UIControlState())
                        
                        self.setFollowButton.backgroundColor = Utilities.dopColor
                        //                    self.follow_button_width.constant = CGFloat(100)
    //                    self.view.layoutIfNeeded()
                        }, completion: { (Bool) in
                            self.person.is_friend = true
                            self.setFollowButton.setTitle("DEJAR DE SEGUIR", for: UIControlState())
                            self.setFollowButton.setTitleColor(UIColor.white, for: UIControlState())
                    })
                })
                },
                failure: { (data) -> Void in
                    DispatchQueue.main.async(execute: {})
                    
            })
        } else {
            deleteFriend()
        }

        
    }
    
}
