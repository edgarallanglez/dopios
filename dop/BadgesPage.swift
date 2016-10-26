//
//  BadgesPage.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

@objc protocol BadgePageDelegate {
    @objc optional func resizeBadgeView(_ dynamic_height: CGFloat)
}

class BadgesPage: UICollectionViewController {
    var delegate: BadgePageDelegate?
    
    @IBOutlet var badgeCollectionView: UICollectionView!
    
    var parent_view: UserProfileStickyController!
    var parent_page_controller: UserPaginationViewController!
    
    var cached_images: [String: UIImage] = [:]
    var badge_array: [BadgeModel] = [BadgeModel]()
    var frame_width: CGFloat!
    var frame_height: CGFloat = 270
    var cell_size: CGFloat!
    var offset = 5
    var new_data: Bool = false
    var added_values: Int = 0
    var loader:MMMaterialDesignSpinner!
    
    override func viewDidLoad() {
        self.collectionView!.isScrollEnabled = false
        self.collectionView!.alwaysBounceVertical = false
        
        frame_width = self.badgeCollectionView.frame.size.width
        cell_size = ((self.frame_width ) / 3) - 9
        setupLoader()
    }
    func setupLoader(){
        loader = MMMaterialDesignSpinner(frame: CGRect(x: 0,y: 70,width: 50,height: 50))
        loader.center.x = self.view.center.x
        loader.lineWidth = 3.0
        loader.startAnimating()
        loader.tintColor = Utilities.dopColor
        self.view.addSubview(loader)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if badge_array.count == 0 { getBadges() }
        else { reload() }
        
    }
    
    func setFrame() {
        if cell_size != nil {
            frame_height = ceil(CGFloat((Double(badge_array.count) / 3.0)))
            frame_height = (frame_height * cell_size) + 40
        }
        
        delegate?.resizeBadgeView!(frame_height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cell_size, height: cell_size)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: BadgeCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "badgeCell", for: indexPath) as! BadgeCollectionCell
        
        if !badge_array.isEmpty {
            let model = self.badge_array[(indexPath as NSIndexPath).row]
            
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
                    }
                }
            }
        }
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.badge_array.count
    }
    
    func getBadges() {
        BadgeController.getAllBadgesWithSuccess(parent_view.user_id,
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
                        let users_badges_id = subJson["users_badges_id"].int!
                        
                        let model = BadgeModel(badge_id: badge_id, name: name, info: info, user_id: user_id, reward_date: reward_date, earned: earned, users_badges_id: users_badges_id)
                        
                        self.badge_array.append(model)
                        
                    } else {
                        let model = BadgeModel(badge_id: badge_id, earned: earned, name: name, info: info)
                        self.badge_array.append(model)
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    self.reload()
                    Utilities.fadeInFromBottomAnimation((self.collectionView)!, delay: 0, duration: 1, yPosition: 20)
                    Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                });
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                })
        })
    }
    
    func reload() {
        if self.parent_page_controller.index == 1 {
            self.badgeCollectionView.reloadData()
            DispatchQueue.main.async(execute: { () -> Void in
                self.setFrame()
            })
        }
    }
    
    func reloadWithOffset(_ parent_scroll: UICollectionView) {
        if badge_array.count != 0 {
            BadgeController.getAllBadgesOffsetWithSuccess(parent_view.user_id, last_badge: self.badge_array[0].users_badges_id!, offset: offset,
                success: { (data) -> Void in
                    let json = data!
                    print(json)
                    self.new_data = false
                    self.added_values = 0
                    
                    for (_, subJson): (String, JSON) in json["data"] {
                        
                        let badge_id = subJson["badge_id"].int!
                        let earned = subJson["earned"].bool!
                        let name = subJson["name"].string!
                        let info = subJson["info"].string!
                        let user_id = subJson["user_id"].int!
                        let reward_date = subJson["reward_date"].string ?? ""
                        let users_badges_id = subJson["users_badges_id"].int!

                        let model = BadgeModel(badge_id: badge_id, name: name, info: info, user_id: user_id, reward_date: reward_date, earned: earned, users_badges_id: users_badges_id)
                        
                        self.badge_array.append(model)
                        self.new_data = true
                        self.added_values += 1
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.reload()
                        if self.new_data { self.offset += self.added_values }
                        parent_scroll.finishInfiniteScroll()

                    });
                },
                failure: { (error) -> Void in
                    DispatchQueue.main.async(execute: {
                        parent_scroll.finishInfiniteScroll()
                    })
            })
        } else { parent_scroll.finishInfiniteScroll() }
        
    }
//    override func viewDidLayoutSubviews() {
//        self.collectionView?.setContentOffset(CGPointZero, animated: true)
////        self.view.layoutIfNeeded()
//    }
}
