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
    
    var branch_id: Int!
    var parent_view: BranchProfileStickyController!

    @IBAction func followBranch(sender: AnyObject) {
        
        let params:[String: AnyObject] = [
            "branch_id" : String(stringInterpolationSegment: branch_id),
            "date" : "2015-01-01"]
        
        print(params)
        BranchProfileController.followBranchWithSuccess(params,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: couponsData)
                    print(json)
                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    print(error)
                })
        })

    }
    
    func setView(viewController: BranchProfileStickyController) {
        self.parent_view = viewController
        self.branch_name.text = self.parent_view.coupon.name
        downloadImage(parent_view.coupon)
    }
    
    func downloadImage(model: Coupon) {
        let logo_url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
        Utilities.getDataFromUrl(logo_url!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.branch_logo.image = UIImage(data: data!)
            }
        }
        
        if model.banner.isEmpty || model.banner == "" {
            self.branch_name.textColor = UIColor.darkGrayColor()
            self.branch_name.shadowColor = UIColor.clearColor()
        } else {
            let banner_url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.banner)")
            Utilities.getDataFromUrl(banner_url!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    self.branch_banner.image = UIImage(data: data!)!.applyLightEffect()
//                    self.branch_banner.image self.branch_banner.image?.applyLightEffect()
                }
            }
        }
    }
    
    
}
