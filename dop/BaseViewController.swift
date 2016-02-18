//
//  BaseViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 11/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate, NotificationBadgeDelegate {
    
    var notificationButton: UIBarButtonItem!
    var vc: SearchViewController!
    var vcNot: NotificationViewController!
    var searchBar: UISearchBar = UISearchBar()
    var errorView: UIView = UIView()
    
    var searchView: UIView!
    var searchViewIsOpen: Bool = false
    var searchViewIsSegue: Bool = false
    
    var cancelSearchButton:UIBarButtonItem!
    
    var badgeDelegate: NotificationBadgeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationButton = UIBarButtonItem(image: UIImage(named: "notification"), style: UIBarButtonItemStyle.Plain, target: self, action: "notification")
        
        
        self.navigationItem.rightBarButtonItem = notificationButton

        
        vc  = self.storyboard!.instantiateViewControllerWithIdentifier("SearchView") as! SearchViewController
        
        vcNot = self.storyboard!.instantiateViewControllerWithIdentifier("Notifications") as! NotificationViewController
        
        
        searchBar.delegate = self
        
        
        self.navigationItem.titleView = searchBar
        
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
        

        self.navigationController?.delegate = self
        
        
        errorView = (NSBundle.mainBundle().loadNibNamed("ErrorView", owner: self, options: nil)[0] as? UIView)!
        
        
        errorView.frame.size.width = self.view.frame.width
        errorView.backgroundColor = UIColor.redColor()
        
        searchView = UIView(frame: CGRectMake(0,0,self.view.frame.width,self.view.frame.height))
        
        //Add blur view to search view
        var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func notification() {
        let tabbar = self.tabBarController as! TabbarController!
        self.navigationController?.pushViewController(tabbar.vcNot, animated: true)
        self.notificationButton.image = UIImage(named: "notification")

       /*vcNot.navigationController?.hidesBottomBarWhenPushed = true
       self.navigationController?.pushViewController(vcNot, animated: true)*/
        
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        viewController.viewDidAppear(true)
    }

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        viewController.viewWillAppear(true)
        if(!searchViewIsSegue) {
            cancelSearch()
        }
        searchViewIsSegue = false


    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    func presentView(notification:NSNotification){
        if(searchViewIsOpen){
            searchViewIsSegue = true
            
            print("SEGMENTED INDEX \(vc.searchSegmentedController.selectedIndex)")
            
            let object_id = notification.object as! Int
            
            if vc.searchSegmentedController.selectedIndex == 0 {
                let viewControllerToPresent = self.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
                viewControllerToPresent.branch_id = object_id
                self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
                
                print("BRANCH PROFILE")
            }
            if vc.searchSegmentedController.selectedIndex == 1 {
                let viewControllerToPresent = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileStickyController") as! UserProfileStickyController
                viewControllerToPresent.user_id = object_id
                self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
                
                print("USER PROFILE")
            }
            
            searchBar.resignFirstResponder()
            
        }
        
    }
    func setBadge(){
        print("HEY")
    }
    
}
