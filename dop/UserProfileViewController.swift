//
//  UserProfileViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 20/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var scrollViewBox: UIScrollView!
    @IBOutlet var profile_image: UIImageView!
    var userImage: UIImage!
    var userImagePath:String=""
    var userId:Int!
    var historyCoupon = [Coupon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        profile_image.image = userImage
        profile_image.layer.cornerRadius = 50
        profile_image.layer.masksToBounds = true
        
        UserProfileController.getUserProfile("\(Utilities.dopURL)\(userId)/profile"){ profileData in
            
            let json = JSON(data: profileData)
            print(json)
        }
        
        getCoupons()
        
    }
    
    func downloadImage(url:NSURL) {
//        print("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
//                print("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.profile_image.image = UIImage(data: data!)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getCoupons() {
        historyCoupon.removeAll()
        UserProfileController.getAllUsedCouponsWithSuccess(6, success: { (couponsData) -> Void in
            let json = JSON(data: couponsData)
            
            for (_, subJson): (String, JSON) in json["data"]{
                let coupon_id = subJson["coupon_id"].int
                let coupon_name = subJson["name"].string
                let coupon_description = subJson["description"].string
                let coupon_limit = subJson["limit"].string
                let coupon_exp = "2015-09-30"
                let coupon_logo = subJson["logo"].string
                let branch_id = subJson["branch_id"].int
                let company_id = subJson["company_id"].int
                let total_likes = subJson["total_likes"].int
                let user_like = subJson["user_like"].int
                let latitude = subJson["latitude"].double!
                let longitude = subJson["longitude"].double!
                let banner = subJson["banner"].string ?? ""
                //                    let categoryId = subJson["category_id"].int!
                
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: 1)
                
                self.historyCoupon.append(model)
            }
    
            dispatch_async(dispatch_get_main_queue(), {
                let margin = 18
                let positionX = 18
                let couponWidth = 180
                let couponHeight = 205
                var position = 18
                
                for (index, coupon) in self.historyCoupon.enumerate() {
                    let coupon_box:TrendingCoupon = NSBundle.mainBundle().loadNibNamed("TrendingCoupon", owner: self, options:
                        nil)[0] as! TrendingCoupon
                    
                    if (index % 2 == 0) && (index != 0) {
                        position = positionX + ((margin + couponWidth))
                    } else {
                        position = positionX + ((margin + couponWidth) * index)
                    }
                    coupon_box.move(CGFloat(position))
                    let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(coupon.company_id)/\(coupon.logo)")
                    
                    Utilities.getDataFromUrl(imageUrl!) { photo in
                        dispatch_async(dispatch_get_main_queue()) {
                            let imageData: NSData = NSData(data: photo!)
                            coupon_box.logo.image = UIImage(data: imageData)
                            UIView.animateWithDuration(0.5, animations: {
                                //cell.branch_banner.alpha = 1
                            })
                        }
                    }
                    
                    coupon_box.descriptionLbl.text = coupon.couponDescription
                    //coupon_box.likes = trending[index].likes
                    coupon_box.layer.borderWidth = 0.5
                    coupon_box.layer.borderColor = UIColor.lightGrayColor().CGColor
                    self.scrollViewBox.addSubview(coupon_box);
                }
                
                let trendingScroll_size = ((margin + couponHeight) * self.historyCoupon.count) + margin
                self.scrollViewBox.contentSize = CGSizeMake(self.scrollViewBox.frame.size.width, CGFloat(trendingScroll_size))
            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
        })
        
    }
    
//    override func viewDidAppear() {
////        if let checkedUrl = NSURL(string:userImagePath) {
////            downloadImage(checkedUrl)
////        }
//    }


}
