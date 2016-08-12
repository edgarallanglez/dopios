//
//  CouponCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 06/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class CouponCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
//    @IBOutlet var expLbl: UILabel!
//    @IBOutlet var limitLbl: UILabel!
//    @IBOutlet var otro: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var branchImage: UIButton!

    var viewController: UIViewController?
    
    @IBAction func branchProfile(sender: UIButton) {
        self.viewController!.performSegueWithIdentifier("branchProfile", sender: self)
    }
    

    
    var radius: CGFloat = 2

    
    func loadItem(coupon:Coupon, viewController: UIViewController) {
        nameLbl.text = coupon.name
        descriptionLbl.text = coupon.couponDescription
//        branchImage.setBackgroundImage(UIImage(named: coupon.logo), forState: UIControlState.Normal)
        branchImage.layer.masksToBounds = true
        branchImage.layer.cornerRadius = 25
        self.viewController = viewController

    }
    
    override func layoutSubviews() {
        layer.cornerRadius = radius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius)

        layer.masksToBounds = false
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 3);
        layer.shadowOpacity = 0.3
        layer.shadowPath = shadowPath.CGPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
