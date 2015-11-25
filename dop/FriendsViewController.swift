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
        let cell: FriendCell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        let model = self.friends[indexPath.row]
        let (title) = model.names
        let imageUrl = NSURL(string: model.main_image)
        cell.loadItem(title: title, image: imageUrl!, friend_id: model.friend_id)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: FriendCell = tableView.cellForRowAtIndexPath(indexPath) as! FriendCell
        self.performSegueWithIdentifier("friendUserProfile", sender: cell)
    }
    
    override func viewDidLoad() {
        let nib = UINib(nibName: "FriendCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "FriendCell")
        
        FriendsController.getAllFriendsWithSuccess(
        success:{ (friendsData) -> Void in
            let json = JSON(data: friendsData)
            
            for (_, subJson): (String, JSON) in json["data"] {
                let friend_id = subJson["friends_id"].int
                let user_id = subJson["user_id"].int
                let user_name = subJson["names"].string
                let user_surnames = subJson["surnames"].string
                let main_image = subJson["main_image"].string
                let model = Friend(friend_id: friend_id, user_id: user_id, names: user_name, surnames: user_surnames, main_image: main_image)
                
                self.friends.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            });
        },
        failure: {(error) -> Void in
            print(error)
        })
    }
    
    @IBAction func getFriends(sender: UIBarButtonItem) {
        let content: FBSDKAppInviteContent = FBSDKAppInviteContent()
        content.previewImageURL = NSURL(string: "http://45.55.7.118/branches/images/local/dop_logo.png")
        content.appLinkURL = NSURL(string: "https://fb.me/927375797314743")
        FBSDKAppInviteDialog.showWithContent(content, delegate: nil)

//        var friendsRequest: FBRequest = FBRequest.requestForMyFriends()
//        friendsRequest.startWithCompletionHandler {
//            (connection: FBRequestConnection!, result:AnyObject!, error: NSError!) -> Void in
//                var resultdict = result as! NSDictionary
//                println("Result Dict: \(resultdict)")
//                var data: NSArray = resultdict.objectForKey("data") as! NSArray
//                
//                for i in 0 ..< data.count {
//                    let valueDict : NSDictionary = data[i] as! NSDictionary
//                    let id = valueDict.objectForKey("id") as! String
//                    println("the id value is \(id)")
//                }
//            
//                var friends = resultdict.objectForKey("data") as! NSArray
//                println("Found \(friends.count) friends")
//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? FriendCell {
            
            let i = tableView.indexPathForCell(cell)!.row
            let model = self.friends[i]
            
            if segue.identifier == "friendUserProfile" {
                let view = segue.destinationViewController as! UserProfileViewController
                view.userId = model.user_id
                view.userImagePath = model.main_image
            }
        }
    }

    

}
