//
//  BranchProfileStickyController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/18/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc protocol SetSegmentedBranchPageDelegate {
    @objc optional func setPage(_ index: Int)
    @objc optional func launchInfiniteScroll(_ parent_scroll: UICollectionView)
}

protocol SetFollowFromController {
    func setFollowButton(_ branch: Branch)
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
    
    fileprivate var layout : CSStickyHeaderFlowLayout? {
        return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.alwaysBounceVertical = true
        self.view.backgroundColor = UIColor.white
        self.frame_width = self.collectionView!.frame.width
        //
        // Setup Cell
        let estimationHeight = true ? 20 : 21
        self.layout?.estimatedItemSize = CGSize(width: self.frame_width, height: CGFloat(estimationHeight))
        
        // Setup Header
        self.collectionView?.register(BranchProfileStickyHeader.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "branchHeader")
        self.layout?.parallaxHeaderReferenceSize = CGSize(width: self.view.frame.size.width, height: 250)
        
        // Setup Section Header
        self.collectionView?.register(BranchProfileStickySectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader")
        self.layout?.headerReferenceSize = CGSize(width: 320, height: 40)
        
        self.collectionView?.delegate = self
        
        drawBar();
        
    }
    override func viewWillAppear(_ animated: Bool) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(BranchProfileStickyController.setBadge), name: NSNotification.Name(rawValue: "newNotification"), object: nil)
        
        notificationButton = UIBarButtonItem(image: UIImage(named: "notification"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BranchProfileStickyController.notification))
        
        self.navigationItem.rightBarButtonItem = notificationButton
        
        vc  = self.storyboard!.instantiateViewController(withIdentifier: "SearchView") as! SearchViewController
        
        vcNot = self.storyboard!.instantiateViewController(withIdentifier: "Notifications") as! NotificationViewController
        
        
        searchBar.delegate = self
        
        
        
        searchBar.tintColor = UIColor.white
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchBar.placeholder = "Buscar"
        
        
        
        for subView in self.searchBar.subviews{
            for subsubView in subView.subviews{
                if let textField = subsubView as? UITextField{
                    textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Buscar", comment: ""), attributes: [NSForegroundColorAttributeName: Utilities.extraLightGrayColor])
                    textField.textColor = UIColor.white
                    
                }
            }
        }
        
        
        
        searchView = UIView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width,height: self.view.frame.height))
        
        //Add blur view to search view
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.extraLight))
        blurView.frame = searchView.bounds
        
        vc.view.addSubview(blurView)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BranchProfileStickyController.cancelSearch))
        blurView.addGestureRecognizer(gestureRecognizer)
        
        //vc.searchScrollView.hidden = true
        vc.searchScrollView.isHidden = true
        
        
        cancelSearchButton = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(BranchProfileStickyController.cancelSearch))
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(BranchProfileStickyController.presentView(_:)),
            name: NSNotification.Name(rawValue: "performSegue"),
            object: nil)
        
    }
    
    // Cells
    func resizeView(_ new_height: CGFloat) {
        var size_changed = false
        if new_height != self.new_height && new_height != 0 { size_changed = true }
        self.new_height = new_height
        if size_changed { invalidateLayout() }
    }
    
    func invalidateLayout() {
        self.layout?.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let custom_cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page_identifier", for: indexPath) as! BranchProfilePageController
        
        custom_cell.delegate = self
        custom_cell.setPaginator(self)
        self.new_height = custom_cell.dynamic_height
        
        return custom_cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        var height: CGFloat!
        if self.new_height != nil && self.new_height > 300 { height = self.new_height } else { height = 300 }
        
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 60.0, height: 50.0)
    }
    
    
    // Parallax Header
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == CSStickyHeaderParallaxHeader {
            self.top_view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "branchHeader", for: indexPath) as! BranchProfileStickyHeader
            self.top_view.setBranchProfile(self)
            
            
            return self.top_view
        } else if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as! BranchProfileStickySectionHeader
            
            view.delegate = self
            self.segmented_controller = view.segmented_controller
            return view
        }
        
        return UICollectionReusableView()
        
    }
    
    func setupIndex(_ index: Int) {
        delegate?.setPage!(index)
        self.collectionView?.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func infiniteScroll() {
        delegate?.launchInfiniteScroll!(self.collectionView!)
    }
    
    func setSegmentedIndex(_ index: Int) {
        self.segmented_controller!.selectedIndex = index
        self.collectionView?.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func setFollowButton(_ branch: Branch) {
        self.branch = branch
        self.following = branch.following
        self.top_view.setBranchFollow(self.branch)
    }
    
    func presentView(_ notification:Foundation.Notification){
        if(searchViewIsOpen){
            searchViewIsSegue = true
            
            let params = notification.object as! NSDictionary
            let object_id = params["id"] as! Int
            
            if vc.searchSegmentedController.selectedIndex == 0 {
                let viewControllerToPresent = self.storyboard!.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
                viewControllerToPresent.branch_id = object_id
                self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
                
            }
            if vc.searchSegmentedController.selectedIndex == 1 {
                let viewControllerToPresent = self.storyboard!.instantiateViewController(withIdentifier: "UserProfileStickyController") as! UserProfileStickyController
                viewControllerToPresent.user_id = object_id
                viewControllerToPresent.is_friend = params["is_friend"] as! Bool
                viewControllerToPresent.operation_id = params["operation_id"] as! Int
                self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
                
            }
            
            searchBar.resignFirstResponder()
            
        }
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
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
            vc.searchScrollView.isHidden = true
            vc.peopleFiltered.removeAll()
            vc.peopleTableView.reloadData()
            vc.filtered.removeAll()
            vc.tableView.reloadData()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchViewIsOpen == true && vc.searchScrollView.isHidden == true){
            vc.searchScrollView.isHidden = false
            Utilities.slideFromBottomAnimation(vc.searchScrollView, delay: 0, duration: 0.5, yPosition: 600)
        }
        
        if(searchText.characters.count == 0){
            vc.searchScrollView.isHidden = true
        }else{
            vc.searchText = searchText as NSString!
            vc.searchTimer()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        vc.searchActive = false;
        vc.timer?.invalidate()
        
        if(vc.searchText != ""){
            vc.search()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        vc.searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        vc.searchActive = false;
    }
    func setBadge(){
        self.notificationButton.image = UIImage(named: "notification-badge")
    }
    func notification() {
        let vcNot = self.storyboard!.instantiateViewController(withIdentifier: "Notifications") as! NotificationViewController
        
        self.navigationController?.pushViewController(vcNot, animated: true)
        self.notificationButton.image = UIImage(named: "notification")
        
        /*vcNot.navigationController?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vcNot, animated: true)*/
        
    }
}

