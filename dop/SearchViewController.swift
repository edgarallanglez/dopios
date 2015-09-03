//
//  SearchViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        //SEARCH BAR
        var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 200, 20))
        searchBar.tintColor = UIColor.whiteColor()
        
        
        var textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        
        
        
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.placeholder = "Buscar"
        var rightNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.rightBarButtonItem = rightNavBarButton
        
        searchBar.delegate = self
        
        
        searchBar.becomeFirstResponder()
        
        let horizonalContraints = NSLayoutConstraint(item: searchBar, attribute:
            .LeadingMargin, relatedBy: .Equal, toItem: view,
            attribute: .LeadingMargin, multiplier: 1.0,
            constant: 20)
        
        //self.view.addConstraint(horizonalContraints)
        
        let horizonal2Contraints = NSLayoutConstraint(item: searchBar, attribute:
            .TrailingMargin, relatedBy: .Equal, toItem: view,
            attribute: .TrailingMargin, multiplier: 1.0, constant: -20)
        
        //self.view.addConstraint(horizonal2Contraints)
        
        let pinTop = NSLayoutConstraint(item: searchBar, attribute: .Top, relatedBy: .Equal,
            toItem: view, attribute: .Top, multiplier: 1.0, constant: 100)
        
        searchBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        NSLayoutConstraint.activateConstraints([horizonalContraints, horizonal2Contraints, pinTop])

        //
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
