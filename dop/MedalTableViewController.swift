//
//  MedalTableViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/21/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class MedalTableViewController: UITableViewController {
    
    @IBOutlet var table_view: UITableView!
    
    var medal_list = [BadgeModel]()
    var cached_images: [String: UIImage] = [:]
    
    
    override func viewDidLoad() {
        getMedals()
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medal_list.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: BadgeCell = tableView.dequeueReusableCellWithIdentifier("BadgeCell", forIndexPath: indexPath) as! BadgeCell
        
        if(!medal_list.isEmpty){
            let model = self.medal_list[indexPath.row]
            
            cell.loadItem(model)
            let imageUrl = NSURL(string: "\(Utilities.badgeURL)\(model.badge_id).png")
            let identifier = "Cell\(indexPath.row)"
            
            if (self.cached_images[identifier] != nil){
                let cell_image_saved : UIImage = self.cached_images[identifier]!
                cell.badge_image.image = cell_image_saved
            } else {
                Utilities.getDataFromUrl(imageUrl!) { photo in
                    dispatch_async(dispatch_get_main_queue()) {
                        let imageData: NSData = NSData(data: photo!)
                        cell.badge_image.image = UIImage(data: imageData)
                        UIView.animateWithDuration(0.5, animations: {
                            //alpha = 1
                        })
                    }
                }
            }
            
            if !model.earned { cell.backgroundColor = Utilities.lightGrayColor }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        
        return cell
    }
    
    func getMedals() {
        BadgeController.getAllMedalsWithSuccess(
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
                        let users_badges_id = subJson["users_badges_id"].int!
                        
                        let model = BadgeModel(badge_id: badge_id, name: name, info: info, user_id: user_id, reward_date: reward_date, earned: earned, users_badges_id: users_badges_id)
                        
                        self.medal_list.append(model)
                        
                    } else {
                        let model = BadgeModel(badge_id: badge_id, earned: earned, name: name, info: info)
                        self.medal_list.append(model)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.table_view.reloadData()
                    //self.refreshControl.endRefreshing()
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
            })
        })
        
    }
}
