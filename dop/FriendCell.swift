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
    @IBOutlet weak var getProfileButton: UIButton!
    
    var friend_id: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func loadItem(title title: String, image: NSURL, friend_id: Int) {
        name.text = title
        self.friend_id = friend_id

        user_image.layer.masksToBounds = true
        user_image.layer.cornerRadius = 22.5
        
        Utilities.getDataFromUrl(image) { data in
            dispatch_async(dispatch_get_main_queue()) {
//                print("Finished downloading \"\(image.lastPathComponent!.URLByDeletingPathExtension)\".")
                self.user_image.image = UIImage(data: data!)
            }
        }
        
        getProfileButton.setTitle(String.fontAwesomeString("fa-chevron-right"), forState: .Normal)
        
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
    
}
