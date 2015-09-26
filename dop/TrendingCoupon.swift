//
//  TrendingCoupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 23/09/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TrendingCoupon: UIView {
    
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var logo: UIImageView!
    init(height:Int) {
        print("AHLO")
        
        
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: height))
        
        
        //self.addSubview(self.view)
        

        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func move(x:CGFloat){
        self.frame.origin = CGPointMake(x, 0)
    }
    
}

