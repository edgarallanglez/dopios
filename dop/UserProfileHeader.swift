//
//  UserProfileHeader.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class UserProfileHeader: UICollectionReusableView {
    
    
    fileprivate var imageView : UIImageView?
    fileprivate var user_profile: UserProfileStickyHeader = UserProfileStickyHeader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        user_profile = (Bundle.main.loadNibNamed("UserProfileStickyHeader", owner: self, options: nil)![0] as? UserProfileStickyHeader)!
        
        self.addSubview(user_profile)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.user_profile.frame = self.bounds
    }
    
    func setUserProfile(_ viewController: UserProfileStickyController) {
        user_profile.setView(viewController)
    }
    
    
}
