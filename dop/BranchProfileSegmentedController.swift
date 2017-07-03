//
//  BranchProfileSegmentedController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class BranchProfileSegmentedController: UIView {
    
    @IBOutlet weak var company_logo: UIImageView!
    @IBOutlet weak var company_name: UILabel!
    @IBOutlet weak var company_category: UIImageView!
    @IBOutlet weak var category_ring_view: UIView!

    var parent_view: BranchProfileStickyController!
    var branch: Branch! {
        didSet {
            downloadImage(model: branch)
            getCategoryView(subcategory_id: branch.subcategory_id!)
            self.company_name.text = branch.name
        }
    }
    
    func downloadImage(model: Branch) {
        let imageUrl = URL(string: "\(Utilities.dopImagesURL)\(model.company_id!)/\(model.logo!)")
        if self.company_logo.image == nil {
            Alamofire.request(imageUrl!).responseImage { response in
                if let image = response.result.value {
                    self.company_logo.image = image
                    self.company_logo.layer.masksToBounds = true
                    self.company_logo.layer.cornerRadius = self.company_logo.frame.width / 2
                    Utilities.fadeInFromBottomAnimation(self.company_logo, delay: 0, duration: 1, yPosition: 1)
                } else {
                    self.company_logo.alpha = 0.3
                    self.company_logo.image = UIImage(named: "dop-logo-transparent")
                    self.company_logo.backgroundColor = Utilities.lightGrayColor
                }
            }
        }
    }
    
    func getCategoryView(subcategory_id: Int) {
        let categories = Constanst.Categories
        
        let icon = UIImage(named: categories["\(subcategory_id)"].string!)
        self.company_category.image = icon
        let ring_size = self.category_ring_view.frame.size.width
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.category_ring_view.frame.size)
        gradient.colors = [Utilities.hexStringToUIColor(hex: "FE51AB").cgColor,
                            Utilities.hexStringToUIColor(hex: "FC2873").cgColor]
        
        self.category_ring_view.layer.cornerRadius = self.category_ring_view.frame.width / 2
        self.category_ring_view.layer.masksToBounds = true
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(arcCenter: CGPoint(x: ring_size / 2, y: ring_size / 2), radius: CGFloat(ring_size / 2), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        self.category_ring_view.layer.addSublayer(gradient)
        
    }
}

