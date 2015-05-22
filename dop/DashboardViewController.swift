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
    
    let simpleTableIdentifier = "CouponCell";

    var coupons = [Coupon]()

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
                let coupon_limit = String(stringInterpolationSegment: subJson["limit"])
                let coupon_exp = String(stringInterpolationSegment: subJson["end_date"])
                let model = Coupon(id:coupon_id,name: coupon_name,limit: coupon_limit,exp: coupon_exp)

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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        
        var cell:CouponCell = tableView.dequeueReusableCellWithIdentifier("CouponCell", forIndexPath: indexPath) as! CouponCell
        

        let model = self.coupons[indexPath.row]

        var (title) = model.name
        
        cell.loadItem(title: title)

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
        let params:[String: AnyObject] = [
            "coupon_id" : coupon_id,
            "taken_date" : "2015-01-01"]

        CouponController.takeCouponWithSuccess(params){(couponsData) -> Void in
            let json = JSON(data: couponsData)

            println(json)
        }
        
    }

}
