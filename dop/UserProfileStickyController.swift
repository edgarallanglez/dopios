//
//  UserProfileStickyController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class UserProfileStickyController: UICollectionViewController {
    
    var new_height: CGFloat!
    var frame_width: CGFloat!
    
    /// User data
    var user_id: Int = 0
    var user_name: String!
    var user_image: UIImageView!
    var user_image_path: String = ""
    var person: PeopleModel!
    
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
        self.layout!.estimatedItemSize = CGSize(width: self.frame_width, height: CGFloat(estimationHeight))

        // Setup Header
        self.collectionView?.registerClass(UserProfileHeader.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "userHeader")
        self.layout?.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 300)
        
        // Setup Section Header
        self.collectionView?.registerClass(UserProfileSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader")
        self.layout?.headerReferenceSize = CGSizeMake(320, 40)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resizeCell:", name: "ResizeCell", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "invalidateLayout", name: "InvalidateLayout", object: nil)
        
        setupProfileDetail()
    }
    
    // Cells
    
    func resizeCell(notification: NSNotification) {
        let page_height = notification.object as! CGFloat
        var size_changed = false
        if page_height != self.new_height && page_height != 0 { size_changed = true }
        if page_height > 200 { self.new_height = page_height } else { self.new_height = 250 }
        if size_changed { invalidateLayout() }
    }
    
    func invalidateLayout(){
        self.layout?.invalidateLayout()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("page_identifier", forIndexPath: indexPath) as! UserPaginationViewController
        cell.setPaginator(self)
        self.layout!.itemSize = CGSizeMake(self.frame_width, cell.dynamic_height)
        self.new_height = cell.dynamic_height
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        var height: CGFloat!
        if self.new_height != nil { height = self.new_height } else { height = 450 }
        
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
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "userHeader", forIndexPath: indexPath) as! UserProfileHeader
            
            NSNotificationCenter.defaultCenter().postNotificationName("SetParentView", object: self)
            
            return view
        } else if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "sectionHeader", forIndexPath: indexPath)
        
            return view
        }
        
        return UICollectionReusableView()
        
    }
    
    func setupProfileDetail() {
        if self.user_id == User.user_id {
            user_name = "\(User.userName) \(User.userSurnames)"
            if self.user_image == nil {
                self.downloadImage(NSURL(string: User.userImageUrl)!)
            }
        } else if person.privacy_status == 0 {
            user_name = "\(person.names) \(person.surnames)"
            //            userProfileSegmentedController.items.removeLast()
        } else if person.privacy_status == 1 {
            user_name = "\(person.names) \(person.surnames)"
//            private_view.hidden = false
            
        }
    
    }
    
    func downloadImage(url: NSURL) {
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.user_image?.image = UIImage(data: data!)
            }
        }
    }
}

