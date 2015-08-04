//
//  CouponDetailViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class CouponDetailViewController: UIViewController {

    @IBOutlet var branch_logo: UIImageView!
    @IBOutlet var branch_cover: UIImageView!
    @IBOutlet var branch_name: UILabel!
    @IBOutlet var branch_category: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        branch_logo.layer.borderColor = UIColor.whiteColor().CGColor
        
        branch_name.layer.shadowOffset = CGSize(width: 1, height: 3)
        branch_name.layer.shadowOpacity = 1
        branch_name.layer.shadowRadius = 3
        branch_name.layer.shadowColor = UIColor.blackColor().CGColor
        
        branch_category.layer.shadowOffset = CGSize(width: 1, height: 3)
        branch_category.layer.shadowOpacity = 1
        branch_category.layer.shadowRadius = 3
        branch_category.layer.shadowColor = UIColor.blackColor().CGColor
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
