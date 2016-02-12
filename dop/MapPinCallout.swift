//
//  MapPinCallout.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 10/02/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class MapPinCallout: UIView {
    
    var branch_image = UIImageView?()
    var name_label: UILabel?
    var address_label: UILabel?
    var info_label: UILabel?
    var button: UIButton?

    override func hitTest(var point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        
        let isInsideView = pointInside(viewPoint, withEvent: event)
        
        var view = super.hitTest(viewPoint, withEvent: event)
        

        
        return view
    }
    override init (frame : CGRect) {
        super.init(frame : frame)

        
        self.frame = CGRectMake(-130, -72, 330, 64)
        
        Utilities.applySolidShadow(self)

        let triangle: TriangeView = TriangeView(frame: CGRectMake(132, 60, 28, 9))
        triangle.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.whiteColor()
        self.addSubview(triangle)

        
        
        button = UIButton(frame: CGRectMake(self.frame.width-30, 0, 30, self.frame.height))
        button!.backgroundColor = UIColor.redColor()
        //button!.addTarget(self, action: "goToBranchProfile:", forControlEvents: .TouchUpInside)
        
        
        branch_image = UIImageView(frame: CGRectMake(0, 0, self.frame.height, self.frame.height))
        

        branch_image?.contentMode = .ScaleAspectFill
        branch_image?.layer.masksToBounds = true
        self.addSubview(branch_image!)
        
        
        
        name_label = UILabel(frame: CGRectMake(self.frame.height+15, 5, self.frame.width-self.frame.height-45,20))
        name_label!.font = UIFont(name: "Montserrat-Regular", size: 16.0)
        name_label?.textColor = UIColor.darkGrayColor()
        self.addSubview(name_label!)
        
        address_label = UILabel(frame: CGRectMake(self.frame.height+15, 21, self.frame.width-self.frame.height-45,20))
        address_label!.font = UIFont(name: "Montserrat-Light", size: 14.0)
        address_label?.textColor = UIColor.darkGrayColor()
        self.addSubview(address_label!)
        
        info_label = UILabel(frame: CGRectMake(self.frame.height+15, 40, self.frame.width-self.frame.height-45,20))
        info_label!.font = UIFont(name: "Montserrat-Regular", size: 10.0)
        info_label?.textColor = UIColor.darkGrayColor()
        self.addSubview(info_label!)
        
        self.addSubview(button!)

    }
    
    convenience init (name: String, address: String, info: String, logo: String) {
        self.init(frame:CGRect.zero)
        
        name_label!.text = name
        address_label!.text = address
        info_label!.text = info
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        
        return CGRectContainsPoint(bounds, point)
    }
    override func removeFromSuperview() {
        Utilities.fadeOutToBottomWithRemoveAnimation(self, delay: 0, duration: 0.5, yPosition: 5, completion: {(result: Bool)in
                self.frame.origin.y = -72
                super.removeFromSuperview()
            })
    }
}
