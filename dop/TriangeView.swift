//
//  TriangleView.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 10/02/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import Foundation
import UIKit

class TriangeView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func draw(_ rect: CGRect) {
        
        let ctx : CGContext = UIGraphicsGetCurrentContext()!

        ctx.beginPath()
        ctx.move(to: CGPoint(x: rect.minX, y: rect.minY))
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        ctx.addLine(to: CGPoint(x: rect.maxX/2.0, y: rect.maxY))
        ctx.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        ctx.closePath()

        
        
        ctx.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
        ctx.fillPath();
    }
}
