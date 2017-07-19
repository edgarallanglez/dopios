//
//  BranchProfileStickyController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/18/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BranchProfileStickyController: UICollectionViewController, UISearchBarDelegate {
    
    var frame_width: CGFloat!
    var coupon: Coupon!
    var branch: Branch!
    /// User data
    var branch_id: Int = 0
    var branch_name: String!
    var logo: UIImage!
    var user_image_path: String = ""
    var top_view: BranchProfileStickyHeader!
    var segmented_view: BranchProfileStickySectionHeader!
    var content_cell: BranchProfileContentController!
    var following: Bool!
    var loaded: Int = 0
    var height: CGFloat = 760
    
    var notificationButton: UIBarButtonItem!
    var vc: SearchViewController!
    var vcNot: NotificationViewController!
    var searchBar: UISearchBar = UISearchBar()
    var searchView: UIView!
    var searchViewIsOpen: Bool = false
    var searchViewIsSegue: Bool = false
    
    var cancelSearchButton: UIBarButtonItem!
    var storyboard_flow: UIStoryboard?
    
    fileprivate var layout : CSStickyHeaderFlowLayout? {
        return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyboard_flow = UIStoryboard(name: "Main", bundle: nil)
        self.collectionView?.alwaysBounceVertical = true
        self.view.backgroundColor = UIColor.white
        self.frame_width = UIScreen.main.bounds.width
        
//        // Setup Cell
//        let estimationHeight = true ? 20 : 21
//        self.layout!.estimatedItemSize = CGSize(width: self.frame_width, height: CGFloat(estimationHeight))
        
//        self.layout?.itemSize = CGSize(width: self.frame_width, height: 520)
        // Setup Header
        self.collectionView?.register(BranchProfileStickyHeader.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "branchHeader")
        self.layout?.parallaxHeaderReferenceSize = CGSize(width: self.frame_width, height: 180)
        
        // Setup Section Header
        self.collectionView?.register(BranchProfileStickySectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader")
        self.layout?.headerReferenceSize = CGSize(width: 320, height: 60)
        getBranchProfile()
        drawBar()
        
        if !self.isMovingToParentViewController { setSearchObserver() }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if User.newNotification { self.notificationButton.image = UIImage(named: "notification-badge") }
        else { self.notificationButton.image = UIImage(named: "notification") }
        if self.isMovingToParentViewController {
            searchBar.alpha = 0
            Utilities.fadeInViewAnimation(searchBar, delay: 0, duration: 0.5)
            self.navigationItem.titleView = searchBar
        }
        if searchViewIsOpen && loaded < 1 { setSearchObserver() }
        loaded += 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        loaded = 0
    }
    
    func invalidateLayout(){
        self.layout?.invalidateLayout()
    }
    
    func drawBar() {
        NotificationCenter.default.addObserver(self, selector: #selector(UserProfileStickyController.setBadge), name: NSNotification.Name(rawValue: "newNotification"), object: nil)
        
        notificationButton = UIBarButtonItem(image: UIImage(named: "notification"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserProfileStickyController.notification))
        
        self.navigationItem.rightBarButtonItem = notificationButton
        vc  = self.storyboard_flow?.instantiateViewController(withIdentifier: "SearchView") as! SearchViewController
        vcNot = self.storyboard_flow?.instantiateViewController(withIdentifier: "Notifications") as! NotificationViewController
        
        searchBar.delegate = self
        searchBar.tintColor = UIColor.white
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchBar.placeholder = "Buscar"
        
        for subView in self.searchBar.subviews {
            for subsubView in subView.subviews {
                if let textField = subsubView as? UITextField {
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
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfileStickyController.cancelSearch))
        blurView.addGestureRecognizer(gestureRecognizer)
        
        //vc.searchScrollView.hidden = true
        vc.searchScrollView.isHidden = true
        cancelSearchButton = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(UserProfileStickyController.cancelSearch))
        //setSearchObserver()
        
    }
    
    func setSearchObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UserProfileStickyController.presentView(_:)),
            name: NSNotification.Name(rawValue: "performSegue"),
            object: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        content_cell = collectionView.dequeueReusableCell(withReuseIdentifier: "branch_content_identifier", for: indexPath) as! BranchProfileContentController
        
        content_cell.parent_view = self
    
        return content_cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: self.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 60.0, height: 66.0)
    }
    
    
    // Parallax Header
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == CSStickyHeaderParallaxHeader {
            self.top_view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "branchHeader", for: indexPath) as! BranchProfileStickyHeader
            self.top_view.setBranchProfile(self)
            
            return self.top_view
            
        } else if kind == UICollectionElementKindSectionHeader {
            self.segmented_view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as! BranchProfileStickySectionHeader
            
            view.layoutSubviews()
            return segmented_view
        }
        
        return UICollectionReusableView()
    }
    
    func getBranchProfile() {
        BranchProfileController.getBranchProfileWithSuccess(branch_id, success: { (data) -> Void in
            let json = data?["data"][0]
            let model = Branch(model: json!)
            self.branch = model
            
            DispatchQueue.main.async(execute: {
                self.segmented_view.setBranch(model: self.branch)
                self.top_view.setBranch(model: self.branch)
                self.content_cell.branch = self.branch
                
                if self.branch.facebook_url == "" && self.branch.instagram_url == "" {
                    self.height = 640
                    self.invalidateLayout()
                }
            })
            
        },
                                                            failure: { (error) -> Void in
                                                                DispatchQueue.main.async(execute: {
                                                                    
                                                                    //                Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                                                                })
        })
    }
    
    func presentView(_ notification: Foundation.Notification) {
        if searchViewIsOpen {
            searchViewIsSegue = true
            
            let params = notification.object as! NSDictionary
            let object_id = params["id"] as! Int
            
            if vc.searchSegmentedController.selectedIndex == 0 {
                let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
                let view_controller = storyboard.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
                view_controller.branch_id = object_id
                self.navigationController?.pushViewController(view_controller, animated: true)
            }
            
            if vc.searchSegmentedController.selectedIndex == 1 {
                let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
                let view_controller = storyboard.instantiateViewController(withIdentifier: "UserProfileStickyController") as! UserProfileStickyController
                view_controller.user_id = object_id
                view_controller.is_friend = params["is_friend"] as! Bool
                view_controller.operation_id = params["operation_id"] as! Int
                self.navigationController?.pushViewController(view_controller, animated: true)
                
            }
            
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if !searchViewIsOpen {
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
    
    func cancelSearch() {
        if searchViewIsOpen {
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
        if (searchViewIsOpen == true && vc.searchScrollView.isHidden == true) {
            //vc.searchScrollView.isHidden = false
            //Utilities.slideFromBottomAnimation(vc.searchScrollView, delay: 0, duration: 0.5, yPosition: 600)
        }
        
        if searchText.characters.count == 0 { vc.searchScrollView.isHidden = true }
        else {
            vc.searchText = searchText as NSString!
            //vc.searchTimer()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        vc.searchActive = false;
        vc.timer?.invalidate()
        
        if vc.searchText != "" {
            vc.search()
            vc.searchScrollView.isHidden = false
            Utilities.slideFromBottomAnimation(vc.searchScrollView, delay: 0, duration: 0.5, yPosition: 600)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        vc.searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        vc.searchActive = false;
    }
    
    func setBadge() {
        self.notificationButton.image = UIImage(named: "notification-badge")
    }
    
    func notification() {
        //let tabbar = self.tabBarController as! TabbarController!
        let notifications_view_controller = self.storyboard_flow!.instantiateViewController(withIdentifier: "Notifications") as! NotificationViewController
        
        self.navigationController?.pushViewController(notifications_view_controller, animated: true)
        self.notificationButton.image = UIImage(named: "notification")
        
        
    }
    
//    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool,
//                          completion: (() -> Void)? = nil) {
//        
//    }

}

