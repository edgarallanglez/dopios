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
    
//    @IBOutlet weak var getProfileButton: UIButton!
    
    var friend_id: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func loadItem(person: Friend, viewController: UIViewController) {
        
        if person.friend {
            self.setFollowButton.backgroundColor = Utilities.dopColor
            self.setFollowButton.setTitle("SIGUIENDO", forState: UIControlState.Normal)
            self.setFollowButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        } else {
            self.setFollowButton.layer.borderWidth = 1
            self.setFollowButton.layer.borderColor = Utilities.dopColor.CGColor
        }
        
        name.text = person.names
        self.friend_id = person.friend_id

        user_image.layer.masksToBounds = true
//        user_image.layer.cornerRadius = user_image.frame.width / 2
        
//        Utilities.getDataFromUrl(image) { data in
//            dispatch_async(dispatch_get_main_queue()) {
////                print("Finished downloading \"\(image.lastPathComponent!.URLByDeletingPathExtension)\".")
//                self.user_image.image = UIImage(data: data!)
//            }
//        }
        
//        getProfileButton.setTitle(String.fontAwesomeString("fa-chevron-right"), forState: .Normal)
        
    }
    
    @IBAction func getProfile(sender: UIButton) {
    }
    
    func deleteFriend(sender: UIButton!){
        let params:[String: Int] = [
            "friends_id": friend_id]
        
        FriendsController.deleteFriend(params,
            success:{(friendsData) -> Void in
                let json = JSON(data: friendsData)
            
                print(json)
            },
            failure:{(error) -> Void in
                
            })
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func setFollow(sender: UIButton) {
        let params:[String: AnyObject] = [
            "user_two_id": self.friend_id
        ]
        
        UserProfileController.followFriendWithSuccess(params, success: { (data) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.setFollowButton.setImage(nil, forState: UIControlState.Normal)
                    
                    self.setFollowButton.backgroundColor = UIColor(red: 248/255, green: 20/255, blue: 90/255, alpha: 1)
//                    self.follow_button_width.constant = CGFloat(100)
//                    self.view.layoutIfNeeded()
                    }, completion: { (Bool) in
                        self.setFollowButton.setTitle("DEJAR DE SEGUIR", forState: UIControlState.Normal)
                        
                })
            })
            },
            failure: { (data) -> Void in
                dispatch_async(dispatch_get_main_queue(), {})
                
        })

        
    }
    
}
