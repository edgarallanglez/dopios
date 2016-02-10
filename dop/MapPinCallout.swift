//
//  MapPinCallout.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 10/02/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class MapPinCallout: UIView {

    override func hitTest(var point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        
        let isInsideView = pointInside(viewPoint, withEvent: event)
        
        var view = super.hitTest(viewPoint, withEvent: event)
        
        return view
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGRectContainsPoint(bounds, point)
    }

}
