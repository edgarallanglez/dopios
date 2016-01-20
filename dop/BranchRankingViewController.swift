//
//  BranchRankingViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol RankingPageDelegate {
    optional func resizeRankingView(dynamic_height: CGFloat)
}

class BranchRankingViewController: UITableViewController {
    var delegate: RankingPageDelegate?
    
    var parent_view: BranchProfileStickyController!
    
    func reloadWithOffset(parent_scroll: UICollectionView) {
    }
}

