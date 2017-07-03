//
//  BranchProfileStickySectionHeader.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit


class BranchProfileStickySectionHeader: UICollectionReusableView {
    
    var segmented_controller: BranchProfileSegmentedController = BranchProfileSegmentedController()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        segmented_controller = (Bundle.main.loadNibNamed("BranchProfileSegmentedController", owner: self, options: nil)?.first as? BranchProfileSegmentedController)!
        
        //self.addSubview(segmented_controller)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.segmented_controller.frame = self.bounds
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    func commonInit() {
        self.addSubview(segmented_controller)
        segmented_controller.frame = self.bounds
    }
    
    func setBranch(model: Branch) {
        segmented_controller.branch = model
    }
    
}
