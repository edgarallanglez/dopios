//
//  NewsfeedViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NewsfeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var newsfeed = [NewsfeedNote]()
    var cachedImages: [String: UIImage] = [:]
    var refreshControl: UIRefreshControl!
    @IBOutlet var tableView: UITableView!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsfeed.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:NewsfeedCell = tableView.dequeueReusableCellWithIdentifier("NewsfeedCell", forIndexPath: indexPath) as! NewsfeedCell
        let model = self.newsfeed[indexPath.row]
        cell.loadItem(model, viewController: self)
        let imageUrl = NSURL(string: model.user_image)
        let identifier = "Cell\(indexPath.row)"
        
        if (self.cachedImages[identifier] != nil){
            let cell_image_saved : UIImage = self.cachedImages[identifier]!
            cell.user_image.image = cell_image_saved
            cell.user_image.alpha = 1
            
        } else {
            cell.user_image.alpha = 0
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
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Que han hecho los perrazos de tus amigos :D!")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        var nib = UINib(nibName: "NewsfeedCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NewsfeedCell")
        
        
        
        getNewsfeedActivity()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender: AnyObject) {
        getNewsfeedActivity()
        newsfeed.removeAll()
    }
    
    func getNewsfeedActivity() {
        NewsfeedController.getAllFriendsTakingCouponsWithSuccess( success: { (friendsData) -> Void in
            let json = JSON(data: friendsData)
            
            for (index: String, subJson: JSON) in json["data"] {
                var client_coupon_id = subJson["clients_coupon_id"].int
                var friend_id = subJson["friends_id"].string
                var exchange_date = subJson["exchange_date"].string
                var main_image = subJson["main_image"].string
                var names = subJson["names"].string
                
                var longitude = subJson["longitude"].string
                let latitude = subJson["latitude"].string
                let branch_id =  subJson["branch_id" ].int
                let coupon_id =  subJson["coupon_id"].string
                let logo =  subJson["logo"].string
                let surnames =  subJson["surnames"].string
                let user_id =  subJson["user_id"].int
                let name =  subJson["name"].string
                let branch_name =  subJson["branch_name"].string
                let total_likes =  subJson["total_likes"].int
                let user_like =  subJson["user_like"].int
                
                let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, branch_image: logo, total_likes:total_likes,user_like: user_like)
                
                self.newsfeed.append(model)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            });
        },
            
        failure: { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl.endRefreshing()
            })
        })

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? NewsfeedCell {

            let i = tableView.indexPathForCell(cell)!.row
            let model = self.newsfeed[i]

            if segue.identifier == "userProfile" {
                let vc = segue.destinationViewController as! UserProfileViewController
                vc.userId = model.user_id
                vc.userImage = model.user_image
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

}
