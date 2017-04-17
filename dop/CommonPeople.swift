//
//  CommonPeople.swift
//  dop
//
//  Created by Edgar Allan Glez on 4/4/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import UIKit

class CommonPeople: UIView {

    @IBOutlet weak var user_image_view: UIView!
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var user_name: UILabel!
    
    func loadItem() {
        let container_layer: CALayer = CALayer()
        container_layer.shadowColor = UIColor.black.cgColor
        container_layer.shadowRadius = 4.5
        container_layer.shadowOffset = CGSize(width: 0, height: 2.2)
        container_layer.shadowOpacity = 0.38
        container_layer.contentsScale = 2.0
        container_layer.addSublayer(self.user_image.layer)
        
        self.user_image_view.layer.addSublayer(container_layer)
        self.user_image_view.layer.contentsScale = 2.0
        self.user_image_view.layer.rasterizationScale = 12.0
        self.user_image_view.layer.shouldRasterize = true
        
    }
}
