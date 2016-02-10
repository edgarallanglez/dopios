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
        class var reuseIdentifier:String {
            return "mapPin"
        }
        
        private var calloutView:MapPinCallout?
        private var hitOutside:Bool = true
        
        var preventDeselection:Bool {
            return !hitOutside
        }
        
        
        convenience init(annotation:MKAnnotation!) {
            self.init(annotation: annotation, reuseIdentifier: MapPin.reuseIdentifier)
            
            canShowCallout = false;
        }
        
        override func setSelected(selected: Bool, animated: Bool) {
            let calloutViewAdded = calloutView?.superview != nil
            
            if (selected || !selected && hitOutside) {
                super.setSelected(selected, animated: animated)
            }
            
            self.superview?.bringSubviewToFront(self)
            
            if (calloutView == nil) {
                calloutView = MapPinCallout()
            }
            
            if (self.selected && !calloutViewAdded) {
                addSubview(calloutView!)
            }
            
            if (!self.selected) {
                calloutView?.removeFromSuperview()
            }
        }
        
        override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
            var hitView = super.hitTest(point, withEvent: event)
            
            if let callout = calloutView {
                if (hitView == nil && self.selected) {
                    hitView = callout.hitTest(point, withEvent: event)
                }
            }
            
            hitOutside = hitView == nil
            
            return hitView;
        }
}


