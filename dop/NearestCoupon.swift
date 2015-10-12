//
//  Nearest.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 08/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NearestCoupon: UIView {

    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var branchNameLbl: UILabel!
    
    init(height:Int) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 230))
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func move(x:CGFloat,y:CGFloat){
        self.frame.origin = CGPointMake(x,y)
    }


}
