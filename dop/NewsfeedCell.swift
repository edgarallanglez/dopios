//
//  NewsfeedCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class NewsfeedCell: UITableViewCell {

    @IBOutlet var date_label: UILabel!
    @IBOutlet var username_button: UIButton!
    @IBOutlet var user_image: UIImageView!
    @IBOutlet var newsfeed_description: TTTAttributedLabel!
    @IBOutlet weak var branch_logo: UIImageView!

    @IBOutlet var heart: UIImageView!
    @IBOutlet var likes: UILabel!
    @IBOutlet var heartView: UIView!

    var viewController: NewsfeedViewController?

    var newsfeedNote: NewsfeedNote?
    var index: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func loadItem(_ newsfeed_note: NewsfeedNote, viewController: NewsfeedViewController, index: Int!) {
        self.index = index
        let newsfeed_activity = "\(newsfeed_note.branch_name.uppercased())"
        downloadImage(URL(string: "\(Utilities.dopImagesURL)\(newsfeed_note.company_id)/\(newsfeed_note.branch_image)")!)

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

        self.newsfeedNote = newsfeed_note

        let gesture = UITapGestureRecognizer(target: self, action: #selector(NewsfeedCell.likeActivity(_:)))
        heartView.addGestureRecognizer(gesture)

        self.likes.text = String(newsfeed_note.total_likes)
        self.heart.image = self.heart.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

        if newsfeed_note.user_like == true { self.heart.tintColor = Utilities.dopColor }
        else { self.heart.tintColor = UIColor.lightGray }

    }

    func likeActivity(_ sender:UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "clients_coupon_id" : String(stringInterpolationSegment: newsfeedNote!.client_coupon_id) as AnyObject,
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
                let params: [String: AnyObject] = [ "user_two_id": self.newsfeedNote?.user_id as AnyObject ]
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
        let view_controller = self.viewController?.storyboard!.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
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
        self.newsfeedNote!.setUserLike(true,total_likes: totalLikes)
    }

    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGray
        let totalLikes = (Int(self.likes.text!))!-1
        self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.newsfeedNote!.setUserLike(false,total_likes: totalLikes)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func downloadImage(_ url: URL) {
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value{
                self.branch_logo.image = image
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
}
