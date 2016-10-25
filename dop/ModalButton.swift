//
//  ModalButton.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 24/12/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class ModalButton: UIButton {
    var background:CAGradientLayer!
    var background_selected:CAGradientLayer!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    override func layoutIfNeeded() {
        background = Utilities.Colors
        background.frame = self.bounds
        
        background_selected = Utilities.DarkColors
        background_selected.frame = self.bounds

        
        self.layer.insertSublayer(background, at: 0)
    }
    
    override var isSelected: Bool {
        
        willSet(newValue) {
            if(isSelected){
                self.layer.insertSublayer(background_selected, at: 0)
            }else{
                self.layer.insertSublayer(background, at: 0)
            }
            print("changing from \(isSelected) to \(newValue)")
        }
        didSet {
            background.removeFromSuperlayer()
            background_selected.removeFromSuperlayer()
            if(isSelected){
                self.layer.insertSublayer(background_selected, at: 0)
            }else{
                self.layer.insertSublayer(background, at: 0)
            }
            print("selected=\(isSelected)")
        }
    }
}
