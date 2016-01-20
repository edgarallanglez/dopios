//
//  BranchCampaignCollectionViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol CampaignPageDelegate {
    optional func resizeCampaignView(dynamic_height: CGFloat)
}

class BranchCampaignCollectionViewController: UICollectionViewController {
    var delegate: CampaignPageDelegate?
    
    var parent_view: BranchProfileStickyController!
    
    func reloadWithOffset(parent_scroll: UICollectionView) {
    }
}
