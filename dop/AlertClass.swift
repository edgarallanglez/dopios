//
//  AlertClass.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import UIKit

class AlertClass: UIView {
    
    func launchAlert() -> UIAlertController {
        return UIAlertController(title: "REWARD", message: "Eres un gran PERRAZO y por ello te felicitamos.", preferredStyle: UIAlertControllerStyle.Alert)
        
    }
}
