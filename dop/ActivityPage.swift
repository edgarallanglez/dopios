//
//  ActivityTable.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class ActivityPage: UITableViewController {
    
    @IBOutlet var activityTableView: UITableView!

    var cached_images: [String: UIImage] = [:]
    var tableViewSize: CGFloat!
    var activity_array = [NewsfeedNote]()
    var frame_width: CGFloat!
    var parent_view: UserProfileStickyController!
    
    override func viewDidLoad() {
        self.tableView.alwaysBounceVertical = false
        self.tableView.scrollEnabled = false
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        let nib = UINib(nibName: "RewardsActivityCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "RewardsActivityCell")
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = 140
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setParentView:", name: "SetParentView", object: nil)
        
        getActivity()
    }
    
    func getHeight() -> CGFloat! {
        return self.tableViewSize
    }
    
    override func viewDidAppear(animated: Bool) {
        setFrame()
    }
    
    func setFrame() {
        self.tableView.frame.size.height = self.tableView.contentSize.height
        NSNotificationCenter.defaultCenter().postNotificationName("PageLoaded", object: self.view)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activity_array.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: RewardsActivityCell = tableView.dequeueReusableCellWithIdentifier("RewardsActivityCell", forIndexPath: indexPath) as! RewardsActivityCell
        
        let model = self.activity_array[indexPath.row]
        
        if self.parent_view.user_image.image != nil {
            cell.user_image.image = self.parent_view.user_image.image
        } else {
            downloadImage(NSURL(string: self.parent_view.person.main_image)!, cell: cell)
        }
        
        cell.loadItem(model, view: self)
        return cell
    }
    
    
    func getActivity() {
        UserProfileController.getAllTakingCouponsWithSuccess(User.user_id, limit: 6, success: { (data) -> Void in
            let json = JSON(data: data)
            
            for (_, subJson): (String, JSON) in json["data"] {
                let client_coupon_id = subJson["clients_coupon_id"].int
                let friend_id = subJson["friends_id"].string
                let exchange_date = subJson["exchange_date"].string
                let main_image = subJson["main_image"].string
                let names = subJson["names"].string
                let company_id = subJson["company_id"].int ?? 0
                let longitude = subJson["longitude"].string
                let latitude = subJson["latitude"].string
                let branch_id =  subJson["branch_id" ].int
                let coupon_id =  subJson["coupon_id"].string
                let logo =  subJson["logo"].string
                let surnames =  subJson["surnames"].string
                let user_id =  subJson["user_id"].int
                let name =  subJson["name"].string
                let branch_name =  subJson["branch_name"].string
                let total_likes =  subJson["total_likes"].int!
                let user_like =  subJson["user_like"].int
                let date =  subJson["used_date"].string
                
                let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like, date:date)
                
                self.activity_array.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.reload()
                self.setFrame()

            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    //                    self.refreshControl.endRefreshing()
                })
        })
    }
    
    func reload() {
        self.tableView.reloadData()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("PageLoaded", object: self.view)
        })
    }
    
    override func viewDidLayoutSubviews() {
        self.activityTableView.frame.size.width = UIScreen.mainScreen().bounds.width
        
    }
    
    func setParentView(notification: NSNotification) {
        self.parent_view = notification.object as! UserProfileStickyController
    }
    
    func downloadImage(url: NSURL, cell: RewardsActivityCell) {
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                cell.user_image.image = UIImage(data: data!)
            }
        }
    }
    
}
