//
//  BadgesPage.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol BadgePageDelegate {
    optional func resizeBadgeView(dynamic_height: CGFloat)
}

class BadgesPage: UICollectionViewController {
    var delegate: BadgePageDelegate?
    
    @IBOutlet var badgeCollectionView: UICollectionView!
    
    var parent_view: UserProfileStickyController!
    
    var cached_images: [String: UIImage] = [:]
    var badge_array: [BadgeModel] = [BadgeModel]()
    var frame_width: CGFloat!
    var frame_height: CGFloat = 270
    var cell_size: CGFloat!
    
    override func viewDidLoad() {
        self.collectionView!.scrollEnabled = false
        self.collectionView!.alwaysBounceVertical = false
        
        frame_width = self.badgeCollectionView.frame.size.width
        cell_size = (self.frame_width ) / 3
    }
    
    override func viewDidAppear(animated: Bool) {
        if badge_array.count == 0 { getBadges() } else { setFrame() }
    }
    
    func setFrame() {
        if cell_size != nil {
            frame_height = ceil(CGFloat((badge_array.count / 3)))
            frame_height = frame_height * cell_size
        }
        
        //self.badgeCollectionView.frame.size.height = frame_height
        delegate?.resizeBadgeView!(frame_height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(cell_size, cell_size)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: BadgeCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("badgeCell", forIndexPath: indexPath) as! BadgeCollectionCell
        
        if(!badge_array.isEmpty){
            let model = self.badge_array[indexPath.row]
            
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
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.badge_array.count
    }
    
    func getBadges() {
        BadgeController.getAllBadgesWithSuccess(
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
                        
                        let model = BadgeModel(badge_id: badge_id, name: name, info: info, user_id: user_id, reward_date: reward_date, earned: earned)
                        
                        self.badge_array.append(model)
                        
                    } else {
                        let model = BadgeModel(badge_id: badge_id, earned: earned, name: name, info: info)
                        self.badge_array.append(model)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.reload()
                    //self.refreshControl.endRefreshing()
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
        })
    }
    
    func reload() {
        self.badgeCollectionView.reloadData()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.setFrame()
        })
    }
    
    func reloadWithOffset() {
        print("llegue hasta abajo en badges :D")
        
    }
    
//    override func viewDidLayoutSubviews() {
//        self.badgeCollectionView.frame.size.height = self.frame_height
//    }
}
