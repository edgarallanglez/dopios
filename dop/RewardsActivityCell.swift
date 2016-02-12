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
    
    func loadItem(model: NewsfeedNote, viewController: UIViewController) {
        self.viewController = viewController
        self.activity_model = model
        self.user_name.setTitle(model.names.uppercaseString, forState: UIControlState.Normal)
        
        self.user_image.layer.masksToBounds = true
        self.user_image.layer.cornerRadius = self.user_image.frame.width / 2
        
        downloadImage(NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.branch_image)")!)
        
        self.total_likes.text = "\(model.total_likes)"
        let newsfeed_activity = "\(model.branch_name.uppercaseString)"
        //////////
        let notification_text = "Asistió a \(newsfeed_activity)"
        
        activity_description.text = notification_text
        let ns_string = notification_text as NSString
        let newsfeed_activity_range = ns_string.rangeOfString(newsfeed_activity)
        let segue = NSURL(string: "branchProfile:\(model.branch_id)")!
        
        activity_description.addLinkToURL(segue, withRange: newsfeed_activity_range)
        
        self.branch_image.tag = model.branch_id
        self.branch_image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "goToBranchProfile:"))
        
//        self.moment.text = Utilities.friendlyDate(model.date)
        
        self.heartView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeActivity:"))
        
        
        self.total_likes.text = String(model.total_likes)
        self.heart.image = self.heart.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        if model.user_like == 1 { self.heart.tintColor = Utilities.dopColor }
        else { self.heart.tintColor = UIColor.lightGrayColor() }
        //////////////
    
    }
    
    func downloadImage(url: NSURL) {
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.branch_image.image = UIImage(data: data!)
            }
        }
    }
    
    func goToBranchProfile(sender: UIGestureRecognizer!){
        let view_controller = self.viewController?.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
        view_controller.branch_id = sender.view!.tag
        self.viewController!.navigationController?.pushViewController(view_controller, animated: true)
    }
    
    func likeActivity(sender: UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "clients_coupon_id" : String(stringInterpolationSegment: activity_model!.client_coupon_id),
            "date" : "2015-01-01"]
        
        var liked:Bool;
        
        if self.heart.tintColor == UIColor.lightGrayColor() {
            self.setCouponLike()
            liked = true
        } else {
            self.removeCouponLike()
            liked = false
        }
        
        print(params)
        NewsfeedController.likeFriendsActivityWithSuccess(params,
            success: { (data) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: data)
                    print(json)
                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if liked { self.removeCouponLike() } else { self.setCouponLike() }
                })
        })
    }
    
    func setCouponLike() {
        heart.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.heart.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        self.heart.tintColor = Utilities.dopColor
        let totalLikes = (Int(self.total_likes.text!))!+1
        self.total_likes.text = String(stringInterpolationSegment: totalLikes)
        self.activity_model!.setUserLike(1,total_likes: totalLikes)
    }
    
    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGrayColor()
        let totalLikes = (Int(self.total_likes.text!))!-1
        self.total_likes.text = String(stringInterpolationSegment: totalLikes)
        self.activity_model!.setUserLike(0,total_likes: totalLikes)
    }
    
}
