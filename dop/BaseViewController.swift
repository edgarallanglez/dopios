//
//  BaseViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 11/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate {
    var notificationButton: NotificationButton!
    var vc: SearchViewController!
    var vcNot: NotificationViewController!
    var searchBar: UISearchBar = UISearchBar()
    var errorView: UIView = UIView()
    var searchView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationButton = NotificationButton(image: UIImage(named: "notification"), style: UIBarButtonItemStyle.Plain, target: self, action: "notification")
        
        
        //self.navigationItem.rightBarButtonItem = notificationButton

        
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
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if(searchView == nil){
            searchView = UIView(frame: CGRectMake(0,0,self.view.frame.width,self.view.frame.height+49))
            searchView.backgroundColor = UIColor.redColor()

            /*view.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
            view.layoutIfNeeded()*/
            
            self.view.addSubview(searchView)
            

            
            searchView.addSubview(vc.view)
            
            //vc.searchBarTextDidBeginEditing(searchBar)
            //vc.searchBar.text = searchBar.text
            //self.searchBar.delegate = searchView
        }
        return true
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        vc.searchText = searchText
        vc.searchTimer()
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
       vcNot.navigationController?.hidesBottomBarWhenPushed = true
       self.navigationController?.pushViewController(vcNot, animated: true)
        //self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("Notifications") as UIViewController, animated: true)
        //self.navigationController?.hidesBottomBarWhenPushed = true
        
        //self.performSegueWithIdentifier("notificationView", sender: nil)
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
        if((searchView) != nil){
            searchView.removeFromSuperview()
        }
        viewController.viewWillAppear(true)
    }
    
}
