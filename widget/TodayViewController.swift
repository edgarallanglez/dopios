//
//  TodayViewController.swift
//  widget
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    var branches = [WidgetBranch]()
    
    @IBOutlet var coupon_box: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 270)
        
    
        
        
        getTopBranches()
    }
    func getTopBranches() {
        TodayController.getDashboardBranchesWithSuccess { (branchesData) -> Void in
            let json = JSON(data: branchesData)
            
            for (_, subJson): (String, JSON) in json["data"] {
                let branch_id = subJson["branch_id"].int
                let branch_name = subJson["name"].string
                let company_id = subJson["company_id"].int
                let banner = subJson["banner"].string
                
                
                let model = WidgetBranch(id: branch_id, name: branch_name, logo: "", banner: banner,company_id: company_id, total_likes: 0, user_like: 0)
                
                
                self.branches.append(model)
                
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                print(json)
                let imageUrl = NSURL(string: "\(WidgetUtilities.dopImagesURL)\(self.branches[0].company_id)/\(self.branches[0].banner)")!
                self.coupon_box.alpha = 0

                WidgetUtilities.getDataFromUrl(imageUrl) { photo in
                    dispatch_async(dispatch_get_main_queue()) {
                        let imageData: NSData = NSData(data: photo!)
                        self.coupon_box.image = UIImage(data: imageData)
                        UIView.animateWithDuration(0.5, animations: {
                            self.coupon_box.alpha = 1
                        })
                        
                    }
                }
                
            });
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
