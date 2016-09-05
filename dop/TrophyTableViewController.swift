//
//  TrophyTableViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/18/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import UIKit

class TrophyTableViewController: UITableViewController {
    
    @IBOutlet var table_view: UITableView!
    
    var trophy_list = [BadgeModel]()
    var cached_images: [String: UIImage] = [:]
    
    
    override func viewDidLoad() {
        getTrophies()
        self.table_view.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trophy_list.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: BadgeCell = tableView.dequeueReusableCellWithIdentifier("BadgeCell", forIndexPath: indexPath) as! BadgeCell
        
        if(!trophy_list.isEmpty){
            let model = self.trophy_list[indexPath.row]
            
            cell.loadItem(model)
            let imageUrl = NSURL(string: "\(Utilities.badgeURL)\(model.badge_id).png")
            
            let identifier = "Cell\(indexPath.row)"
            
            if (self.cached_images[identifier] != nil){
                let cell_image_saved : UIImage = self.cached_images[identifier]!
                cell.badge_image.image = cell_image_saved
            } else {
                Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                    if let image = UIImage(data: data!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.badge_image.image = image
                            UIView.animateWithDuration(0.5, animations: {
                                //alpha = 1
                            })
                        }
                    }else{
                        print("Error")
                    }
                })
            }
            
            if !model.earned { cell.backgroundColor = Utilities.lightGrayColor }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func getTrophies() {
        
        NSNotificationCenter.defaultCenter().postNotificationName("showLoader", object: true)

        BadgeController.getAllTrophiesWithSuccess(
            success: { (data) -> Void in
                let json = JSON(data: data)
                print(json)
                for (_, subJson): (String, JSON) in json["data"] {
                    
                    let badge_id = subJson["badge_id"].int!
                    let earned = subJson["earned"].bool!
                    let name = subJson["name"].string!
                    let info = subJson["info"].string!
                    
                    if earned {
                        let user_id = subJson["user_id"].int!
                        let reward_date = subJson["reward_date"].string ?? ""
                        let users_badges_id = subJson["users_badges_id"].int ?? 0
                        
                        let model = BadgeModel(badge_id: badge_id, name: name, info: info, user_id: user_id, reward_date: reward_date, earned: earned, users_badges_id: users_badges_id)
                        
                        self.trophy_list.append(model)
                        
                    } else {
                        let model = BadgeModel(badge_id: badge_id, earned: earned, name: name, info: info)
                        self.trophy_list.append(model)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.table_view.reloadData()
                    NSNotificationCenter.defaultCenter().postNotificationName("showLoader", object: false)
                    //self.refreshControl.endRefreshing()
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName("showLoader", object: false)
                })
        })
        
    }
}
