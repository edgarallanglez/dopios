//
//  UserProfileStickyController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l > r
//  default:
//    return rhs < lhs
//  }
//}

class UserProfileStickyController: UICollectionViewController, UISearchBarDelegate {
    var frame_width: CGFloat!
    
    /// User data
    var user_id: Int = 0
    var user_name: String!
    var user_image: UIImageView!
    var user_image_path: String = ""
    var is_friend: Bool?
    var operation_id: Int = 5
    var person: PeopleModel!
    var page_index: Int!
    var top_view: UserProfileHeader!
    var content_cell: UserProfileContentController!
    
    var notificationButton: UIBarButtonItem!
    var vc: SearchViewController!
    var vcNot: NotificationViewController!
    var searchBar: UISearchBar = UISearchBar()
    var searchView: UIView!
    var searchViewIsOpen: Bool = false
    var searchViewIsSegue: Bool = false
    var cancelSearchButton: UIBarButtonItem!
    var reload: Bool = false
    var loaded: Int = 0
    var storyboard_flow: UIStoryboard?
    
    fileprivate var layout: CSStickyHeaderFlowLayout? {
        return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyboard_flow = UIStoryboard(name: "Main", bundle: nil)
        self.collectionView?.alwaysBounceVertical = true
        self.view.backgroundColor = UIColor.white
        self.frame_width = self.collectionView!.frame.width
        
        // Setup Cell
//        let estimationHeight = true ? 20 : 21
//        self.layout!.estimatedItemSize = CGSize(width: self.frame_width, height: CGFloat(estimationHeight))

        // Setup Header
        self.collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "userHeader")
        self.layout?.parallaxHeaderReferenceSize = CGSize(width: self.view.frame.size.width, height: 130)
        
        // Setup Section Header
        self.collectionView?.register(CollectionViewSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader")
        self.layout?.headerReferenceSize = CGSize(width: 320, height: 0)
        getProfile()
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
        
        content_cell = collectionView.dequeueReusableCell(withReuseIdentifier: "user_content_identifier", for: indexPath) as! UserProfileContentController
        
        content_cell.parent_view = self
        
        return content_cell    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        
        return CGSize(width: width, height: 530)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    // Parallax Header
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == CSStickyHeaderParallaxHeader {
            self.top_view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "userHeader", for: indexPath) as! UserProfileHeader
            self.top_view.setUserProfile(self)
            
            return self.top_view
        } else if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath)

            return view
        }
        
        return UICollectionReusableView()
        
    }
    
    func getProfile() {
        UserProfileController.getUserProfile(user_id, success: { (profileData) -> Void in
            let json = profileData!
            print(json)
            for (_, subJson): (String, JSON) in json["data"] {
                let names = subJson["names"].string!
                let surnames = subJson["surnames"].string!
                let facebook_key = subJson["facebook_key"].string ?? ""
                let user_id = subJson["user_id"].int!
                let birth_date = subJson["birth_date"].string ?? ""
                let privacy_status = subJson["privacy_status"].int ?? 0
                let main_image = subJson["main_image"].string ?? ""
                let level = subJson["level"].int ?? 0
                let exp = subJson["exp"].double ?? 0
                let is_friend = subJson["is_friend"].bool!
                //let total_used = subJson["total_used"].int!
                
                let model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: birth_date, facebook_key: facebook_key, privacy_status: privacy_status, main_image: main_image, level: level, exp: exp)
                
                model.is_friend = is_friend
                self.person = model
                self.top_view.setUser(user: self.person)
            }
            
            DispatchQueue.main.async(execute: {
                self.content_cell.user = self.person
            })
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    print("Error")
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
        let vcNot = self.storyboard!.instantiateViewController(withIdentifier: "Notifications") as! NotificationViewController
        
        self.navigationController?.pushViewController(vcNot, animated: true)
        self.notificationButton.image = UIImage(named: "notification")

        
        
        /*vcNot.navigationController?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vcNot, animated: true)*/
        
    }
}

