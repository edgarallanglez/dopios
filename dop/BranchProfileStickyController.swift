//
//  BranchProfileStickyController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/18/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol SetSegmentedBranchPageDelegate {
    optional func setPage(index: Int)
    optional func launchInfiniteScroll(parent_scroll: UICollectionView)
}

protocol SetFollowFromController {
    func setFollowButton(branch: Branch)
}

class BranchProfileStickyController: UICollectionViewController, BranchPaginationDelegate, BranchSegmentedControlDelegate {
    
    var delegate: SetSegmentedBranchPageDelegate?
    var delegateFollow: SetFollowFromController?
    
    var new_height: CGFloat!
    var frame_width: CGFloat!
    
    var coupon: Coupon!
    
    var branch: Branch!
    /// User data
    var branch_id: Int = 0
    var branch_name: String!
    var logo: UIImage!
    var user_image_path: String = ""
    var top_view: BranchProfileStickyHeader!
    var page_index: Int!
    var segmented_controller: BranchProfileSegmentedController?
    var following: Bool!
    
    private var layout : CSStickyHeaderFlowLayout? {
        return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.alwaysBounceVertical = true
        self.view.backgroundColor = UIColor.whiteColor()
        self.frame_width = self.collectionView!.frame.width
        //
        // Setup Cell
        let estimationHeight = true ? 20 : 21
        self.layout?.estimatedItemSize = CGSize(width: self.frame_width, height: CGFloat(estimationHeight))
        
        // Setup Header
        self.collectionView?.registerClass(BranchProfileStickyHeader.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "branchHeader")
        self.layout?.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 250)
        
        // Setup Section Header
        self.collectionView?.registerClass(BranchProfileStickySectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader")
        self.layout?.headerReferenceSize = CGSizeMake(320, 40)
        
        self.collectionView?.delegate = self
        
//        self.collectionView!.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
//        self.collectionView!.infiniteScrollIndicatorMargin = 40
//        
//        self.collectionView!.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
//            if self!.segmented_controller?.selectedIndex != 0 {
//                self?.infiniteScroll()
//            } else { self?.collectionView?.finishInfiniteScroll() }
//        }
    }
    
    // Cells
    func resizeView(new_height: CGFloat) {
        var size_changed = false
        if new_height != self.new_height && new_height != 0 { size_changed = true }
        self.new_height = new_height
        if size_changed { invalidateLayout() }
    }
    
    func invalidateLayout() {
        self.layout?.invalidateLayout()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let custom_cell = collectionView.dequeueReusableCellWithReuseIdentifier("page_identifier", forIndexPath: indexPath) as! BranchProfilePageController
        
        custom_cell.delegate = self
        custom_cell.setPaginator(self)
        self.new_height = custom_cell.dynamic_height
        
        return custom_cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        var height: CGFloat!
        if self.new_height != nil && self.new_height > 300 { height = self.new_height } else { height = 300 }
        
        return CGSizeMake(width, height)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(60.0, 50.0)
    }
    
    
    // Parallax Header
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == CSStickyHeaderParallaxHeader {
            self.top_view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "branchHeader", forIndexPath: indexPath) as! BranchProfileStickyHeader
            self.top_view.setBranchProfile(self)
            
            
            return self.top_view
        } else if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "sectionHeader", forIndexPath: indexPath) as! BranchProfileStickySectionHeader
            
            view.delegate = self
            self.segmented_controller = view.segmented_controller
            return view
        }
        
        return UICollectionReusableView()
        
    }
    
    func setupIndex(index: Int) {
        delegate?.setPage!(index)
        self.collectionView?.setContentOffset(CGPointZero, animated: false)
    }
    
    func infiniteScroll() {
        delegate?.launchInfiniteScroll!(self.collectionView!)
    }
    
    func setSegmentedIndex(index: Int) {
        self.segmented_controller!.selectedIndex = index
        self.collectionView?.setContentOffset(CGPointZero, animated: false)
    }
    
    func setFollowButton(branch: Branch) {
        self.branch = branch
        self.following = branch.following
        self.top_view.setBranchFollow(self.branch)
    }
}

