//
//  BranchProfileViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/8/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit

class BranchProfileViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var branchLogo: UIImageView!
    @IBOutlet weak var branchName: UILabel!
    @IBOutlet weak var branchLocationMap: MKMapView!
    @IBOutlet weak var couponTimeline: UITableView!
    
    var branchId: Int!
    let regionRadius: CLLocationDistance = 500
    var coupons = [Coupon]()
    var json: JSON!
    
    override func viewDidLoad() {
        var nib = UINib(nibName: "CouponCell", bundle: nil)
        couponTimeline.registerNib(nib, forCellReuseIdentifier: "CouponCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        getBranchProfile()
        getBranchCouponTimeline()
    }
    
    func getBranchProfile() {
        branchLogo.image = UIImage(named: "starbucks.gif")
        BranchProfileController.getBranchProfileWithSuccess(2, success: { (branchData) -> Void in
            let data = JSON(data: branchData)
            var json = data["data"]
            json = json[0]
            var latitude = json["latitude"].double
            var longitude = json["longitude"].double
            
            let branchPin = CLLocation(latitude: latitude!, longitude: longitude!)
            var newLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.branchName.text = json["name"].string
                var dropPin = MKPointAnnotation()
                dropPin.coordinate = newLocation
                self.branchLocationMap.addAnnotation(dropPin)
                self.centerMapOnLocation(branchPin)
            })
        })
    }
    
    func getBranchCouponTimeline() {
        coupons = [Coupon]()
        BranchProfileController.getBranchCouponTimeline(2, success: { (couponsData) -> Void in
            let json = JSON(data: couponsData)
            
            var namex = "";
            for (index: String, subJson: JSON) in json["bond"]{
                var coupon_id = subJson["coupon_id"].int!
                let coupon_name = subJson["name"].string!
                let coupon_description = subJson["description"].string!
                let coupon_limit = "hoy"
                let coupon_exp = subJson["end_date"].string!
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp)
                println(subJson)
                
                self.coupons.append(model)
                
                println(coupon_name)
                namex = coupon_name
            }
            
            for (index: String, subJson: JSON) in json["nxn"] {
                                var coupon_id = subJson["coupon_id"].int!
                                let coupon_name = subJson["name"].string ?? ""
                                let coupon_description = subJson["description"].string ?? ""
                                let coupon_limit = "Mañana"
                                let coupon_exp = subJson["end_date"].string ?? ""
                                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp)
                println(subJson)
                
                                self.coupons.append(model)
                
                                println(coupon_name)
                                namex = coupon_name
            }
            
            for (index: String, subJson: JSON) in json["discount"]{
                                var coupon_id = subJson["coupon_id"].int!
                                let coupon_name = subJson["name"].string ?? ""
                                let coupon_description = subJson["description"].string ?? ""
                                let coupon_limit = "pasado mañana"
                                let coupon_exp = subJson["end_date"].string ?? ""
                                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp)
                println(subJson)
                
                                self.coupons.append(model)
                
                                println(coupon_name)
                                namex = coupon_name
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.couponTimeline.reloadData()
            })

        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return coupons.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cell: CouponCell = tableView.dequeueReusableCellWithIdentifier("CouponCell", forIndexPath: indexPath) as! CouponCell
        
        let model = self.coupons[indexPath.section]
        var (title) = model.name
        var description = model.couponDescription
        
        cell.loadItem(title: title, description: description, viewController: self)
        
        return cell
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        branchLocationMap.setRegion(coordinateRegion, animated: true)
    }
    
    
}