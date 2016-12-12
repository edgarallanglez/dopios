//
//  LoginTextView.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 08/12/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class LoginTextView: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12);
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

}
