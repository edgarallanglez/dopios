//
//  RewardsActivity.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/2/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class RewardsActivityCell: UITableViewCell {
    
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var user_name: UIButton!
    @IBOutlet weak var activity_description: TTTAttributedLabel!
    @IBOutlet weak var moment: UILabel!
    @IBOutlet weak var branch_image: UIImageView!
    @IBOutlet weak var total_likes: UILabel!
    @IBOutlet weak var heart: UIImageView!
    @IBOutlet weak var heartView: UIView!
    
    var viewController: UIViewController!
    var activity_model: NewsfeedNote!
    
    func loadItem(_ model: NewsfeedNote, viewController: UIViewController) {
        self.viewController = viewController
        self.activity_model = model
        self.user_name.setTitle(model.names.uppercased(), for: UIControlState())
        
        
        
        downloadImage(URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.branch_image)")!)
        
        self.total_likes.text = "\(model.total_likes)"
        let newsfeed_activity = "\(model.branch_name.uppercased())"
        //////////
        let notification_text = "Asistió a \(newsfeed_activity)"
        
        activity_description.text = notification_text
        let ns_string = notification_text as NSString
        let newsfeed_activity_range = ns_string.range(of: newsfeed_activity)
        let segue = URL(string: "branchProfile:\(model.branch_id)")!
        
        self.moment.text = Utilities.friendlyDate(model.date)
        
        
        activity_description.addLink(to: segue, with: newsfeed_activity_range)
        
        self.branch_image.tag = model.branch_id
        self.branch_image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RewardsActivityCell.goToBranchProfile(_:))))
        
//        self.moment.text = Utilities.friendlyDate(model.date)
        
       
        
        
        self.total_likes.text = String(model.total_likes)
        self.heart.image = self.heart.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        if model.user_like == true { self.heart.tintColor = Utilities.dopColor }
        else { self.heart.tintColor = UIColor.lightGray }
        
        if model.private_activity == true {
            self.heart.image = UIImage(named: "lockIcon")
            self.total_likes.isHidden = true
        }else{
             self.heartView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RewardsActivityCell.likeActivity(_:))))
        }
        //////////////
    
    }
    
    func downloadImage(_ url: URL) {
        Utilities.downloadImage(url, completion: {(data, error) -> Void in
            if let image = UIImage(data: data!) {
                DispatchQueue.main.async {
                    self.branch_image.image = image
                }
            }else{
                print("Error")
            }
        })
    }
    
    func goToBranchProfile(_ sender: UIGestureRecognizer!){
        let view_controller = self.viewController?.storyboard!.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
        view_controller.branch_id = sender.view!.tag
        self.viewController!.navigationController?.pushViewController(view_controller, animated: true)
    }
    
    func likeActivity(_ sender: UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "clients_coupon_id" : String(stringInterpolationSegment: activity_model!.client_coupon_id) as AnyObject,
            "date" : "2015-01-01" as AnyObject]
        
        var liked:Bool;
        
        if self.heart.tintColor == UIColor.lightGray {
            self.setCouponLike()
            liked = true
        } else {
            self.removeCouponLike()
            liked = false
        }
        
        print(params)
        NewsfeedController.likeFriendsActivityWithSuccess(params,
            success: { (data) -> Void in
                DispatchQueue.main.async(execute: {
                    let json = data!
                    print(json)
                })
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    if liked { self.removeCouponLike() } else { self.setCouponLike() }
                })
        })
    }
    
    func setCouponLike() {
        heart.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
                self.heart.transform = CGAffineTransform.identity
            }, completion: nil)
        
        self.heart.tintColor = Utilities.dopColor
        let totalLikes = (Int(self.total_likes.text!))!+1
        self.total_likes.text = String(stringInterpolationSegment: totalLikes)
        self.activity_model!.setUserLike(true,total_likes: totalLikes)
    }
    
    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGray
        let totalLikes = (Int(self.total_likes.text!))!-1
        self.total_likes.text = String(stringInterpolationSegment: totalLikes)
        self.activity_model!.setUserLike(false,total_likes: totalLikes)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.user_image.layer.masksToBounds = true
        self.user_image.layer.cornerRadius = self.user_image.frame.width / 2
    }
}
