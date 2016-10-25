//
//  MapPinCallout.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 10/02/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class MapPinCallout: UIView {
    
    var branch_image: UIImageView = UIImageView()
    var name_label: UILabel?
    var address_label: UILabel?
    var info_label: UILabel?
    var button: UIButton?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convert(point, to: self) ?? point
        
        _ = self.point(inside: viewPoint, with: event)
        
        let view = super.hitTest(viewPoint, with: event)

        return view
    }
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.frame = CGRect(x: -130, y: -72, width: 330, height: 64)
        
        Utilities.applySolidShadow(self)

        let triangle: TriangeView = TriangeView(frame: CGRect(x: 132, y: 60, width: 28, height: 9))
        triangle.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.white
        self.addSubview(triangle)

        
        let inset = (self.frame.size.height - 30)/2
        
        button = UIButton(frame: CGRect(x: self.frame.width-30, y: 0, width: 30, height: self.frame.height))
        button!.setImage(UIImage(named:"arrow-right"), for: UIControlState())
        button?.imageEdgeInsets = UIEdgeInsets(top: inset , left: 0, bottom: inset, right: 0)
        button?.tintColor = Utilities.dopColor
        button!.backgroundColor = UIColor.white
        
        branch_image = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height))
        
        branch_image.contentMode = .scaleAspectFill
        branch_image.layer.masksToBounds = true
        self.addSubview(branch_image)
        
        name_label = UILabel(frame: CGRect(x: self.frame.height+15, y: 5, width: self.frame.width-self.frame.height-45,height: 20))
        name_label!.font = UIFont(name: "Montserrat-Regular", size: 16.0)
        name_label?.textColor = UIColor.darkGray
        self.addSubview(name_label!)
        
        address_label = UILabel(frame: CGRect(x: self.frame.height+15, y: 21, width: self.frame.width-self.frame.height-45,height: 20))
        address_label!.font = UIFont(name: "Montserrat-Light", size: 14.0)
        address_label?.textColor = UIColor.darkGray
        self.addSubview(address_label!)
        
        info_label = UILabel(frame: CGRect(x: self.frame.height+15, y: 40, width: self.frame.width-self.frame.height-45,height: 20))
        info_label!.font = UIFont(name: "Montserrat-Regular", size: 10.0)
        info_label?.textColor = UIColor.darkGray
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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        return bounds.contains(point)
    }
    override func removeFromSuperview() {
        Utilities.fadeOutToBottomWithCompletion(self, delay: 0, duration: 0.5, yPosition: 5, completion: {(result: Bool)in
                self.frame.origin.y = -72
                super.removeFromSuperview()
            })
    }
}
