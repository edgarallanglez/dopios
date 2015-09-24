//
//  BranchProfileTopView.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/6/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BranchProfileTopView: UIView {
    
    @IBOutlet weak var branchCover: UIImageView!
    @IBOutlet weak var branchName: UILabel!
    @IBOutlet weak var branchLogo: UIImageView!
    @IBOutlet weak var branchProfileSegmented: SegmentedControl!
    var branchId:Int!
    @IBAction func followBranch(sender: AnyObject) {
        
        let params:[String: AnyObject] = [
            "branch_id" : String(stringInterpolationSegment: branchId),
            "date" : "2015-01-01"]
        
        print(params)
        BranchProfileController.followBranchWithSuccess(params,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: couponsData)
                    print(json)
                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    print(error)
                })
        })

    }
}
