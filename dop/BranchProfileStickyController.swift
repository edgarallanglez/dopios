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

class BranchProfileStickyController: UICollectionViewController, BranchPaginationDelegate, BranchSegmentedControlDelegate, UISearchBarDelegate {
    
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
    
    var notificationButton: UIBarButtonItem!
    var vc: SearchViewController!
    var vcNot: NotificationViewController!
    var searchBar: UISearchBar = UISearchBar()
    var searchView: UIView!
    var searchViewIsOpen: Bool = false
    var searchViewIsSegue: Bool = false
    
    var cancelSearchButton:UIBarButtonItem!
    
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
        
        drawBar();
        
    }
    override func viewWillAppear(animated: Bool) {
        if User.newNotification {
            self.notificationButton.image = UIImage(named: "notification-badge")
        }else{
            self.notificationButton.image = UIImage(named: "notification")
        }
        
        searchBar.alpha = 0
        Utilities.fadeInViewAnimation(searchBar, delay: 0, duration: 0.5)
        self.navigationItem.titleView = searchBar
    }
    func drawBar(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setBadge", name: "newNotification", object: nil)
        
        notificationButton = UIBarButtonItem(image: UIImage(named: "notification"), style: UIBarButtonItemStyle.Plain, target: self, action: "notification")
        
        self.navigationItem.rightBarButtonItem = notificationButton
        
        vc  = self.storyboard!.instantiateViewControllerWithIdentifier("SearchView") as! SearchViewController
        
        vcNot = self.storyboard!.instantiateViewControllerWithIdentifier("Notifications") as! NotificationViewController
        
        
        searchBar.delegate = self
        
        
        
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.placeholder = "Buscar"
        
        
        
        for subView in self.searchBar.subviews{
            for subsubView in subView.subviews{
                if let textField = subsubView as? UITextField{
                    textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Buscar", comment: ""), attributes: [NSForegroundColorAttributeName: Utilities.extraLightGrayColor])
                    textField.textColor = UIColor.whiteColor()
                    
                }
            }
        }
        
        
        
        searchView = UIView(frame: CGRectMake(0,0,self.view.frame.width,self.view.frame.height))
        
        //Add blur view to search view
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
        blurView.frame = searchView.bounds
        
        vc.view.addSubview(blurView)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "cancelSearch")
        blurView.addGestureRecognizer(gestureRecognizer)
        
        //vc.searchScrollView.hidden = true
        vc.searchScrollView.hidden = true
        
        
        cancelSearchButton = UIBarButtonItem(title: "Cancelar", style: .Plain, target: self, action: "cancelSearch")
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "presentView:",
            name: "performSegue",
            object: nil)
        
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
    
    func presentView(notification:NSNotification){
        if(searchViewIsOpen){
            searchViewIsSegue = true
            
            let params = notification.object as! NSDictionary
            let object_id = params["id"] as! Int
            
            if vc.searchSegmentedController.selectedIndex == 0 {
                let viewControllerToPresent = self.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
                viewControllerToPresent.branch_id = object_id
                self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
                
            }
            if vc.searchSegmentedController.selectedIndex == 1 {
                let viewControllerToPresent = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileStickyController") as! UserProfileStickyController
                viewControllerToPresent.user_id = object_id
                viewControllerToPresent.is_friend = params["is_friend"] as! Bool
                viewControllerToPresent.operation_id = params["operation_id"] as! Int
                self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
                
            }
            
            searchBar.resignFirstResponder()
            
        }
        
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if(searchViewIsOpen == false){
            self.navigationItem.rightBarButtonItem = cancelSearchButton
            
            searchView.layer.masksToBounds = true
            self.view.addSubview(searchView)
            Utilities.fadeInFromBottomAnimation(searchView, delay: 0, duration: 0.7, yPosition: 20)
            
            searchView.addSubview(vc.view)
            vc.searchBar = self.searchBar
            
            searchViewIsOpen = true
        }
        return true
    }
    func cancelSearch(){
        if(searchViewIsOpen == true){
            searchView.removeFromSuperview()
            searchBar.resignFirstResponder()
            searchViewIsOpen = false
            self.navigationItem.rightBarButtonItem = notificationButton
            searchBar.text = ""
            vc.searchScrollView.hidden = true
            vc.peopleFiltered.removeAll()
            vc.peopleTableView.reloadData()
            vc.filtered.removeAll()
            vc.tableView.reloadData()
        }
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchViewIsOpen == true && vc.searchScrollView.hidden == true){
            vc.searchScrollView.hidden = false
            Utilities.slideFromBottomAnimation(vc.searchScrollView, delay: 0, duration: 0.5, yPosition: 600)
        }
        
        if(searchText.characters.count == 0){
            vc.searchScrollView.hidden = true
        }else{
            vc.searchText = searchText
            vc.searchTimer()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        vc.searchActive = false;
        vc.timer?.invalidate()
        
        if(vc.searchText != ""){
            vc.search()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        vc.searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        vc.searchActive = false;
    }
    func setBadge(){
        self.notificationButton.image = UIImage(named: "notification-badge")
    }
    func notification() {
        let tabbar = self.tabBarController as! TabbarController!
        self.navigationController?.pushViewController(tabbar.vcNot, animated: true)
        self.notificationButton.image = UIImage(named: "notification")
        
        /*vcNot.navigationController?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vcNot, animated: true)*/
        
    }
}

