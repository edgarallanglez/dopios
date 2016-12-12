//
//  PageZeroViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/9/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PageZeroViewController: UIViewController {
    
    @IBOutlet weak var trending_image_view: UIImageView!
    @IBOutlet weak var exp_near_image_view: UIImageView!
    @IBOutlet weak var promo_container: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyPlainShadow(trending_image_view)
        Utilities.applyPlainShadow(exp_near_image_view)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Utilities.fadeInViewAnimation(promo_container, delay: 0, duration: 1)
    }

}
