//
//  UserProfileSectionHeader.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol SegmentedControlDelegate {
    @objc optional func setupIndex(_ index: Int)
}

class UserProfileSectionHeader: UICollectionReusableView {
    var delegate: SegmentedControlDelegate?
    
    let segmented_controller: UserProfileSegmentedController = UserProfileSegmentedController()
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
        segmented_controller.addTarget(self, action: #selector(UserProfileSectionHeader.setSegmentedController), for: UIControlEvents.valueChanged)
        
    }
    
    func setSegmentedController() {
        delegate?.setupIndex!(segmented_controller.selectedIndex)
    }
}
