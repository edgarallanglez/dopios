//
//  BranchProfileStickyHeader.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BranchProfileStickyHeader: UICollectionReusableView {
    
    fileprivate var imageView : UIImageView?
    fileprivate var branch_profile: BranchProfileTopView = BranchProfileTopView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        branch_profile = (Bundle.main.loadNibNamed("BranchProfileTopView", owner: self, options: nil)?.first as? BranchProfileTopView)!
        
        self.addSubview(branch_profile)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.branch_profile.frame = self.bounds
    }
    
    func setBranchProfile(_ viewController: BranchProfileStickyController) {
        branch_profile.setView(viewController)
    }
    
    func setBranch(model: Branch) {
        branch_profile.branch = model
    }
    

}
