//
//  SearchViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {

    var searchBar:UISearchBar!
    
    var searchActive : Bool = false
    var data:[NearbyBranch] = []
    var filtered:[NearbyBranch] = []
    
    var searching:Bool = false
    var timer : NSTimer? = nil
    
    
    var coordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager!
    var current: CLLocation!
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        //SEARCH BAR
        searchBar = UISearchBar(frame: CGRectMake(0, 0, 100, 20))
        searchBar.tintColor = UIColor.whiteColor()
        
        
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
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
        
        
        
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.alpha = 0


        //
        
        data = []
        
        tableView.reloadData()
        
        
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        User.coordinate = locationManager.location!.coordinate
        
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
        
        UIView.animateWithDuration(0.3, animations: {
            self.searchBar.alpha = 0
        })
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
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timeOut", userInfo: nil, repeats: false)
        
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
        if(!searching) {
            return filtered.count
        }else{
            return 1;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell:UITableViewCell
        if(!searching){
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! SearchCell;
            
            let model = self.filtered[indexPath.row]
            
            cell.loadItem(model, viewController: self)
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None

            return (cell)
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("loadingCell") as! LoadingCell;
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None

            cell.loading_indicator.startAnimating()
            
            return (cell)
        }
        
    }
    
    
    func search(){
        filtered.removeAll()
        
        let searchText: String = searchBar.text!
        
        let latitude = User.coordinate.latitude
        let longitude = User.coordinate.longitude
        
        
        let params: [String:AnyObject] = [
            "text": searchText,
            "latitude": latitude,
            "longitude":longitude
        ]
        
        searching = true
        tableView.reloadData()

        SearchController.searchWithSuccess(params,
            success: { (couponsData) -> Void in
                
                let json = JSON(data: couponsData)
                print(json)
                for (_, subJson): (String, JSON) in json["data"] {
                    var distance:Double = 0.0
                    
                    if(subJson["distance"]){
                         distance = Utilities.roundValue(subJson["distance"].double!,numberOfPlaces: 1.0)
                    }
                    let name = subJson["name"].string!
                    let branch_id = subJson["branch_id"].int
                    
                   
                    
                    
                    let model = NearbyBranch(id: branch_id, name: name, distance:distance)
                    
                    self.filtered.append(model)
                }

                
                dispatch_async(dispatch_get_main_queue(), {
                    self.data.removeAll()
                    self.data = self.filtered
                    
                    self.searching = false
                    
                    self.tableView.reloadData()

                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {

                    self.searching = false
                    
                    self.tableView.reloadData()
                })
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(!searching){
            let cell: SearchCell = tableView.cellForRowAtIndexPath(indexPath) as! SearchCell
            self.performSegueWithIdentifier("branchProfile", sender: cell)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? SearchCell {
            
            let i = tableView.indexPathForCell(cell)!.row
            let model = self.filtered[i]
            
            if segue.identifier == "branchProfile" {
                let view = segue.destinationViewController as! BranchProfileViewController
                view.branchId = model.id
                
                           }
        }
    }
    

}
