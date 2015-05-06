//
//  DashboardViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    @IBOutlet weak var menuButton:UIBarButtonItem!

    var coupons = [Coupon]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func getCoupons(){
        coupons = [Coupon]()
        
        CouponController.getAllCouponsWithSuccess { (couponsData) -> Void in
            let json = JSON(data: couponsData)
            
            for (index: String, subJson: JSON) in json{
                
                let coupon_name = String(stringInterpolationSegment: subJson["name"])
                let coupon_limit = String(stringInterpolationSegment: subJson["limit"])
                let coupon_exp = String(stringInterpolationSegment: subJson["end_date"])
                let modelo = Coupon(name: coupon_name,limit: coupon_limit,exp: coupon_exp)

                self.coupons.append(modelo)

                println(coupon_name)
            }



        }
    


    }
    override func viewDidAppear(animated: Bool) {
        getCoupons()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
