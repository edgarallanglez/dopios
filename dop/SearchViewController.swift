//
//  SearchViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var peopleTableView: UITableView!
    @IBOutlet weak var searchSegmentedController: SearchSegmentedController!
    @IBOutlet weak var searchScrollView: UIScrollView!
    
    var searchBar: UISearchBar!
    var searchActive: Bool = false
    var filtered: [Branch] = []
    var peopleFiltered: [PeopleModel] = []
    var cachedImages: [String: UIImage] = [:]
    
    var searching: Bool = false
    var timer: NSTimer? = nil
    var coordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager!
    var current: CLLocation!
    
    var searchText: NSString!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        
        tableView.reloadData()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        User.coordinate = locationManager.location!.coordinate
        
        

        self.view.backgroundColor = UIColor.clearColor()
        
    }

    func timeOut(){
        //let searchText = searchBar.text
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
                if filtered.count == 0{
                    return 1
                }else{
                    return filtered.count
                }
            }else{
                if peopleFiltered.count == 0{
                    return 1
                }else{
                    return peopleFiltered.count
                }
            }

        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let default_cell: UITableViewCell = UITableViewCell()
        
        if tableView == self.tableView {
            if(!searching){
                if(self.filtered.count != 0){
                    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! SearchCell;
                    let model = self.filtered[indexPath.row]
                    cell.loadItem(model, viewController: self)
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    
                    return (cell)
                }else{
                    let cell = tableView.dequeueReusableCellWithIdentifier("loadingCell") as! LoadingCell;
                    cell.label.text = "No se encontraron resultados"
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.loading_indicator.hidden = true
                    
                    return (cell)
                }
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("loadingCell") as! LoadingCell;
                cell.label.text = "Buscando"
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.loading_indicator.hidden = false
                cell.loading_indicator.startAnimating()
                
                return (cell)
            }
        } else if tableView == self.peopleTableView {
            if(!searching){
                if(self.peopleFiltered.count != 0){
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
                        Utilities.getDataFromUrl(imageUrl!) { data in
                            dispatch_async(dispatch_get_main_queue()) {
                                let cell_image: UIImage? = UIImage(data: data!)
                                
                                if tableView.indexPathForCell(cell)?.row == indexPath.row {
                                    if cell_image == nil { self.cachedImages[identifier] = UIImage(named: "dopLogo") }
                                    else { self.cachedImages[identifier] = cell_image }
                    
                                    cell.user_image.image = self.cachedImages[identifier]!
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
                    cell.label.text = "No se encontraron resultados"
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.loading_indicator.hidden = true
                    
                    return (cell)
                }
                
            } else {
                let cell = self.tableView.dequeueReusableCellWithIdentifier("loadingCell") as! LoadingCell;
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.loading_indicator.startAnimating()
                
                return (cell)
            }
            
        }
        return(default_cell)
    }
    
    func searchTimer(){
        if(searchText.length == 1){
            search()
        }else{
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timeOut", userInfo: nil, repeats: false)
        }
    }
    
    
    func search(){
        filtered.removeAll()
        peopleFiltered.removeAll()
        cachedImages.removeAll()
        
        
        let latitude = User.coordinate.latitude
        let longitude = User.coordinate.longitude
        let params: [String:AnyObject] = [
            "text": searchText!,
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
                        let model = Branch(id: branch_id, name: name, distance: distance)
                        
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
                        let isFriend = subJson["friend"].bool!
                        
                        let model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: birth_date, facebook_key: facebook_key, privacy_status: privacy_status, main_image: main_image, is_friend: isFriend)
                        
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
            
            if(tableView == self.tableView && filtered.count>0){
                 let model = self.filtered[indexPath.row]
                
                NSNotificationCenter.defaultCenter().postNotificationName("performSegue", object: model.id)

            }else
                if(peopleFiltered.count > 0){
                 let model = self.peopleFiltered[indexPath.row] 
                NSNotificationCenter.defaultCenter().postNotificationName("performSegue", object: model.user_id)

            }
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
        /*if let cell = sender as? SearchCell {
            let i = tableView.indexPathForCell(cell)!.row
            
            if segue.identifier == "branchProfile" {
                let model = self.filtered[i]
                let view = segue.destinationViewController as! BranchProfileStickyController
                view.branch_id = model.id
            }
        }
        
        if let cell = sender as? PeopleCell {
            let i = peopleTableView.indexPathForCell(cell)!.row
            
            if segue.identifier == "userProfile" {
                let model = self.peopleFiltered[i]
                let view = segue.destinationViewController as! UserProfileStickyController
                view.user_id = model.user_id
                view.person = model
                //view.user_image.image = self.cachedImages["Cell\(i)"]
            }
        }*/
    }
    

}
