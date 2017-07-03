//
//  PageThreeViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/10/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PageThreeViewController: UIViewController {
    
    @IBOutlet weak var tutorial_description: UILabel!
    @IBOutlet weak var tutorial_title: UILabel!
    @IBOutlet weak var top_logo: UIImageView!
    
    @IBOutlet weak var exp_progress: KAProgressLabel!
    @IBOutlet weak var follow_button: UIButton!
    var spinner: MMMaterialDesignSpinner = MMMaterialDesignSpinner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.setMaterialDesignButton(self.follow_button, button_size: 50)
        
        // Do any additional setup after loading the view.
        follow_button.alpha = 0
        
        top_logo.alpha = 0
        tutorial_title.alpha = 0
        tutorial_description.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setProgressBar()
    }
    
    @IBAction func setFollow(_ sender: UIButton) {
        self.follow_button.setImage(nil, for: UIControlState())
        Utilities.setButtonSpinner(self.follow_button, spinner: self.spinner, spinner_size: 18, spinner_width: 1.5, spinner_color: UIColor.white )
        Utilities.fadeInViewAnimation(self.spinner, delay: 0, duration: 0.3)
        
        UIButton.animate(withDuration: 0.7, delay: 1.1, options: UIViewAnimationOptions(), animations: {
            
            Utilities.fadeOutViewAnimation(self.spinner, delay: 1.1, duration: 0.3)
            
            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
            self.follow_button.backgroundColor = Utilities.dopColor
            self.follow_button.imageView?.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            UIButton.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.follow_button.setImage(UIImage(named: "following-icon"), for: UIControlState())
                self.follow_button.imageView?.alpha = 1
            })
            
        })
    }
    
    func setProgressBar() {
        exp_progress.alpha = 1
        exp_progress.startDegree = 0
        exp_progress.progressColor = UIColor(red: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        exp_progress.trackColor = Utilities.lightGrayColor
        exp_progress.trackWidth = 3
        exp_progress.progressWidth = 3
        
        exp_progress.setEndDegree(270.0, timing: TPPropertyAnimationTimingEaseInEaseOut, duration: 1.5, delay: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Utilities.fadeInFromBottomAnimation(top_logo, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(tutorial_title, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(tutorial_description, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(follow_button, delay: 0.8, duration: 1, yPosition: 20)
    }
    override func viewDidDisappear(_ animated: Bool) {
        top_logo.alpha = 0
        tutorial_title.alpha = 0
        tutorial_description.alpha = 0
        follow_button.alpha = 0
    }
    
}
