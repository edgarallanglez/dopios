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

        
        self.layer.insertSublayer(background, atIndex: 0)
    }
    
    override var selected: Bool {
        
        willSet(newValue) {
            if(selected){
                self.layer.insertSublayer(background_selected, atIndex: 0)
            }else{
                self.layer.insertSublayer(background, atIndex: 0)
            }
            print("changing from \(selected) to \(newValue)")
        }
        didSet {
            background.removeFromSuperlayer()
            background_selected.removeFromSuperlayer()
            if(selected){
                self.layer.insertSublayer(background_selected, atIndex: 0)
            }else{
                self.layer.insertSublayer(background, atIndex: 0)
            }
            print("selected=\(selected)")
        }
    }
}
