//
//  SearchViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var peopleTableView: UITableView!
    @IBOutlet weak var searchSegmentedController: SearchSegmentedController!
    @IBOutlet weak var searchScrollView: UIScrollView!
    
    var searchBar: UISearchBar!
    var searchActive: Bool = false
    var filtered: [NearbyBranch] = []
    var peopleFiltered: [PeopleModel] = []
    var cachedImages: [String: UIImage] = [:]
    
    var searching: Bool = false
    var timer: NSTimer? = nil
    var coordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager!
    var current: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //SEARCH BAR
        searchBar = UISearchBar(frame: CGRectMake(0, 0, 100, 20))
        searchBar.tintColor = UIColor.whiteColor()
        
        //searchScrollView.contentSize = CGSizeMake(searchScrollView.frame.size.width * 2, searchScrollView.frame.height)
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
        
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        
        searchBar.delegate = self
        
        searchBar.becomeFirstResponder()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.alpha = 0
        
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
        
        let searchText = searchBar.text
        
        if(searchText != ""){
            search()
            searchBar.resignFirstResponder()
        }
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
        let searchText = searchBar.text
        
        if(searchText != ""){
            search()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!searching) {
            if tableView == self.tableView {
                return filtered.count
            } else {
                return peopleFiltered.count
            }
        } else {
            return 1;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let default_cell: UITableViewCell = UITableViewCell()
        if tableView == self.tableView {
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
        } else if tableView == self.peopleTableView {
            if(!searching){
                let cell = tableView.dequeueReusableCellWithIdentifier("PeopleCell") as! PeopleCell;
                let model = self.peopleFiltered[indexPath.row]
                cell.loadItem(model, viewController: self)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                ////////
                let imageUrl = NSURL(string: model.main_image)
                let identifier = "Cell\(indexPath.row)"
                
                if (self.cachedImages[identifier] != nil){
                    let cell_image_saved : UIImage = self.cachedImages[identifier]!
                    cell.user_image.image = cell_image_saved
                    cell.user_image.alpha = 1
                    cell.user_name.alpha = 1
                    
                } else {
                    cell.user_image.alpha = 0
                   // cell.user_name.alpha = 0
                    Utilities.getDataFromUrl(imageUrl!) { data in
                        dispatch_async(dispatch_get_main_queue()) {
                            var cell_image : UIImage = UIImage()
                            cell_image = UIImage (data: data!)!
                            
                            if tableView.indexPathForCell(cell)?.row == indexPath.row {
                                self.cachedImages[identifier] = cell_image
                                let cell_image_saved : UIImage = self.cachedImages[identifier]!
                                cell.user_image.image = cell_image_saved
                                UIView.animateWithDuration(0.5, animations: {
                                    cell.user_image.alpha = 1
                                    cell.user_name.alpha = 1
                                })
                            }
                        }
                    }
                }
                ////////
                
                return (cell)
                
            } else {
                let cell = self.tableView.dequeueReusableCellWithIdentifier("loadingCell") as! LoadingCell;
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.loading_indicator.startAnimating()
                
                return (cell)
            }
            
        }
        return(default_cell)
    }
    
    
    func search(){
        filtered.removeAll()
        peopleFiltered.removeAll()
        
        let searchText: String = searchBar.text!
        let latitude = User.coordinate.latitude
        let longitude = User.coordinate.longitude
        let params: [String:AnyObject] = [
            "text": searchText,
            "latitude": latitude,
            "longitude":longitude
        ]
        searching = true
        
        
        if self.searchSegmentedController.selectedIndex == 0 {
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
                        self.searching = false
                        self.tableView.reloadData()

                    })
                },
                failure: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.searching = false
                        self.tableView.reloadData()
                    })
                }
            )
        } else {
            peopleTableView.reloadData()
            SearchController.searchPeopleWithSuccess(params,
                success: { (data) -> Void in
                    let json = JSON(data: data)
                    print(json)
                    for (_, subJson): (String, JSON) in json["data"] {
                        let names = subJson["names"].string!
                        let surnames = subJson["surnames"].string!
                        let user_id = subJson["user_id"].int!
                        let birth_date = subJson["birth_date"].string!
                        let facebook_key = subJson["facebok_key"].string ?? ""
                        let privacy_status = subJson["privacy_status"].int!
                        let main_image = subJson["main_image"].string!
                        
                        let model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: birth_date, facebook_key: facebook_key, privacy_status: privacy_status, main_image: main_image)
                        
                        self.peopleFiltered.append(model)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.searching = false
                        self.peopleTableView.reloadData()
                        
                    })
                },
                failure: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.searching = false
                        self.peopleTableView.reloadData()
                    })
                }
            )
        }
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
    
    @IBAction func setSearchTarget(sender: SearchSegmentedController) {
        switch sender.selectedIndex {
        case 0:
            tableView.reloadData()
        case 1:
            peopleTableView.reloadData()
        default:
            print("Oops!")
        }
        let x = CGFloat(sender.selectedIndex) * self.searchScrollView.frame.size.width
        self.searchScrollView.setContentOffset(CGPointMake(x, 0), animated: true)
        
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
