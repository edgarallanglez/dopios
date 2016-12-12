//
//  PageThreeViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/10/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PageThreeViewController: UIViewController {

    @IBOutlet weak var exp_progress: KAProgressLabel!
    @IBOutlet weak var follow_button: UIButton!
    var spinner: MMMaterialDesignSpinner = MMMaterialDesignSpinner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.setMaterialDesignButton(self.follow_button, button_size: 50)

        // Do any additional setup after loading the view.
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
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            self.follow_button.setImage(UIImage(named: "following-icon"), for: UIControlState())
            //
            
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
    
    

}
