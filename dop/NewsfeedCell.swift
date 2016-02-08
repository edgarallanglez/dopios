//
//  NewsfeedCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NewsfeedCell: UITableViewCell {

    @IBOutlet var date_label: UILabel!
    @IBOutlet var username_button: UIButton!
    @IBOutlet var user_image: UIImageView!
    @IBOutlet var newsfeed_description: TTTAttributedLabel!
    @IBOutlet weak var branch_logo: UIImageView!
    
    @IBOutlet var heart: UIImageView!
    @IBOutlet var likes: UILabel!
    @IBOutlet var heartView: UIView!
    
    var viewController:UIViewController?
    
    var newsfeedNote:NewsfeedNote?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func loadItem(newsfeed_note: NewsfeedNote, viewController: UIViewController) {
        
     
        
        let newsfeed_activity = "\(newsfeed_note.branch_name.uppercaseString)"
    
        downloadImage(NSURL(string: "\(Utilities.dopImagesURL)\(newsfeed_note.company_id)/\(newsfeed_note.branch_image)")!)
        
        //////////
        let notification_text = "Asistió a \(newsfeed_activity)"
        
        newsfeed_description.text = notification_text
        let ns_string = notification_text as NSString
        let newsfeed_activity_range = ns_string.rangeOfString(newsfeed_activity)
        let segue = NSURL(string: "branchProfile")!

        newsfeed_description.addLinkToURL(segue, withRange: newsfeed_activity_range)
        //////////////
        
        self.user_image.layer.masksToBounds = true
        self.user_image.layer.cornerRadius = 25
        self.user_image.alpha=0
        self.username_button.setTitle(newsfeed_note.names.uppercaseString, forState: UIControlState.Normal)
        self.username_button.addTarget(self, action: "goToUserProfile:", forControlEvents: UIControlEvents.TouchUpInside)
        self.viewController=viewController
        self.date_label.text = Utilities.friendlyDate(newsfeed_note.date)
        
        self.newsfeedNote = newsfeed_note
        
        let gesture = UITapGestureRecognizer(target: self, action: "likeActivity:")
        heartView.addGestureRecognizer(gesture)
        
        
        self.likes.text = String(newsfeed_note.total_likes)
        
        self.heart.image = self.heart.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        if(newsfeed_note.user_like == 1){
            self.heart.tintColor = Utilities.dopColor
        } else {
            self.heart.tintColor = UIColor.lightGrayColor()
        }
        
    }
    
    func likeActivity(sender:UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "clients_coupon_id" : String(stringInterpolationSegment: newsfeedNote!.client_coupon_id),
            "date" : "2015-01-01"]
        
        var liked:Bool;
        
        if(self.heart.tintColor == UIColor.lightGrayColor()){
            self.setCouponLike()
            liked = true
        }else{
            self.removeCouponLike()
            liked = false
        }
        
        print(params)
        NewsfeedController.likeFriendsActivityWithSuccess(params,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: couponsData)
                    print(json)
                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if(liked == true){
                        self.removeCouponLike()
                    }else{
                        self.setCouponLike()
                    }
                })
        })
    }
    
    
    
    func goToUserProfile(_: UIButton!){
        self.viewController!.performSegueWithIdentifier("userProfile", sender: self)
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
        let totalLikes = (Int(self.likes.text!))!+1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.newsfeedNote!.setUserLike(1,total_likes: totalLikes)
    }
    
    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGrayColor()
        let totalLikes = (Int(self.likes.text!))!-1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.newsfeedNote!.setUserLike(0,total_likes: totalLikes)
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func downloadImage(url: NSURL) {
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.branch_logo.image = UIImage(data: data!)
            }
        }
    }
    
}
