//
//  LoyaltyCollectionCell.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/20/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import UIKit

class LoyaltyCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var loyalty_logo: UIImageView!
    @IBOutlet weak var loyalty_progress: KAProgressLabel!
    @IBOutlet weak var branch_logo: UIImageView!
    @IBOutlet weak var loyalty_count: UILabel!
    
    var parent_view: UIViewController!
    var loyalty: Loyalty!
    var percent: Double!
    var progress: Double!
    
    func setItem(model: Loyalty, view_controller: UIViewController) {
        self.parent_view = view_controller
        self.loyalty = model
        
        loyalty_count.text =  "\(Int(loyalty.visit!))/\(Int(loyalty.goal!))"
        setProgress()
    }
    
    func setProgress() {
        loyalty_progress.alpha = 1
        loyalty_progress.startDegree = 0
        loyalty_progress.progressColor = UIColor(red: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        loyalty_progress.trackColor = Utilities.lightGrayColor
        loyalty_progress.trackWidth = 3
        loyalty_progress.progressWidth = 3
        percent = loyalty.visit / loyalty.goal
        progress = 360 * percent
        loyalty_progress.setEndDegree(CGFloat(progress), timing: TPPropertyAnimationTimingEaseInEaseOut, duration: 1.5, delay: 0)
    }
}
