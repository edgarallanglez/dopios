//
//  SearchViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

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
    var timer: Timer? = nil
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
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //User.coordinate = locationManager.location!.coordinate
        
        self.view.backgroundColor = UIColor.clear
    }
    
    func timeOut(){
        //let searchText = searchBar.text
        if(searchText != ""){
            search()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !searching {
            if tableView == self.tableView {
                if filtered.count == 0 { return 1 }
                else { return filtered.count }
            } else {
                if peopleFiltered.count == 0 { return 1 }
                else { return peopleFiltered.count }
            }
        } else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let default_cell: UITableViewCell = UITableViewCell()
        
        if tableView == self.tableView {
            if(!searching){
                if(self.filtered.count != 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SearchCell;
                    let model = self.filtered[(indexPath as NSIndexPath).row]
                    cell.loadItem(model, viewController: self)
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    
                    return (cell)
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell") as! LoadingCell;
                    cell.label.text = "No se encontraron resultados"
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.loading_indicator.isHidden = true
                    
                    return (cell)
                }
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell") as! LoadingCell;
                cell.label.text = "Buscando"
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.loading_indicator.isHidden = false
                cell.loading_indicator.startAnimating()
                
                return (cell)
            }
        } else if tableView == self.peopleTableView {
            if(!searching){
                if(self.peopleFiltered.count != 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell") as! PeopleCell;
                    let model = self.peopleFiltered[(indexPath as NSIndexPath).row]
                    cell.loadItem(model, viewController: self)
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    ////////
                    let imageUrl = URL(string: model.main_image)
                    let identifier = "Cell\((indexPath as NSIndexPath).row)"
                    
                    if (self.cachedImages[identifier] != nil){
                        let cell_image_saved : UIImage = self.cachedImages[identifier]!
                        cell.user_image.image = cell_image_saved
                        cell.user_image.alpha = 1
                        cell.user_name.alpha = 1
                        
                    } else {
                        cell.user_name.alpha = 1
                        cell.user_image.alpha = 0.3
                        cell.user_image.image = UIImage(named: "dop-logo-transparent")
                        cell.user_image.backgroundColor = Utilities.lightGrayColor
                        if model.main_image != "" {
                            Alamofire.request(imageUrl!).responseImage { response in
                                if let image = response.result.value{
                                    if (tableView.indexPath(for: cell) as NSIndexPath?)?.row == (indexPath as NSIndexPath).row {
                                        self.cachedImages[identifier] = image
                                        
                                        cell.user_image.image = self.cachedImages[identifier]!
                                        UIView.animate(withDuration: 0.5, animations: {
                                            cell.user_image.alpha = 1
                                        })
                                    }
                                    
                                }
                            }
                        }
                        /*Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                         if let image = UIImage(data: data!) {
                         DispatchQueue.main.async {
                         let cell_image: UIImage? = image
                         
                         if (tableView.indexPath(for: cell) as NSIndexPath?)?.row == (indexPath as NSIndexPath).row {
                         if cell_image == nil { self.cachedImages[identifier] = UIImage(named: "dopLogo") }
                         else { self.cachedImages[identifier] = cell_image }
                         
                         cell.user_image.image = self.cachedImages[identifier]!
                         UIView.animate(withDuration: 0.5, animations: {
                         cell.user_image.alpha = 1
                         cell.user_name.alpha = 1
                         })
                         }
                         }
                         }else{
                         print("Error")
                         }
                         })*/
                        
                    }
                    ////////
                    
                    return (cell)
                } else {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "loadingCell") as! LoadingCell;
                    cell.label.text = "No se encontraron resultados"
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.loading_indicator.isHidden = true
                    
                    return (cell)
                }
                
            } else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "loadingCell") as! LoadingCell;
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.loading_indicator.startAnimating()
                
                return (cell)
            }
            
        }
        return(default_cell)
    }
    
    func searchTimer(){
        /*      if(searchText.length == 1){
         search()
         }else{*/
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(SearchViewController.timeOut), userInfo: nil, repeats: false)
        //}
    }
    
    
    func search(){
        filtered.removeAll()
        peopleFiltered.removeAll()
        cachedImages.removeAll()
        
        let latitude = User.coordinate.latitude
        let longitude = User.coordinate.longitude
        let params: [String:AnyObject] = [
            "text": searchText!,
            "latitude": latitude as AnyObject,
            "longitude":longitude as AnyObject
        ]
        
        searching = true
        
        if self.searchSegmentedController.selectedIndex == 0 {
            tableView.reloadData()
            SearchController.searchWithSuccess(params,
                                               success: { (couponsData) -> Void in
                                                
                                                let json = couponsData!
                                                print(json)
                                                for (_, subJson): (String, JSON) in json["data"] {
                                                    var distance:Double = 0.0
                                                    
                                                    if (!subJson["distance"].isEmpty) {
                                                        distance = Utilities.roundValue(subJson["distance"].double!,numberOfPlaces: 1.0)
                                                    }
                                                    
                                                    let name = subJson["name"].string!
                                                    let branch_id = subJson["branch_id"].int
                                                    let model = Branch(id: branch_id, name: name, distance: distance)
                                                    
                                                    self.filtered.append(model)
                                                }
                                                
                                                DispatchQueue.main.async(execute: {
                                                    self.searching = false
                                                    self.tableView.reloadData()
                                                    
                                                })
            },
                                               failure: { (error) -> Void in
                                                DispatchQueue.main.async(execute: {
                                                    self.searching = false
                                                    self.tableView.reloadData()
                                                })
            }
            )
        } else {
            peopleTableView.reloadData()
            SearchController.searchPeopleWithSuccess(params,
                                                     success: { (data) -> Void in
                                                        let json = data!
                                                        
                                                        for (_, subJson): (String, JSON) in json["data"] {
                                                            let names = subJson["names"].string!
                                                            let surnames = subJson["surnames"].string!
                                                            let user_id = subJson["user_id"].int!
                                                            let birth_date = subJson["birth_date"].string ?? ""
                                                            let facebook_key = subJson["facebok_key"].string ?? ""
                                                            let privacy_status = subJson["privacy_status"].int ?? 0
                                                            let main_image = subJson["main_image"].string ?? ""
                                                            let is_friend = subJson["is_friend"].bool!
                                                            let level = subJson["level"].int ?? 0
                                                            let exp = subJson["exp"].double ?? 0
                                                            let operation_id = subJson["operation_id"].int ?? 5
                                                            
                                                            let model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: birth_date, facebook_key: facebook_key, privacy_status: privacy_status, main_image: main_image, is_friend: is_friend, level: level, exp: exp, operation_id: operation_id)
                                                            
                                                            self.peopleFiltered.append(model)
                                                        }
                                                        DispatchQueue.main.async(execute: {
                                                            self.searching = false
                                                            self.peopleTableView.reloadData()
                                                            
                                                        })
            },
                                                     failure: { (error) -> Void in
                                                        DispatchQueue.main.async(execute: {
                                                            self.searching = false
                                                            self.peopleTableView.reloadData()
                                                        })
            }
            )
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!searching){
            var params = [String: AnyObject]()
            if(tableView == self.tableView && filtered.count > 0) {
                let model = self.filtered[(indexPath as NSIndexPath).row]
                params = ["id": model.id as AnyObject]
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "performSegue"), object: params)
                
            } else if peopleFiltered.count > 0 {
                let model = self.peopleFiltered[(indexPath as NSIndexPath).row]
                params = ["id": model.user_id as AnyObject,
                          "is_friend": model.is_friend! as AnyObject,
                          "operation_id": model.operation_id! as AnyObject ]
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "performSegue"), object: params)
            }
        }
    }
    
    @IBAction func setSearchTarget(_ sender: SearchSegmentedController) {
        switch sender.selectedIndex {
        case 0:
            tableView.reloadData()
        case 1:
            peopleTableView.reloadData()
        default:
            print("Oops!")
        }
        let x = CGFloat(sender.selectedIndex) * self.searchScrollView.frame.size.width
        self.searchScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if let cell = sender as? SearchCell {
        //            let i = tableView.indexPathForCell(cell)!.row
        //            
        //            if segue.identifier == "branchProfile" {
        //                let model = self.filtered[i]
        //                let view = segue.destinationViewController as! BranchProfileStickyController
        //                view.branch_id = model.id
        //            }
        //        }
        //        
        //        if let cell = sender as? PeopleCell {
        //            let i = peopleTableView.indexPathForCell(cell)!.row
        //            
        //            if segue.identifier == "userProfile" {
        //                let model = self.peopleFiltered[i]
        //                let view = segue.destinationViewController as! UserProfileStickyController
        //                view.user_id = model.user_id
        //                view.person = model
        //                view.user_image.image = self.cachedImages["Cell\(i)"]
        //            }
        //        }
    }
    
    
}
