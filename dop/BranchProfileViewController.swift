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

    
    @IBOutlet weak var tableView: UITableView!
    var branchId: Int!
    var logo: UIImage!
    var logoString: String!
    var coupons = [Coupon]()
    var json: JSON!
    var headerTopView: BranchProfileTopView = BranchProfileTopView()
    var selectedIndex: Int = 0

    
    override func viewDidLoad() {
        var couponNib = UINib(nibName: "CouponCell", bundle: nil)
        tableView.registerNib(couponNib, forCellReuseIdentifier: "CouponCell")
        var aboutNib = UINib(nibName: "BranchProfileAboutView", bundle: nil)
        tableView.registerNib(aboutNib, forCellReuseIdentifier: "BranchProfileAboutView")
        
//      branchLogo.image = self.logo
    }
    
    override func viewDidAppear(animated: Bool) {
//        getBranchProfile()
//        getBranchCouponTimeline()
   }
    

    
//    func getBranchProfile() {
//        BranchProfileController.getBranchProfileWithSuccess(branchId, success: { (branchData) -> Void in
//            let data = JSON(data: branchData)
//            var json = data["data"]
//            json = json[0]
//            var latitude = json["latitude"].double
//            var longitude = json["longitude"].double
//            
//            let branchPin = CLLocation(latitude: latitude!, longitude: longitude!)
//            var newLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                self.branchName.text = json["name"].string
//                var dropPin = MKPointAnnotation()
//                dropPin.coordinate = newLocation
//                self.branchLocationMap.addAnnotation(dropPin)
//                self.centerMapOnLocation(branchPin)
//            })
//        })
//    }
    
    func getBranchCouponTimeline() {
        coupons = [Coupon]()
        BranchProfileController.getBranchCouponTimeline(branchId, success: { (couponsData) -> Void in
            let json = JSON(data: couponsData)
            
            var namex = "";
            for (index: String, subJson: JSON) in json["bond"]{
                var coupon_id = subJson["coupon_id"].int!
                let coupon_name = subJson["name"].string!
                let coupon_description = subJson["description"].string!
                let coupon_limit = "hoy"
                let coupon_exp = subJson["end_date"].string!
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: self.logoString, branch_id: self.branchId)
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
                                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: self.logoString, branch_id: self.branchId)
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
                                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: self.logoString, branch_id: self.branchId)
                println(subJson)
                
                                self.coupons.append(model)
                
                                println(coupon_name)
                                namex = coupon_name
            }
            
            for (index: String, subJson: JSON) in json["new_promo"]{
                var coupon_id = subJson["coupon_id"].int!
                let coupon_name = subJson["name"].string ?? ""
                let coupon_description = subJson["description"].string ?? ""
                let coupon_limit = "pasado mañana"
                let coupon_exp = subJson["end_date"].string ?? ""
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: self.logoString, branch_id: self.branchId)
                println(subJson)
                
                self.coupons.append(model)
                
                println(coupon_name)
                namex = coupon_name
            }
            
            dispatch_async(dispatch_get_main_queue(), {
//                self.couponTimeline.reloadData()
            })

        })
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 285
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cell: BranchProfileAboutView = tableView.dequeueReusableCellWithIdentifier("BranchProfileAboutView", forIndexPath: indexPath) as! BranchProfileAboutView
        
//        let model = Coupon(id: 2, name: "Edgar Allan", description: "Todo Gratis", limit: "20", exp: "1000 pts", logo: "cinepolis.jpeg", branch_id: 2)
        
//        cell.loadItem(model, viewController: self)
//        cell.branchImage.setBackgroundImage(self.logo, forState: UIControlState.Normal)
        var initialLocation = CLLocation(latitude: 24.815471, longitude: -107.397844)
        cell.loadAbout("Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. ", branchLocation: initialLocation)
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerTopView = (NSBundle.mainBundle().loadNibNamed("BranchProfileTopView", owner: self, options: nil)[0] as? BranchProfileTopView)!
        headerTopView.branchProfileSegmented?.addTarget(self, action: "setTableViewAtIndex", forControlEvents: .ValueChanged)
        return headerTopView
    }
    
    func setTableViewAtIndex() {
        selectedIndex = headerTopView.branchProfileSegmented.selectedIndex
        println(selectedIndex)
    }
    
}