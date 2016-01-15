//
//  TrophyViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 9/30/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TrophyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIAlertViewDelegate {
    
    @IBOutlet weak var collection_view: UICollectionView!
    
    var trophy_list = [BadgeModel]()
    var cached_images: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        getTrophies()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trophy_list.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = collection_view.frame.width / 3
        return CGSizeMake(size, size)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("trophy_identifier", forIndexPath: indexPath) as! TrophyCollectionCell
        
        let model = trophy_list[indexPath.row]
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
        
        return cell
    }
    
    func getTrophies() {
        BadgeController.getAllBadgesWithSuccess(3,
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
                        
                        self.trophy_list.append(model)

                    } else {
                        let model = BadgeModel(badge_id: badge_id, earned: earned, name: name, info: info)
                        self.trophy_list.append(model)
                    }
            }
                dispatch_async(dispatch_get_main_queue(), {
                    self.collection_view.reloadData()
                    //self.refreshControl.endRefreshing()
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
            })
        })

    }
    func launchBadgeAlert() {
        self.presentViewController(AlertClass().launchAlert(), animated: true, completion: nil)
    }
    
}
