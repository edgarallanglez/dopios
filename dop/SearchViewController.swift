//
//  SearchViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate {

    var searchBar:UISearchBar!
    
    var searchActive : Bool = false
    var data:[NearbyBranch] = []
    var filtered:[NearbyBranch] = []
    
    var searching:Bool = false
    var timer : NSTimer? = nil
    
    
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        //SEARCH BAR
        searchBar = UISearchBar(frame: CGRectMake(0, 0, 100, 20))
        searchBar.tintColor = UIColor.whiteColor()
        
        
        var textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        
        
        
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.placeholder = "Buscar"
        //var rightNavBarButton = UIBarButtonItem(customView:searchBar)
        //self.navigationItem.rightBarButtonItem = rightNavBarButton
        
        
        self.navigationController?.navigationBar.addSubview(searchBar)
        //self.view.addSubview(searchBar)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        
        searchBar.becomeFirstResponder()
        
        
        
        
        searchBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        searchBar.alpha = 0


        //
        
        data = []
        
        tableView.reloadData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let horizonalContraints = NSLayoutConstraint(item: searchBar, attribute:
            .LeadingMargin, relatedBy: .Equal, toItem: self.view,
            attribute: .LeadingMargin, multiplier: 1.0,
            constant: 30)
        
        
        let horizonal2Contraints = NSLayoutConstraint(item: searchBar, attribute:
            .TrailingMargin, relatedBy: .Equal, toItem: self.view,
            attribute: .TrailingMargin, multiplier: 1.0, constant: 0)
        
        
        let pinTop = NSLayoutConstraint(item: searchBar, attribute: .Top, relatedBy: .Equal,
            toItem: self.navigationController?.navigationBar, attribute: .Top, multiplier: 1.0, constant: 0)
        
        
        NSLayoutConstraint.activateConstraints([horizonalContraints, horizonal2Contraints, pinTop])
        
        UIView.animateWithDuration(0.3, animations: {
            self.searchBar.alpha = 1
        })
        
        
    }
    override func viewDidDisappear(animated: Bool) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        
        
        

    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        timer?.invalidate()
        search()
        searchBar.resignFirstResponder()
    }
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "timeOut", userInfo: nil, repeats: false)
        
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        /*filtered = data.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })*/
        /*if(filtered.isEmpty){
            searchActive = false;
        } else {
            searchActive = true;
        }*/
        //self.tableView.reloadData()
    }
    func timeOut(){
        search()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*if(searchActive) {
            return filtered.count
        }*/
        return data.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! SearchCell;
        if(searchActive){
            let model = self.filtered[indexPath.row]
            
            cell.loadItem(model, viewController: self)
            
        } else {
            let model = self.data[indexPath.row]
            
            cell.loadItem(model, viewController: self)
        }
        
        return cell;
    }
    
    
    func search(){
        filtered.removeAll()
        
        var searchText = searchBar.text.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
       
        searchBar.text = searchText
        
        let params:[String: AnyObject] = [
            "text" : searchText,
            "latitude" : "24.766499",
            "longitude" : "-107.469864"]
        
        println(params)
        SearchController.searchWithSuccess(params,
            success: { (couponsData) -> Void in
                
                let json = JSON(data: couponsData)
                println(json)
                for (index: String, subJson: JSON) in json["data"] {
                    
                    let distance = subJson["distance"].double!
                    let name = subJson["name"].string!
                    let branch_id = subJson["branch_id"].int
                    
                    let model = NearbyBranch(id: branch_id, name: name, distance:distance)
                    
                    self.filtered.append(model)
                }

                
                dispatch_async(dispatch_get_main_queue(), {
                    self.data.removeAll()
                    self.data = self.filtered
                    
                    self.tableView.reloadData()

                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }


}
