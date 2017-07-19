//
//  PageZeroViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/9/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PageZeroViewController: UIViewController {
    @IBOutlet var tutorial_title: UILabel!
    @IBOutlet var tutorial_description: UILabel!
    
    @IBOutlet var top_logo: UIImageView!
    @IBOutlet weak var trending_image_view: UIImageView!
    @IBOutlet weak var exp_near_image_view: UIImageView!
    @IBOutlet weak var promo_container: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyPlainShadow(trending_image_view)
        Utilities.applyPlainShadow(exp_near_image_view)
        
        // Do any additional setup after loading the view.
        promo_container.alpha = 0
        top_logo.alpha = 0
        tutorial_title.alpha = 0
        tutorial_description.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Utilities.fadeInFromBottomAnimation(promo_container, delay: 0, duration: 1, yPosition: 20)
    }
    
    func startFadeIn() {
        Utilities.fadeInFromBottomAnimation(top_logo, delay: 0, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(tutorial_title, delay: 0, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(tutorial_description, delay: 0, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(promo_container, delay: 0.5, duration: 1, yPosition: 20)
    }
    
}
