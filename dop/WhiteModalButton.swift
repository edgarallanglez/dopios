//
//  WhiteModalButton.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/11/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import UIKit

class WhiteModalButton: UIButton {
    var background:CAGradientLayer!
    var background_selected:CAGradientLayer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func layoutIfNeeded() {
        background = Utilities.WhiteLayer
        background.frame = self.bounds
        
        background_selected = Utilities.DefaultSelectedLayer
        background_selected.frame = self.bounds
        
        self.layer.insertSublayer(background, at: 0)
    }
    
    override var isSelected: Bool {
        willSet(newValue) {
            if isSelected {
                self.layer.insertSublayer(background_selected, at: 0)
            } else {
                self.layer.insertSublayer(background, at: 0)
            }
            print("changing from \(isSelected) to \(newValue)")
        }
        
        didSet {
            background.removeFromSuperlayer()
            background_selected.removeFromSuperlayer()
            
            if isSelected {
                self.layer.insertSublayer(background_selected, at: 0)
            } else {
                self.layer.insertSublayer(background, at: 0)
            }
            
            print("selected=\(isSelected)")
        }
    }
}
