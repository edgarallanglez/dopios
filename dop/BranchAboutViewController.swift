//
//  BranchAboutViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol AboutPageDelegate {
    optional func resizeAboutView(dynamic_height: CGFloat)
}

class BranchAboutViewController: UIViewController {
    var delegate: AboutPageDelegate?
    var branch_about: BranchProfileAboutView!
    var parent_view: BranchProfileStickyController!
    
    override func viewDidLoad() {
        self.view.clipsToBounds = true
//        
//        
//        self.branch_about = (NSBundle.mainBundle().loadNibNamed("BranchProfileAboutView", owner: self, options: nil)[0] as? BranchProfileAboutView)!
//        self.branch_about.frame.size.width = self.view.frame.size.width
//        self.view.addSubview(branch_about)
    }
    
    override func viewDidAppear(animated: Bool) {
        setFrame()
    }
    
    func setFrame() {
        var dynamic_height: CGFloat = 250
//        self.view.frame.size.height = self.branch_about.frame.height
//        self.branch_about.frame.size.height = CGFloat(280)
        //if self.branch_about.frame.height > dynamic_height { dynamic_height = self.branch_about.frame.height }
        delegate?.resizeAboutView!(dynamic_height)

    }
    
    func reloadWithOffset(parent_scroll: UICollectionView) {
    }
    
    
}
