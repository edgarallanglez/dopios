//
//  BranchProfileTopView.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/6/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BranchProfileTopView: UIView {
    
    @IBOutlet weak var branch_banner: UIImageView!
    @IBOutlet weak var branch_name: UILabel!
    @IBOutlet weak var branch_logo: UIImageView!
    @IBOutlet weak var follow_button: UIButton!
    @IBOutlet weak var follow_button_width: NSLayoutConstraint!
    
    var branch_id: Int!
    var parent_view: BranchProfileStickyController!

    @IBAction func followBranch(sender: AnyObject) {
        
        let params:[String: AnyObject] = [
            "branch_id" : String(stringInterpolationSegment: parent_view.branch_id),
            "date" : "2015-01-01"]
        
        print(params)
        BranchProfileController.followBranchWithSuccess(params,
            success: { (data) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        self.follow_button.setImage(nil, forState: UIControlState.Normal)
                        
                        self.follow_button.backgroundColor = Utilities.dopColor
                        self.follow_button_width.constant = CGFloat(100)
                        self.layoutIfNeeded()
                        }, completion: { (Bool) in
                            self.follow_button.setTitle("SIGUIENDO", forState: UIControlState.Normal)
                            
                    })

                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    print(error)
                })
        })

    }
    
    func setFollow() {
        if (parent_view.following != nil && parent_view.following == true) { setFollowingButton() }
    }
    
    func setView(viewController: BranchProfileStickyController) {
        self.parent_view = viewController
        self.branch_name.text = self.parent_view.coupon.name
        downloadImage(parent_view.coupon)
    }
    
    func setFollowingButton() {
        UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.follow_button.setImage(nil, forState: UIControlState.Normal)
            
            self.follow_button.backgroundColor = Utilities.dopColor
            self.follow_button_width.constant = CGFloat(100)
            self.layoutIfNeeded()
            }, completion: { (Bool) in
                self.follow_button.setTitle("SIGUIENDO", forState: UIControlState.Normal)
                
        })
    }
    
    func downloadImage(model: Coupon) {
        let logo_url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
        Utilities.getDataFromUrl(logo_url!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.branch_logo.image = UIImage(data: data!)
            }
        }
        
        if !model.banner.isEmpty {
            let banner_url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.banner)")
            Utilities.getDataFromUrl(banner_url!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    self.branch_banner.image = UIImage(data: data!)!.applyLightEffect()
                    self.branch_name.textColor = UIColor.whiteColor()
                    self.branch_name.shadowColor = UIColor.darkGrayColor()
                }
            }
        }
    }
    
    
}
