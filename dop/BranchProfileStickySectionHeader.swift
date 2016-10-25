//
//  BranchProfileStickySectionHeader.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol BranchSegmentedControlDelegate {
    @objc optional func setupIndex(_ index: Int)
}

class BranchProfileStickySectionHeader: UICollectionReusableView {
    var delegate: BranchSegmentedControlDelegate?
    
    let segmented_controller: BranchProfileSegmentedController = BranchProfileSegmentedController()
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    func commonInit() {
        self.addSubview(segmented_controller)
        segmented_controller.frame = self.bounds
        segmented_controller.sendActions(for: UIControlEvents.touchUpInside)
        segmented_controller.addTarget(self, action: #selector(BranchProfileStickySectionHeader.setSegmentedController), for: UIControlEvents.valueChanged)
        
    }
    
    func setSegmentedController() {
        delegate?.setupIndex!(segmented_controller.selectedIndex)
    }
}
