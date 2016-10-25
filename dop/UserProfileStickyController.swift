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


@objc protocol SetSegmentedPageDelegate {
    @objc optional func setPage(_ index: Int)
    
    @objc optional func launchInfiniteScroll(_ parent_scroll: UICollectionView)
}

class UserProfileStickyController: UICollectionViewController, UserPaginationDelegate, SegmentedControlDelegate, UISearchBarDelegate {
    var delegate: SetSegmentedPageDelegate?
    var new_height: CGFloat!
    var frame_width: CGFloat!
    
    /// User data
    var user_id: Int = 0
    var user_name: String!
    var user_image: UIImageView!
    var user_image_path: String = ""
    var is_friend: Bool?
    var operation_id: Int = 0
    var person: PeopleModel!
    var page_index: Int!
    var segmented_controller: UserProfileSegmentedController?
    
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
    
    fileprivate var layout: CSStickyHeaderFlowLayout? {
        return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        self.view.backgroundColor = UIColor.white
        self.frame_width = self.collectionView!.frame.width
        
        // Setup Cell
        let estimationHeight = true ? 20 : 21
        self.layout!.estimatedItemSize = CGSize(width: self.frame_width, height: CGFloat(estimationHeight))

        // Setup Header
        self.collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "userHeader")
        self.layout?.parallaxHeaderReferenceSize = CGSize(width: self.view.frame.size.width, height: 250)
        
        // Setup Section Header
        self.collectionView?.register(UserProfileSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader")
        self.layout?.headerReferenceSize = CGSize(width: 320, height: 40)
        
        self.collectionView?.delegate = self
        checkForProfile()
        drawBar()
        
        if !self.isMovingToParentViewController { setSearchObserver() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        loaded = 0
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
    
    func drawBar() {
        NotificationCenter.default.addObserver(self, selector: #selector(UserProfileStickyController.setBadge), name: NSNotification.Name(rawValue: "newNotification"), object: nil)

        notificationButton = UIBarButtonItem(image: UIImage(named: "notification"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserProfileStickyController.notification))
        
        self.navigationItem.rightBarButtonItem = notificationButton
        vc  = self.storyboard!.instantiateViewController(withIdentifier: "SearchView") as! SearchViewController
        vcNot = self.storyboard!.instantiateViewController(withIdentifier: "Notifications") as! NotificationViewController
    
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
    // Cells
    func resizeView(_ new_height: CGFloat) {
        var size_changed = false
        if new_height != self.new_height && new_height != 0 { size_changed = true }
        self.new_height = new_height
        if size_changed { invalidateLayout() }
    }

    func invalidateLayout(){
        self.layout?.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell!
        if self.person != nil {
            self.reload = false
            if self.person?.privacy_status == 0 || User.user_id == self.person.user_id || self.person.is_friend == true {
                let custom_cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page_identifier", for: indexPath) as! UserPaginationViewController
                
                custom_cell.delegate = self
                custom_cell.setPaginator(self)
                self.new_height = custom_cell.dynamic_height
                return custom_cell
            } else { cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locked_identifier", for: indexPath)
                cell.alpha = 1
                cell.isHidden = false
            }
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locked_identifier", for: indexPath)
            self.reload = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        var height: CGFloat!
        if self.new_height != nil || self.new_height > 250 { height = self.new_height } else { height = 250 }
        
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
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "userHeader", for: indexPath) as! UserProfileHeader
            view.setUserProfile(self)
            
            return view
        } else if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as! UserProfileSectionHeader
            
            view.delegate = self
            self.segmented_controller = view.segmented_controller
            return view
        }
        
        return UICollectionReusableView()
        
    }
    
    func checkForProfile() {
        UserProfileController.getUserProfile(user_id, success: { (profileData) -> Void in
            let json = profileData!
            for (_, subJson): (String, JSON) in json["data"] {
                let names = subJson["names"].string!
                let surnames = subJson["surnames"].string!
                let facebook_key = subJson["facebook_key"].string ?? ""
                let user_id = subJson["user_id"].int!
                let birth_date = subJson["birth_date"].string!
                let privacy_status = subJson["privacy_status"].int!
                let main_image = subJson["main_image"].string!
                let level = subJson["level"].int!
                let exp = subJson["exp"].double!
                let is_friend = subJson["is_friend"].bool!
                //let total_used = subJson["total_used"].int!
                
                let model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: birth_date, facebook_key: facebook_key, privacy_status: privacy_status, main_image: main_image, level: level, exp: exp)
                model.is_friend = self.is_friend
                self.person = model
            }
            
            DispatchQueue.main.async(execute: {
                self.setupProfileDetail()
            })
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    print("Error")
                })
        
        })
        
    }
    
    func setupProfileDetail() {
        
        if self.user_id == User.user_id {
            user_name = "\(User.userName)"
            if self.user_image == nil { self.downloadImage(URL(string: User.userImageUrl)!) }
            self.collectionView?.reloadData()
            //self.person.is_friend = true
        }
        
        user_name = "\(person.names) \(person.surnames)"
        if person != nil && person.is_friend != nil {
            if person.privacy_status == 1 && !person.is_friend! {
                user_name = "\(person.names) \(person.surnames)"
                self.collectionView?.reloadData()
            }
        }
        
        if self.reload { self.collectionView?.reloadData() }
    }
    
    func downloadImage(_ url: URL) {
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value{
                self.user_image?.image = image
            }else{
                self.user_image.alpha = 0.3
                self.user_image.image = UIImage(named: "dop-logo-transparent")
                self.user_image.backgroundColor = Utilities.lightGrayColor
            }
        }
        /*Utilities.downloadImage(url, completion: {(data, error) -> Void in
            if let image = UIImage(data: data!) {
                DispatchQueue.main.async {
                    self.user_image?.image = image
                }
            } else { print("Error") }
        })*/
    }
    
    func setupIndex(_ index: Int) {
        delegate?.setPage!(index)
        self.collectionView?.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func infiniteScroll() {
        delegate?.launchInfiniteScroll!(self.collectionView!)
        if person.privacy_status == 1 { self.collectionView!.finishInfiniteScroll() }
    }
    
    func setSegmentedIndex(_ index: Int) {
        self.segmented_controller!.selectedIndex = index
        self.collectionView?.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func presentView(_ notification: Foundation.Notification) {
        if searchViewIsOpen {
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
            vc.searchScrollView.isHidden = false
            Utilities.slideFromBottomAnimation(vc.searchScrollView, delay: 0, duration: 0.5, yPosition: 600)
        }
        
        if searchText.characters.count == 0 { vc.searchScrollView.isHidden = true }
        else {
            vc.searchText = searchText as NSString!
            vc.searchTimer()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        vc.searchActive = false;
        vc.timer?.invalidate()
        
        if vc.searchText != "" {
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
    
    func setBadge() {
        self.notificationButton.image = UIImage(named: "notification-badge")
    }
    
    func notification() {
        let tabbar = self.tabBarController as! TabbarController!
        self.navigationController?.pushViewController((tabbar?.vcNot)!, animated: true)
        self.notificationButton.image = UIImage(named: "notification")
        
        /*vcNot.navigationController?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vcNot, animated: true)*/
        
    }
}

