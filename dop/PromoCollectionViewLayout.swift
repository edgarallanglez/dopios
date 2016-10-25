//
//  PromoCollectionViewLayout.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 11/03/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PromoCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        
        attribute?.transform = attribute!.transform.translatedBy(x: 0, y: 0)
        attribute?.transform = attribute!.transform.scaledBy(x: 0.5, y: 0.5)
        attribute?.alpha = 0.0
        
        return attribute
        
    }
}
