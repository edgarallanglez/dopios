//
//  FriendsViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet var mainLoader: MMMaterialDesignSpinner!
    
    @IBOutlet weak var friendScrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followingTableView: UITableView!
    @IBOutlet weak var friendSegmentedController: FriendSegmentedController!
    
    var current_table: String = "all"
    var friends = [PeopleModel]()
    var following = [PeopleModel]()
    var cachedImages: [String: UIImage] = [:]
    var cachedFollowingImages: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        mainLoader.tintColor = Utilities.dopColor
        mainLoader.lineWidth = 3.0
        
        friendScrollView.isScrollEnabled = false
        
        
        getAllPeople()
        
    }
    /*func scrollViewDidScroll(scrollView: UIScrollView) {
     let pagenumber = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
     
     friendSegmentedController.selectedIndex = pagenumber
     
     
     }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView { return friends.count } else { return following.count }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell;
        var model: PeopleModel
        if tableView == self.tableView { model = self.friends[(indexPath as NSIndexPath).row] } else { model = self.following[(indexPath as NSIndexPath).row] }
        
        let imageUrl = URL(string: model.main_image)
        cell.loadItem(model, viewController: self)
        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        ////////
        let identifier = "Cell\((indexPath as NSIndexPath).row)"
        if tableView == self.tableView {
            if (self.cachedImages[identifier] != nil){
                let cell_image_saved : UIImage = self.cachedImages[identifier]!
                cell.user_image.image = cell_image_saved
                cell.user_image.alpha = 1
                
            } else {
                cell.user_image.alpha = 0.3
                cell.user_image.image = UIImage(named: "dop-logo-transparent")
                cell.user_image.backgroundColor = Utilities.lightGrayColor
                if model.main_image != "" {
                    Alamofire.request(imageUrl!).responseImage { response in
                        if let image = response.result.value{
                            if (tableView.indexPath(for: cell) as NSIndexPath?)?.row == (indexPath as NSIndexPath).row {
                                self.cachedImages[identifier] = image
                                let cell_image_saved : UIImage = self.cachedImages[identifier]!
                                cell.user_image.image = cell_image_saved
                                UIView.animate(withDuration: 0.5, animations: {
                                    cell.user_image.alpha = 1
                                })
                            }
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
                cell.user_image.alpha = 0.3
                cell.user_image.image = UIImage(named: "dop-logo-transparent")
                cell.user_image.backgroundColor = Utilities.lightGrayColor
                
                if model.main_image != "" {
                    Alamofire.request(imageUrl!).responseImage { response in
                        if let image = response.result.value{
                            if (tableView.indexPath(for: cell)?.row == indexPath.row) {
                                self.cachedFollowingImages[identifier] = image
                                let cell_image_saved : UIImage = self.cachedFollowingImages[identifier]!
                                cell.user_image.image = cell_image_saved
                                UIView.animate(withDuration: 0.5, animations: {
                                    cell.user_image.alpha = 1
                                })
                            }
                        }
                    }
                }
                
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: FriendCell = tableView.cellForRow(at: indexPath) as! FriendCell
        let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
        let view_controller = storyboard.instantiateViewController(withIdentifier: "UserProfileStickyController") as! UserProfileStickyController

        view_controller.user_id = cell.friend_id
        view_controller.person = cell.person
        self.navigationController?.pushViewController(view_controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func getAllPeople() {
        friends.removeAll()
        cachedImages.removeAll()
        
        mainLoader.startAnimating()
        
        FriendsController.getAllFriendsWithSuccess(
            success:{ (friendsData) -> Void in
                let json = friendsData!
                
                for (_, subJson): (String, JSON) in json["data"] {
                    let friend_id = subJson["friends_id"].int
                    let user_id = subJson["user_id"].int
                    let user_name = subJson["names"].string
                    let user_surnames = subJson["surnames"].string
                    let main_image = subJson["main_image"].string
                    let friend = subJson["is_friend"].bool!
                    let birth_date = subJson["birth_date"].string ?? ""
                    let privacy_status = subJson["privacy_status"].int ?? 0
                    let facebook_key = subJson["facebook_key"].string ?? ""
                    let level = subJson["level"].int ?? 0
                    let exp = subJson["exp"].double ?? 0
                    let operation_id = subJson["operation_id"].int ?? 5
                    
                    let model = PeopleModel(friend_id: friend_id, user_id: user_id, names: user_name, surnames: user_surnames, main_image: main_image, is_friend: friend, birth_date: birth_date, privacy_status: privacy_status, facebook_key: facebook_key, level: level, exp: exp, operation_id: operation_id)
                    
                    self.friends.append(model)
                }
                
                DispatchQueue.main.async(execute: {
                    self.mainLoader.stopAnimating()
                    
                    self.tableView.reloadData()
                });
        },
            failure: {(error) -> Void in
                self.mainLoader.stopAnimating()
                print(error)
        })
    }
    
    func getFollowings() {
        following.removeAll()
        cachedFollowingImages.removeAll()
        mainLoader.startAnimating()
        FriendsController.getAllFollowingWithSuccess(
            success:{ (friendsData) -> Void in
                let json = friendsData!
                print(json)
                for (_, subJson): (String, JSON) in json["data"] {
                    let friend_id = subJson["friends_id"].int
                    let user_id = subJson["user_id"].int
                    let user_name = subJson["names"].string ?? ""
                    let user_surnames = subJson["surnames"].string ?? ""
                    let main_image = subJson["main_image"].string ?? ""
                    let friend = subJson["is_friend"].bool!
                    let birth_date = subJson["birth_date"].string ?? ""
                    let privacy_status = subJson["privacy_status"].int ?? 0
                    let facebook_key = subJson["facebook_key"].string ?? ""
                    let level = subJson["level"].int ?? 0
                    let exp = subJson["exp"].double ?? 0
                    let operation_id = subJson["operation_id"].int ?? 5
                    
                    
                    let model = PeopleModel(friend_id: friend_id, user_id: user_id, names: user_name, surnames: user_surnames, main_image: main_image, is_friend: friend, birth_date: birth_date, privacy_status: privacy_status, facebook_key: facebook_key, level: level, exp: exp, operation_id: operation_id)
                    
                    self.following.append(model)
                }
                
                DispatchQueue.main.async(execute: {
                    self.followingTableView.reloadData()
                    self.mainLoader.stopAnimating()
                });
        },
            failure: {(error) -> Void in
                print(error)
                self.mainLoader.stopAnimating()
        })
    }
    
    @IBAction func setPeopleTarget(_ sender: FriendSegmentedController) {
        switch sender.selectedIndex {
        case 0:
            self.current_table = "all"
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
        self.friendScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    @IBAction func getFriends(_ sender: UIBarButtonItem) {
        let content: FBSDKAppInviteContent = FBSDKAppInviteContent()
        content.previewImageURL = URL(string: "http://45.55.7.118/branches/images/local/dop_logo.png")
        content.appLinkURL = URL(string: "https://fb.me/1422710034447981")
        
        FBSDKAppInviteDialog.show(with: content, delegate: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? FriendCell {
            
            var model: PeopleModel
            if current_table == "all" {
                let i = (self.tableView.indexPath(for: cell)! as NSIndexPath).row
                model = self.friends[i]
            } else {
                let i = (self.followingTableView.indexPath(for: cell)! as NSIndexPath).row
                model = self.following[i]
            }
            
            if segue.identifier == "friendUserProfile" {
                let view = segue.destination as! UserProfileStickyController
                view.user_id = model.user_id
                view.user_image_path = model.main_image
                view.user_image = cell.user_image
                view.person = model
                view.is_friend = model.is_friend
                view.operation_id = model.operation_id!
                view.user_name = model.names
            }
        }
    }
    
    func sendPushNotification(params: Parameters) {
        UserProfileController.sendPushNotification(params, success: { (data) -> Void in
        },
                                                   failure: { (error) -> Void in
        })
        
    }
    
    
    
}
