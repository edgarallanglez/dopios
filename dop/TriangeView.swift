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
    
    override func drawRect(rect: CGRect) {
        
        let ctx : CGContextRef = UIGraphicsGetCurrentContext()!

        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect)/2.0, CGRectGetMaxY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextClosePath(ctx)

        
        
        CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
        CGContextFillPath(ctx);
    }
}