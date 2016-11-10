//
//  PeopleCell.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/21/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PeopleCell: UITableViewCell {
    
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var ranking_position: KAProgressLabel!

    
    var viewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadItem(_ person: PeopleModel, viewController: UIViewController) {
        user_name.text = "\(person.names) \(person.surnames)"
//        user_image.image = person.main_image
        self.viewController = viewController
        self.layoutIfNeeded()
    }
    
    func setRankingPosition(_ index: Int) {
        ranking_position.trackWidth = 0
        ranking_position.alpha = 1
        ranking_position.startDegree = 0
        
        switch index {
            case 0: ranking_position.progressColor = Utilities.dop_gold_color
            case 1: ranking_position.progressColor = UIColor.gray
            case 2: ranking_position.progressColor = Utilities.dop_bronze_color
        default: ranking_position.progressColor = UIColor.white
        
        }
        
        ranking_position.progressWidth = 2
        ranking_position.setEndDegree(CGFloat(360), timing: TPPropertyAnimationTimingEaseInEaseOut, duration: 1.5, delay: 0)
    }
    
}
