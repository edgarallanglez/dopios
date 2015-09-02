//
//  FriendsViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
  
    var friends = [Friend]()

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cell:FriendCell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        
        
        let model = self.friends[indexPath.row]
        
        var (title) = model.names
        let imageUrl = NSURL(string: model.main_image)
        
        cell.loadItem(title: title, image: imageUrl!, friend_id: model.friend_id)
        
        return cell
    }
    
    override func viewDidLoad() {
        var nib = UINib(nibName: "FriendCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "FriendCell")
        
        
        FriendsController.getAllFriendsWithSuccess(
        success:{ (friendsData) -> Void in
            let json = JSON(data: friendsData)
            
            var namex = "";
            for (index: String, subJson: JSON) in json["data"]{
                var friend_id = String(stringInterpolationSegment:subJson["friends_id"])
                var user_id = String(stringInterpolationSegment:subJson["user_id"]).toInt()
                let user_name = String(stringInterpolationSegment: subJson["names"])
                let user_surnames = String(stringInterpolationSegment: subJson["surnames"])
                let main_image = String(stringInterpolationSegment: subJson["main_image"])
                let model = Friend(friend_id: friend_id,user_id: user_id, names: user_name, surnames: user_surnames, main_image: main_image)
                
                self.friends.append(model)
                
                println(json)
                
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            });
        },
        failure:{(friendsData)->Void in
        
        })
    }

}
