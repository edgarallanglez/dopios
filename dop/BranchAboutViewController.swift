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
    
    var parent_view: BranchProfileStickyController!
    
    
    
    func reloadWithOffset(parent_scroll: UICollectionView) {
    }
    
    
}
