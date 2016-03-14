//
//  PromoCollectionViewLayout.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 11/03/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PromoCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath)
        
        attribute?.transform = CGAffineTransformTranslate(attribute!.transform, 0, 0)
        attribute?.transform = CGAffineTransformScale(attribute!.transform, 0.5, 0.5)
        attribute?.alpha = 0.0
        
        return attribute
        
    }
}
