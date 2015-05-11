//
//  DashboardViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet var couponsTableView: UITableView!
    
    let simpleTableIdentifier = "CouponCell";

    var coupons = [Coupon]()

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
                
                let coupon_name = String(stringInterpolationSegment: subJson["name"])
                let coupon_limit = String(stringInterpolationSegment: subJson["limit"])
                let coupon_exp = String(stringInterpolationSegment: subJson["end_date"])
                let model = Coupon(name: coupon_name,limit: coupon_limit,exp: coupon_exp)

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
        
        /*let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomCell*/
        /*let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")*/
        
        
       
        //cell.expLbl.text = "asd"
        //cell.limitLbl.text = model.exp
        //cell!.nameLbl.text = "Hola"
        
        
        return cell
    }
}
