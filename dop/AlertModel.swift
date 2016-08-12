//
//  AlertClass.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import UIKit

class AlertModel: NSObject {
    let alert_title: String!
    let alert_subtitle: String?
    let alert_image: String!
    let alert_description: String!
    
    init(alert_title: String!, alert_subtitle: String?, alert_image: String!, alert_description: String!) {
        self.alert_title = alert_title
        self.alert_subtitle = alert_subtitle
        self.alert_image = alert_image
        self.alert_description = alert_description
    }
    
    init(alert_title: String!, alert_image: String!, alert_description: String!) {
        self.alert_title = alert_title
        self.alert_image = alert_image
        self.alert_description = alert_description
        self.alert_subtitle = nil
    }
}
