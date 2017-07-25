//
//  NewsfeedHeaderView.swift
//  dop
//
//  Created by Edgar Allan Glez on 4/29/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class NewsfeedFirstCell: UITableViewCell {

    @IBOutlet var date_label: UILabel!
    @IBOutlet var username_button: UIButton!
    @IBOutlet var user_image: UIImageView!
    @IBOutlet var newsfeed_description: TTTAttributedLabel!
    @IBOutlet weak var branch_logo: UIImageView!
    
    @IBOutlet var heart: UIImageView!
    @IBOutlet var likes: UILabel!
    @IBOutlet var heartView: UIView!
    
    var viewController: NewsfeedViewController?
    var newsfeed: Newsfeed?
    var index: Int!
    var cachedImages: [Int: UIImage] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadItem(_ newsfeed_note: Newsfeed, viewController: NewsfeedViewController, index: Int!) {
        self.index = index
        let newsfeed_activity = "\(newsfeed_note.branch_name.uppercased())"
        
        //downloadImage(NSURL(string: "\(newsfeed_note.user_image)")!)
        
        //////////
        let notification_text = "Asistió a \(newsfeed_activity)"
        
        newsfeed_description.text = notification_text
        let ns_string = notification_text as NSString
        let newsfeed_activity_range = ns_string.range(of: newsfeed_activity)
        let segue = URL(string: "branchProfile:\(newsfeed_note.branch_id)")!
        
        newsfeed_description.addLink(to: segue, with: newsfeed_activity_range)
        //////////////
        
        self.user_image.alpha = 0
        self.user_image.layoutIfNeeded()
        
        self.username_button.setTitle(newsfeed_note.names.uppercased(), for: UIControlState())
        self.username_button.addTarget(self, action: #selector(NewsfeedCell.goToUserProfile(_:)), for: UIControlEvents.touchUpInside)
        self.user_image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewsfeedCell.goToUserProfile(_:))))
        self.branch_logo.tag = newsfeed_note.branch_id
        self.branch_logo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewsfeedCell.goToBranchProfile(_:))))
        self.viewController = viewController
        self.date_label.text = Utilities.friendlyDate(newsfeed_note.date)
        
        self.newsfeed = newsfeed_note
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(NewsfeedCell.likeActivity(_:)))
        heartView.addGestureRecognizer(gesture)
        
        self.likes.text = String(newsfeed_note.total_likes)
        self.heart.image = self.heart.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        if newsfeed_note.user_like == true { self.heart.tintColor = Utilities.dopColor }
        else { self.heart.tintColor = UIColor.lightGray }
        
    }
    
    func likeActivity(_ sender:UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "clients_coupon_id" : String(stringInterpolationSegment: newsfeed!.client_coupon_id) as AnyObject,
            "date" : "2015-01-01" as AnyObject]
        
        var liked:Bool;
        
        if self.heart.tintColor == UIColor.lightGray {
            self.setCouponLike()
            liked = true
        } else {
            self.removeCouponLike()
            liked = false
        }
        
        NewsfeedController.likeFriendsActivityWithSuccess(params,
                                                          success: { (data) -> Void in
                                                            let params: [String: AnyObject] = [ "user_two_id": self.newsfeed?.user_id as AnyObject ]
                                                            self.sendPushNotification(params: params)
                                                            
        },
                                                          failure: { (error) -> Void in
                                                            DispatchQueue.main.async(execute: {
                                                                if liked { self.removeCouponLike() } else { self.setCouponLike() }
                                                            })
        })
    }
    
    func goToUserProfile(_: UIButton!){
        self.viewController!.goToUserProfile(self.index)
    }
    
    func goToBranchProfile(_ sender: UIGestureRecognizer!){
        
        let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
        let view_controller = storyboard.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
        view_controller.branch_id = sender.view!.tag
        self.viewController!.navigationController?.pushViewController(view_controller, animated: true)
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
        let totalLikes = (Int(self.likes.text!))!+1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.newsfeed!.setUserLike(true,total_likes: totalLikes)
    }
    
    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGray
        let totalLikes = (Int(self.likes.text!))!-1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.newsfeed!.setUserLike(false,total_likes: totalLikes)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func downloadImage(_ url: URL) {
        
        if  self.cachedImages[self.index] != nil {
            let cell_image_saved : UIImage = self.cachedImages[self.index]!
            self.branch_logo.image = cell_image_saved
            self.branch_logo.alpha = 1
        } else {
            self.branch_logo.alpha = 0.3
            self.branch_logo.image = UIImage(named: "dop-logo-transparent")
            self.branch_logo.backgroundColor = Utilities.lightGrayColor
            
            Alamofire.request(url).responseImage { response in
                if let image = response.result.value {
                    self.cachedImages[self.index] = image
                    self.branch_logo.image = image
                    UIView.animate(withDuration: 0.5, animations: {
                        self.branch_logo.alpha = 1
                    })
                }
            }
        }
        
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.user_image.layer.cornerRadius = self.user_image.frame.width / 2
        self.user_image.layer.masksToBounds = true
    }
    
    func sendPushNotification(params: Parameters) {
        UserProfileController.sendLikePushNotification(params, success: { (data) -> Void in
            print(data)
        },
                                                       failure: { (error) -> Void in
                                                        print(error)
        })
        
    }
    
    func setTopBorder() {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners:[.topRight, .topLeft],
                                cornerRadii: CGSize(width: 10, height: 10))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }

    
}
