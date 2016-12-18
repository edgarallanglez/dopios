//
//  PageFourViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/10/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PageFourViewController: UIViewController {
    @IBOutlet var tutorial_description: UILabel!
    @IBOutlet var tutorial_title: UILabel!
    @IBOutlet var top_icon: UIImageView!
    
    @IBOutlet weak var activity_view: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyPlainShadow(activity_view)
        // Do any additional setup after loading the view.
                
        top_icon.alpha = 0
        tutorial_title.alpha = 0
        tutorial_description.alpha = 0
        activity_view.alpha = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        Utilities.fadeInFromBottomAnimation(top_icon, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(activity_view, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(tutorial_title, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(tutorial_description, delay: 0.5, duration: 1, yPosition: 20)
    }
    override func viewDidDisappear(_ animated: Bool) {
        top_icon.alpha = 0
        activity_view.alpha = 0
        tutorial_title.alpha = 0
        tutorial_description.alpha = 0
    }

}
