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
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var contentTabbed: UIView!
    
    @IBOutlet weak var segmentedControlTabs: UISegmentedControl!
    
    var branchId: Int!
    var logo: UIImage!
    var logoString: String!
    let regionRadius: CLLocationDistance = 500
    var coupons = [Coupon]()
    var json: JSON!
    
    var tableView:UIView = UIView()
    
    override func viewDidLoad() {
//        var nib = UINib(nibName: "CouponCell", bundle: nil)
//        couponTimeline.registerNib(nib, forCellReuseIdentifier: "CouponCell")
//        branchLogo.image = self.logo
        branchLogo.image = UIImage(named: "starbucks.gif")
        backgroundImage.image = UIImage(named: "starbucks_banner.jpg")
   
    }
    
    override func viewDidAppear(animated: Bool) {
//        getBranchProfile()
//        getBranchCouponTimeline()
        var application: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        var tabBarController = application.tabBarController as? UITabBarController
//        var selectedIndex:Int = application.tabBarController!.selectedIndex
//        application(application: application, didFinishLaunchingWithOptions: self.tabBarController)
   }
    
    func getBranchProfile() {
        BranchProfileController.getBranchProfileWithSuccess(branchId, success: { (branchData) -> Void in
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
        
        cell.loadItem(model, viewController: self)
        cell.branchImage.setBackgroundImage(self.logo, forState: UIControlState.Normal)
        return cell
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        branchLocationMap.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func segmentedControl(sender: UISegmentedControl) {
        
        switch segmentedControlTabs.selectedSegmentIndex {
        case 0:
            contentTabbed.backgroundColor = UIColor.greenColor()
        case 1:
            contentTabbed.backgroundColor = Utilities.dopColor
        case 2:
            contentTabbed.backgroundColor = UIColor.grayColor()
        default:
            break
            
        }
    }
    
}