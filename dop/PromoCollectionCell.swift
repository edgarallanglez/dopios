//
//  PromoCollectionCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PromoCollectionCell: UICollectionViewCell {
    
    @IBOutlet var coupon_description: UILabel!
    @IBOutlet var branch_banner: UIImageView!
    @IBOutlet var heart: UIImageView!
    @IBOutlet var likes: UILabel!
    
    var viewController: UIViewController?
    
    func loadItem(coupon:Coupon, viewController: UIViewController) {
//        nameLbl.text = coupon.name
        coupon_description.text = coupon.couponDescription
        //        branchImage.setBackgroundImage(UIImage(named: coupon.logo), forState: UIControlState.Normal)
        self.viewController = viewController
        
    }
}
