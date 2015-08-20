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
    
    var friend_id:String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func loadItem(#title: String, image: NSURL, friend_id: String) {
        name.text = title
        self.friend_id = friend_id

        user_image.layer.masksToBounds = true
        user_image.layer.cornerRadius = 22.5
        
        Utilities.getDataFromUrl(image) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(image.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.user_image.image = UIImage(data: data!)
            }
        }
        
        let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = CGRectMake(290, 20, 90, 30)
        button.backgroundColor = UIColor.greenColor()
        button.setTitle("Amigo", forState: UIControlState.Normal)
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.viewForBaselineLayout()!.addSubview(button)
        
        println("Id es \(friend_id)")
        
    }
    
    func buttonAction(sender:UIButton!){
        let params:[String: String] = [
            "friends_id": friend_id]
        
        FriendsController.deleteFriend(params,
            success:{(friendsData) -> Void in
                let json = JSON(data: friendsData)
            
                println(json)
            },
            failure:{(error) -> Void in
                
            })
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
