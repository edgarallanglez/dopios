//
//  SearchCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 08/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet var branch_name: UILabel!
    @IBOutlet var distance: UILabel!
    
    var viewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadItem(branch:NearbyBranch, viewController: UIViewController) {
        branch_name.text = branch.name
        distance.text = branch.distance
        //        branchImage.setBackgroundImage(UIImage(named: coupon.logo), forState: UIControlState.Normal)
        self.viewController = viewController
        
    }

}
