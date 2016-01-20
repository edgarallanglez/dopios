////
////  BranchProfileViewController.swift
////  dop
////
////  Created by Edgar Allan Glez on 7/8/15.
////  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
////
//
//import UIKit
//import MapKit
//
//class BranchProfileViewController: UIViewController, CLLocationManagerDelegate {
//
//    
//    @IBOutlet weak var tableView: UITableView!
//    var branchId: Int!
//    var logo: UIImage!
//    var logoString: String!
//    var coupons = [Coupon]()
//    var json: JSON!
//    var headerTopView: BranchProfileTopView = BranchProfileTopView()
//    var aboutView: BranchProfileAboutView = BranchProfileAboutView()
//    var selectedIndex: Int = 0
//    var dropPin: Annotation!
//    var branchPin: CLLocation!
//
//    
//    override func viewDidLoad() {
//        
//        print("Branch profile view controller \(branchId)")
//
//        let couponNib = UINib(nibName: "CouponCell", bundle: nil)
//        tableView.registerNib(couponNib, forCellReuseIdentifier: "CouponCell")
//        let aboutNib = UINib(nibName: "BranchProfileAboutView", bundle: nil)
//        tableView.registerNib(aboutNib, forCellReuseIdentifier: "BranchProfileAboutView")
//        let campaignNib = UINib(nibName: "BranchProfileLastCampaign", bundle: nil)
//        tableView.registerNib(campaignNib, forCellReuseIdentifier: "BranchProfileLastCampaign")
//        
//        headerTopView = (NSBundle.mainBundle().loadNibNamed("BranchProfileTopView", owner: self, options: nil)[0] as? BranchProfileTopView)!
//        
//        aboutView = (NSBundle.mainBundle().loadNibNamed("BranchProfileAboutView", owner: self, options: nil)[0] as? BranchProfileAboutView)!
//
//        headerTopView.branchId = branchId
//        headerTopView.branchLogo.image = self.logo
//        self.headerTopView.branchCover.image = self.headerTopView.branchCover.image?.applyLightEffect()
//        getBranchProfile()
//        
////      branchLogo.image = self.logo
//    }
//    
//    override func viewDidAppear(animated: Bool) {
////        self.aboutView.centerMapOnLocation(self.branchPin)
//   }
//    
//
//    
//    func getBranchProfile() {
//        BranchProfileController.getBranchProfileWithSuccess(branchId, success: { (branchData) -> Void in
//            let data = JSON(data: branchData)
//            var json = data["data"]
//            json = json[0]
//            let latitude = json["latitude"].double
//            let longitude = json["longitude"].double
//            
//            self.branchPin = CLLocation(latitude: latitude!, longitude: longitude!)
//            let newLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
//            self.aboutView.branchPin = self.branchPin
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                self.headerTopView.branchName.text = json["name"].string
//                self.dropPin = Annotation(coordinate: newLocation, title: json["name"].string!, subTitle: "nada")
//                if json["category_id"].int! == 1 {
//                    self.dropPin.typeOfAnnotation = "marker-food-icon"
//                } else if json["category_id"].int! == 2 {
//                    self.dropPin.typeOfAnnotation = "marker-services-icon"
//                } else if json["category_id"].int! == 3 {
//                    self.dropPin.typeOfAnnotation = "marker-entertainment-icon"
//                }
////                self.headerTopView.setImages(self.logo, company_id: json["company_id"].int!)
//                self.tableView.reloadData()
//                
//            })
//        })
//    }
//    
//    func getBranchCouponTimeline() {
//        coupons = [Coupon]()
//        BranchProfileController.getBranchCouponTimeline(branchId, success: { (couponsData) -> Void in
//            let json = JSON(data: couponsData)
//            
//            print(json)
//        
//            for (_, subJson): (String, JSON) in json["bond"]{
//                var coupon_id = subJson["coupon_id"].int!
//                let coupon_name = subJson["name"].string!
//                let coupon_description = subJson["description"].string!
//                let coupon_limit = "hoy"
//                let coupon_exp = ""
//                let latitude = 0.0
//                let longitude = 0.0
//                //let latitude = subJson["latitude"].double!
//                //let longitude = subJson["longitude"].double!
//                
//                
//                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: self.logoString, branch_id: self.branchId, company_id: 1, total_likes: 0 ,user_like: 0, latitude: latitude, longitude: longitude, banner: "", category_id: 1)
//                
//                self.coupons.append(model)
//            }
//            
//            for (_, subJson): (String, JSON) in json["nxn"] {
//                var coupon_id = subJson["coupon_id"].int!
//                let coupon_name = subJson["name"].string ?? ""
//                let coupon_description = subJson["description"].string ?? ""
//                let coupon_limit = "Mañana"
//                let coupon_exp = subJson["end_date"].string ?? ""
//                let latitude = 0.0//subJson["latitude"].double!
//                let longitude = 0.0//subJson["longitude"].double!
//                
//                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: self.logoString, branch_id: self.branchId,company_id: 1, total_likes: 0 ,user_like: 0, latitude: latitude, longitude: longitude, banner: "", category_id: 1)
//                
//                self.coupons.append(model)
//            }
//            
//            for (_, subJson): (String, JSON) in json["discount"]{
//                var coupon_id = subJson["coupon_id"].int!
//                let coupon_name = subJson["name"].string ?? ""
//                let coupon_description = subJson["description"].string ?? ""
//                let coupon_limit = "pasado mañana"
//                let coupon_exp = subJson["end_date"].string ?? ""
//                let latitude = 0.0//subJson["latitude"].double!
//                let longitude = 0.0//subJson["longitude"].double!
//                
//                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: self.logoString, branch_id: self.branchId,company_id: 1,total_likes: 0 ,user_like: 0, latitude: latitude, longitude: longitude, banner: "", category_id: 1)
//                
//                self.coupons.append(model)
//            }
//            
//            for (_, subJson): (String, JSON) in json["new_promo"]{
//                var coupon_id = subJson["coupon_id"].int!
//                let coupon_name = subJson["name"].string ?? ""
//                let coupon_description = subJson["description"].string ?? ""
//                let coupon_limit = "pasado mañana"
//                let coupon_exp = subJson["end_date"].string ?? ""
//                let latitude = 0.0//subJson["latitude"].double!
//                let longitude = 0.0//subJson["longitude"].double!
//                
//                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: self.logoString, branch_id: self.branchId, company_id: 1, total_likes: 0 ,user_like: 0, latitude: latitude, longitude: longitude, banner: "", category_id: 1)
//                
//                self.coupons.append(model)
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                self.tableView.reloadData()
//            })
//
//        })
//    }
//    
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch self.selectedIndex {
//        case 0:
//            return 1
//        case 1:
//            return self.coupons.count
//        default:
//            return 1
//        }
//    }
//    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 285
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let defaultCell: UITableViewCell = UITableViewCell()
//        switch self.selectedIndex {
//        case 0:
//            tableView.estimatedRowHeight = 500
//            tableView.rowHeight = UITableViewAutomaticDimension
//
//            let cell: BranchProfileAboutView = tableView.dequeueReusableCellWithIdentifier("BranchProfileAboutView", forIndexPath: indexPath) as! BranchProfileAboutView
//        
//            cell.loadAbout("Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. ")
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            if self.branchPin != nil {
//                cell.branchLocationMap.addAnnotation(dropPin)
//                cell.centerMapOnLocation(self.branchPin)
//            }
//            return cell
//            
//        case 1:
//            let cellCampaign: BranchProfileLastCampaign = tableView.dequeueReusableCellWithIdentifier("BranchProfileLastCampaign", forIndexPath: indexPath) as! BranchProfileLastCampaign
//            tableView.estimatedRowHeight = 150
//            tableView.rowHeight = UITableViewAutomaticDimension
//            return cellCampaign
//        
//        case 2:
//            var cell: BranchProfileAboutView = tableView.dequeueReusableCellWithIdentifier("BranchProfileAboutView", forIndexPath: indexPath) as! BranchProfileAboutView
//            
//        default:
//            return defaultCell
//        }
//        return defaultCell
//    }
//    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        headerTopView.branchProfileSegmented?.addTarget(self, action: "setTableViewAtIndex", forControlEvents: .ValueChanged)
//        return headerTopView
//    }
//    
//    func setTableViewAtIndex() {
//        self.selectedIndex = headerTopView.branchProfileSegmented.selectedIndex
//        switch headerTopView.branchProfileSegmented.selectedIndex {
//        case 0:
//            tableView.reloadData()
//        case 1:
//            getBranchCouponTimeline()
////        case 2:
////            tableView.reloadData()
//        default:
//            tableView.reloadData()
//        }
////        tableView.reloadData()
//    }
//    
//}