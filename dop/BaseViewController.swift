//
//  BaseViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 11/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate {
    
    var notificationButton: UIBarButtonItem!
    var vc: SearchViewController!
    //var vcNot: NotificationViewController!
    var searchBar: UISearchBar = UISearchBar()
    var errorView: UIView = UIView()
    
    var searchView: UIView!
    var searchViewIsOpen: Bool = false
    var searchViewIsSegue: Bool = false
    
    var cancelSearchButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.setBadge), name: NSNotification.Name(rawValue: "newNotification"), object: nil)

        
        notificationButton = UIBarButtonItem(image: UIImage(named: "notification"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BaseViewController.notification))
        
        
        self.navigationItem.rightBarButtonItem = notificationButton

        
        vc  = self.storyboard!.instantiateViewController(withIdentifier: "SearchView") as! SearchViewController
        
        //vcNot = self.storyboard!.instantiateViewController(withIdentifier: "Notifications") as! NotificationViewController
        
        
        searchBar.delegate = self
        
        
        self.navigationItem.titleView = searchBar
        
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
        

        self.navigationController?.delegate = self
        
        
        errorView = (Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)![0] as? UIView)!
        
        
        errorView.frame.size.width = self.view.frame.width
        errorView.backgroundColor = UIColor.red
        
        searchView = UIView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width,height: self.view.frame.height))
        
        //Add blur view to search view
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.extraLight))
        blurView.frame = searchView.bounds
        
        vc.view.addSubview(blurView)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BaseViewController.cancelSearch))
        blurView.addGestureRecognizer(gestureRecognizer)
        
        //vc.searchScrollView.hidden = true
        vc.searchScrollView.isHidden = true
        
        
        
        cancelSearchButton = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(BaseViewController.cancelSearch))
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(BaseViewController.presentView(_:)),
            name: NSNotification.Name(rawValue: "performSegue"),
            object: nil)
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func notification() {
       let vcNot = self.storyboard!.instantiateViewController(withIdentifier: "Notifications") as! NotificationViewController
        
        //let tabbar = self.tabBarController as! TabbarController!
        self.navigationController?.pushViewController(vcNot, animated: true)
        //self.navigationController?.pushViewController((tabbar?.vcNot)!, animated: true)
        self.notificationButton.image = UIImage(named: "notification")

       /*vcNot.navigationController?.hidesBottomBarWhenPushed = true
       self.navigationController?.pushViewController(vcNot, animated: true)*/
        
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }

    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        viewController.viewDidAppear(true)
        
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.viewWillAppear(true)
        if(!searchViewIsSegue) {
            cancelSearch()
        }
        searchViewIsSegue = false


    }
    override func viewWillAppear(_ animated: Bool) {
        
        
        if User.newNotification {
            self.notificationButton.image = UIImage(named: "notification-badge")
        }else{
            self.notificationButton.image = UIImage(named: "notification")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    func presentView(_ notification: Foundation.Notification){
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
    func setBadge(){
        self.notificationButton.image = UIImage(named: "notification-badge")
        User.newNotification = true
    }

}
