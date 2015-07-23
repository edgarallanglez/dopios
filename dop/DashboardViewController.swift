//
//  DashboardViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet var couponsTableView: UITableView!
    
    var locValue:CLLocationCoordinate2D?

    var coupons = [Coupon]()
    
    var cachedImages: [String: UIImage] = [:]

    var locationManager: CLLocationManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        var nib = UINib(nibName: "CouponCell", bundle: nil)
        couponsTableView.registerNib(nib, forCellReuseIdentifier: "CouponCell")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getCoupons() {
        coupons = [Coupon]()
        
        CouponController.getAllCouponsWithSuccess { (couponsData) -> Void in
            let json = JSON(data: couponsData)
            
            var namex = "";
            for (index: String, subJson: JSON) in json["data"]{
                var coupon_id = String(stringInterpolationSegment:subJson["coupon_id"]).toInt()
                let coupon_name = String(stringInterpolationSegment: subJson["name"])
                let coupon_description = String(stringInterpolationSegment: subJson["description"])
                let coupon_limit = String(stringInterpolationSegment: subJson["limit"])
                let coupon_exp = String(stringInterpolationSegment: subJson["end_date"])
                let coupon_logo = String(stringInterpolationSegment: subJson["logo"])
                let branch_id = String(stringInterpolationSegment: subJson["branch_id"]).toInt()

                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id:branch_id)

                self.coupons.append(model)

                println(coupon_name)
                namex = String(coupon_name)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.couponsTableView.reloadData()
            });
            

        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        getCoupons()
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
//
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view:UIView = UIView()
        view.backgroundColor = UIColor.clearColor()
        
        return view
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.contentView.backgroundColor = UIColor.clearColor()
//        
//        var whiteRoundedCornerView:UIView!
//        whiteRoundedCornerView = UIView(frame: CGRectMake(5, 10, self.view.bounds.width-10, 100))
//        whiteRoundedCornerView.backgroundColor = UIColor(red: 174/255.0, green: 174/255.0, blue: 174/255.0, alpha: 1.0)
//        whiteRoundedCornerView.layer.masksToBounds = false
//        
//        whiteRoundedCornerView.layer.shadowOpacity = 1.55;
//        
//        
//        
//        whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(1, 0);
//        whiteRoundedCornerView.layer.shadowColor=UIColor(red: 53/255.0, green: 143/255.0, blue: 185/255.0, alpha: 1.0).CGColor
//        
//        
//        
//        whiteRoundedCornerView.layer.cornerRadius=3.0
//        whiteRoundedCornerView.layer.shadowOffset=CGSizeMake(-1, -1)
//        whiteRoundedCornerView.layer.shadowOpacity=0.5
//        cell.contentView.addSubview(whiteRoundedCornerView)
//        cell.contentView.sendSubviewToBack(whiteRoundedCornerView)
//        
//        
//    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        var cell: CouponCell = tableView.dequeueReusableCellWithIdentifier("CouponCell", forIndexPath: indexPath) as! CouponCell
        
        let model = self.coupons[indexPath.section]
        
        
        cell.loadItem(model, viewController: self)
        
        let imageUrl = NSURL(string: "http://104.236.141.44/branches/images/\(model.branch_id)/\(model.logo)")
        
        
        let identifier = "Cell\(indexPath.section)"
        
        println(identifier)
        if(self.cachedImages[identifier] != nil){
            let cell_image_saved : UIImage = self.cachedImages[identifier]!

            cell.branchImage.setBackgroundImage(cell_image_saved, forState: UIControlState.Normal)
        } else{
            cell.branchImage.alpha = 0

            Utilities.getDataFromUrl(imageUrl!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    println("Finished downloading \"\(imageUrl!.lastPathComponent!.stringByDeletingPathExtension)\".")
                
                    var cell_image : UIImage = UIImage()
                    cell_image = UIImage ( data: data!)!

                    if tableView.indexPathForCell(cell)?.section == indexPath.section{
                        self.cachedImages[identifier] = cell_image
                        
                        let cell_image_saved : UIImage = self.cachedImages[identifier]!

                        cell.branchImage.setBackgroundImage(cell_image_saved, forState: UIControlState.Normal)
                        
                        UIView.animateWithDuration(0.5, animations: {
                            cell.branchImage.alpha = 1
                        })
                   
                    }
               
                    
                }
            }
        }

        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        let currentCoupon = self.coupons[indexPath.row]
        
        var useAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Usar" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let useMenu = UIAlertController(title: nil, message: "Usar cupón", preferredStyle: .ActionSheet)
            
            let acceptAction = UIAlertAction(title: "Usar", style: UIAlertActionStyle.Default, handler: {
                    UIAlertAction in
                    self.takeCoupon(currentCoupon.id)
                })
            let cancelAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil)
            
            useMenu.addAction(acceptAction)
            useMenu.addAction(cancelAction)
            
            
            self.presentViewController(useMenu, animated: true, completion: nil)
        })
        var shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Compartir" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let shareMenu = UIAlertController(title: nil, message: "Compartir cupón", preferredStyle: .ActionSheet)
            
            let acceptAction = UIAlertAction(title: "Compartir", style: UIAlertActionStyle.Default, handler: {
                    UIAlertAction in
                    //self.takeCoupon(currentCoupon.id)
                })
            let cancelAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil)
            
            shareMenu.addAction(acceptAction)
            shareMenu.addAction(cancelAction)
            
            
            self.presentViewController(shareMenu, animated: true, completion: nil)
        })
        
        useAction.backgroundColor = UIColor(red: 203/255, green: 76/255, blue: 76/255, alpha: 1)

        return [useAction,shareAction]
    }
    
    func takeCoupon(coupon_id:Int) {
        
        var latitude = String(stringInterpolationSegment:locValue!.latitude)
        var longitude = String(stringInterpolationSegment: locValue!.longitude)

        let params:[String: AnyObject] = [
            "coupon_id" : coupon_id,
            "taken_date" : "2015-01-01",
            "latitude" : latitude,
            "longitude" : longitude]
        


        CouponController.takeCouponWithSuccess(params){(couponsData) -> Void in
            let json = JSON(data: couponsData)

            println(json)
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locValue = manager.location.coordinate

        println("locations = \(locValue!.latitude)")
        locationManager.stopUpdatingLocation()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? CouponCell {
            
            let i = couponsTableView.indexPathForCell(cell)!.section
            let model = self.coupons[i]
            
            if segue.identifier == "branchProfile" {
                let view = segue.destinationViewController as! BranchProfileViewController
                view.branchId = model.branch_id
                view.logo = cell.branchImage.currentBackgroundImage
                view.logoString = model.logo
                
            }
        }
        
    }

}
