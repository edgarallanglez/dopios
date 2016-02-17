//
//  FriendsViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var friendScrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followingTableView: UITableView!
    @IBOutlet weak var friendSegmentedController: FriendSegmentedController!
    
    var current_table: String = "all"
    var friends = [Friend]()
    var following = [Friend]()
    var cachedImages: [String: UIImage] = [:]
    var cachedFollowingImages: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        getAllPeople()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView { return friends.count } else { return following.count }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("FriendCell") as! FriendCell;
        var model: Friend
        if tableView == self.tableView { model = self.friends[indexPath.row] } else { model = self.following[indexPath.row] }
        
        let imageUrl = NSURL(string: model.main_image)
        cell.loadItem(model, viewController: self)

        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        ////////
        let identifier = "Cell\(indexPath.row)"
        if tableView == self.tableView {
            if (self.cachedImages[identifier] != nil){
                let cell_image_saved : UIImage = self.cachedImages[identifier]!
                cell.user_image.image = cell_image_saved
                cell.user_image.alpha = 1
                
            } else {
                cell.user_image.alpha = 1

                Utilities.getDataFromUrl(imageUrl!) { data in
                    dispatch_async(dispatch_get_main_queue()) {
                        var cell_image : UIImage = UIImage()
                        cell_image = UIImage (data: data!)!
                        
                        if tableView.indexPathForCell(cell)?.row == indexPath.row {
                            self.cachedImages[identifier] = cell_image
                            let cell_image_saved : UIImage = self.cachedImages[identifier]!
                            cell.user_image.image = cell_image_saved
                            UIView.animateWithDuration(0.5, animations: {
                                cell.user_image.alpha = 1
                            })
                        }
                    }
                }
            }
        } else {
            if (self.cachedFollowingImages[identifier] != nil){
                let cell_image_saved : UIImage = self.cachedFollowingImages[identifier]!
                cell.user_image.image = cell_image_saved
                cell.user_image.alpha = 1
                
            } else {
                cell.user_image.alpha = 1
                
                Utilities.getDataFromUrl(imageUrl!) { data in
                    dispatch_async(dispatch_get_main_queue()) {
                        var cell_image : UIImage = UIImage()
                        cell_image = UIImage (data: data!)!
                        
                        if tableView.indexPathForCell(cell)?.row == indexPath.row {
                            self.cachedFollowingImages[identifier] = cell_image
                            let cell_image_saved : UIImage = self.cachedFollowingImages[identifier]!
                            cell.user_image.image = cell_image_saved
                            UIView.animateWithDuration(0.5, animations: {
                                cell.user_image.alpha = 1
                            })
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: FriendCell = tableView.cellForRowAtIndexPath(indexPath) as! FriendCell
        self.performSegueWithIdentifier("friendUserProfile", sender: cell)
    }
    
    func getAllPeople() {
        friends.removeAll()
        cachedImages.removeAll()
        FriendsController.getAllFriendsWithSuccess(
            success:{ (friendsData) -> Void in
                let json = JSON(data: friendsData)
                
                for (_, subJson): (String, JSON) in json["data"] {
                    let friend_id = subJson["friends_id"].int
                    let user_id = subJson["user_id"].int
                    let user_name = subJson["names"].string
                    let user_surnames = subJson["surnames"].string
                    let main_image = subJson["main_image"].string
                    let friend = subJson["friend"].bool!
                    let birth_date = subJson["birth_date"].string!
                    let privacy_status = subJson["privacy_status"].int
                    let facebook_key = subJson["facebook_key"].string ?? ""
                    
                    let model = Friend(friend_id: friend_id, user_id: user_id, names: user_name, surnames: user_surnames, main_image: main_image, friend: friend, birth_date: birth_date, privacy_status: privacy_status, facebook_key: facebook_key)
                    
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
    
    func getFollowings() {
        following.removeAll()
        cachedFollowingImages.removeAll()
        FriendsController.getAllFollowingWithSuccess(
            success:{ (friendsData) -> Void in
                let json = JSON(data: friendsData)
                print(json)
                for (_, subJson): (String, JSON) in json["data"] {
                    let friend_id = subJson["friends_id"].int
                    let user_id = subJson["user_id"].int
                    let user_name = subJson["names"].string ?? ""
                    let user_surnames = subJson["surnames"].string ?? ""
                    let main_image = subJson["main_image"].string ?? ""
                    let friend = subJson["friend"].bool!
                    let birth_date = subJson["birth_date"].string!
                    let privacy_status = subJson["privacy_status"].int
                    let facebook_key = subJson["facebook_key"].string ?? ""
                    
                    let model = Friend(friend_id: friend_id, user_id: user_id, names: user_name, surnames: user_surnames, main_image: main_image, friend: friend, birth_date: birth_date, privacy_status: privacy_status, facebook_key: facebook_key)
                    
                    self.following.append(model)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.followingTableView.reloadData()
                });
            },
            failure: {(error) -> Void in
                print(error)
        })
    }
    
    @IBAction func setPeopleTarget(sender: FriendSegmentedController) {
        switch sender.selectedIndex {
        case 0:
//            tableView.reloadData()
            print("holis")
        case 1:
            getFollowings()
            self.current_table = "following"
//            followingTableView.reloadData()
        default:
            print("Oops!")
        }
        let x = CGFloat(sender.selectedIndex) * self.friendScrollView.frame.size.width
        self.friendScrollView.setContentOffset(CGPointMake(x, 0), animated: true)
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
            
            var model: Friend
            if current_table == "all" {
                let i = self.tableView.indexPathForCell(cell)!.row
                model = self.friends[i]
            } else {
                let i = self.followingTableView.indexPathForCell(cell)!.row
                model = self.following[i]
            }
            
            if segue.identifier == "friendUserProfile" {
                let view = segue.destinationViewController as! UserProfileStickyController
                view.user_id = model.user_id
                view.user_image_path = model.main_image
                view.user_image = cell.user_image
                let person = PeopleModel(names: model.names, surnames: model.surnames, user_id: model.user_id, birth_date: model.birth_date, facebook_key: model.facebook_key, privacy_status: model.privacy_status, main_image: model.main_image, is_friend: model.friend)
                view.person = person
                view.user_name = model.names
            }
        }
    }

    

}
