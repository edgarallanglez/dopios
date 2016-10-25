//
//  MapAnnotation.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 09/02/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit

class MapPin: MKAnnotationView {
        var name: String = ""
        var address: String = ""
        var info: String = ""
        var logo: String = ""
    
        class var reuseIdentifier:String {
            return "custom"
        }
    
        class var name:String {
            return "custom"
        }
        var calloutView:MapPinCallout?
        fileprivate var hitOutside:Bool = true
        
        var preventDeselection:Bool {
            return !hitOutside
        }
        
        
        convenience init(annotation:MKAnnotation!) {
            self.init(annotation: annotation, reuseIdentifier: MapPin.reuseIdentifier)
            

            canShowCallout = false;
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            let calloutViewAdded = calloutView?.superview != nil
            
            if (selected || !selected && hitOutside) {
                super.setSelected(selected, animated: animated)
            }
            
            self.superview?.bringSubview(toFront: self)
            
            if (calloutView == nil) {
                calloutView = MapPinCallout(name: self.name, address: "", info: "", logo: "")
            }
            
            if (self.isSelected && !calloutViewAdded) {
                addSubview(calloutView!)
                Utilities.fadeInFromBottomAnimation(calloutView!, delay: 0, duration: 0.5, yPosition: 10)

            }
            
            if (!self.isSelected) {
                calloutView?.removeFromSuperview()
            }
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            var hitView = super.hitTest(point, with: event)
            
            if let callout = calloutView {
                if (hitView == nil && self.isSelected ) {
                    hitView = callout.hitTest(point, with: event)
                }
            }
            
            hitOutside = hitView == nil
            
            return hitView;
        }
}


