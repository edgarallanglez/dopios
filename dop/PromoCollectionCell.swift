//
//  PromoCollectionCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Social
import FBSDKShareKit

class PromoCollectionCell: UICollectionViewCell {
    
    @IBOutlet var coupon_description: UILabel!
    @IBOutlet var branch_banner: UIImageView!
    @IBOutlet var heart: UIImageView!
    @IBOutlet var likes: UILabel!
    @IBOutlet var heartView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    
    var viewController: UIViewController?
    
    var couponId: Int!
    
    func loadItem(coupon:Coupon, viewController: UIViewController) {
        coupon_description.text = coupon.couponDescription
        
        var rawString = String.fontAwesomeString("fa-facebook")
        var stringAttributed = NSMutableAttributedString(string: rawString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 1)!])
        stringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("FontAwesome", fontSize: 14), range: NSRange(location: 0,length: 1))
        
        self.shareButton.titleLabel?.textAlignment = .Center
        self.shareButton.titleLabel?.numberOfLines = 1
        self.shareButton.setAttributedTitle(stringAttributed, forState: UIControlState.Normal)
        
        let gesture = UITapGestureRecognizer(target: self, action: "likeCoupon:")
        heartView.addGestureRecognizer(gesture)
        
        self.couponId = coupon.id
        
        self.likes.text = String(coupon.total_likes)
        
        self.viewController = viewController
        
        if(coupon.user_like == 1){
            self.heart.tintColor = Utilities.dopColor
        }else{
            self.heart.tintColor = UIColor.lightGrayColor()
        }
    }
    
    func likeCoupon(sender:UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "coupon_id" : String(stringInterpolationSegment: couponId),
            "date" : "2015-01-01"]

        CouponController.likeCouponWithSuccess(params){ (couponsData) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                let json = JSON(data: couponsData)
                if(self.heart.tintColor == UIColor.lightGrayColor()){
                    self.heart.tintColor = Utilities.dopColor
                    let totalLikes = (self.likes.text!.toInt())!+1
                    self.likes.text = String(stringInterpolationSegment: totalLikes)
                }else{
                    self.heart.tintColor = UIColor.lightGrayColor()
                    let totalLikes = (self.likes.text!.toInt())!-1
                    self.likes.text = String(stringInterpolationSegment: totalLikes)
                }

                println(json)
            });
        }
    }
    
    
    @IBAction func shareCoupon(sender: UIButton) {
//        FBSDKShareButton *button = [[FBSDKShareButton alloc] init];
//        button.shareContent = content;
//        [self.view addSubview:button];
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://www.allan-glez.com/")
        content.contentTitle = "Mira comparto desde DOP para el mundo"
        content.contentDescription = "Luego va a estar InMoon aquí"
        content.imageURL = NSURL(string: "http://45.55.7.118//branches/images/local/dop_logo.png")
        
        FBSDKShareDialog.showFromViewController(self.viewController, withContent: content, delegate: nil)
    }
    
}
