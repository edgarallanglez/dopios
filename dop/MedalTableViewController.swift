//
//  MedalTableViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/21/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire

class MedalTableViewController: UITableViewController {
    
    @IBOutlet var table_view: UITableView!
    
    var medal_list = [BadgeModel]()
    var cached_images: [String: UIImage] = [:]
    
    
    override func viewDidLoad() {
        getMedals()
        self.table_view.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medal_list.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BadgeCell = tableView.dequeueReusableCell(withIdentifier: "BadgeCell", for: indexPath) as! BadgeCell
        
        if(!medal_list.isEmpty){
            let model = self.medal_list[(indexPath as NSIndexPath).row]
            
            cell.loadItem(model)
            let imageUrl = URL(string: "\(Utilities.badgeURL)\(model.badge_id).png")
            let identifier = "Cell\((indexPath as NSIndexPath).row)"
            
            if (self.cached_images[identifier] != nil){
                let cell_image_saved : UIImage = self.cached_images[identifier]!
                cell.badge_image.image = cell_image_saved
            } else {
                Alamofire.request(imageUrl!).responseImage { response in
                    if let image = response.result.value{
                        cell.badge_image.image = image
                        UIView.animate(withDuration: 0.5, animations: {
                            if model.earned { cell.badge_image.alpha = 1 }
                            else { cell.badge_image.alpha = 0.3 }
                            //
                        })
                    }
                }

            }
    
            if !model.earned { cell.backgroundColor = Utilities.lightGrayColor }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        
        return cell
    }
    
    func getMedals() {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "showLoader"), object: true)
        BadgeController.getAllMedalsWithSuccess(
            success: { (data) -> Void in
                let json = data!
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
                        
                        self.medal_list.append(model)
                        
                    } else {
                        let model = BadgeModel(badge_id: badge_id, earned: earned, name: name, info: info)
                        self.medal_list.append(model)
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.table_view.reloadData()
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "showLoader"), object: false)
                    //self.refreshControl.endRefreshing()
                });
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "showLoader"), object: false)
            })
        })
        
    }
}
