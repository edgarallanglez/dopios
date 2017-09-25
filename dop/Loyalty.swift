//
//  Loyalty.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/7/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import Foundation

class Loyalty: NSObject {
    let loyalty_id: Int!
    let owner_id: Int!
    let company_id: Int!
    let name: String!
    let about: String?
    let type: String!
    let goal: Double!
    let is_global: Bool?
    let end_date: String?
    let logo: String?
    var visit: Double!
    var logo_image: UIImage?
    
    init(model: JSON) {
        self.loyalty_id = model["loyalty_id"].int!
        self.owner_id = model["owner_id"].int!
        self.company_id = model["company_id"].int!
        self.name = model["name"].string!
        self.about = model["description"].string!
        self.type = model["type"].string!
        self.goal = model["goal"].double!
        self.is_global = model["is_global"].bool!
        self.end_date = model["end_date"].string!
        self.logo = model["logo"].string ?? ""
        self.visit = model["visit"].double ?? 0.0
        
        self.logo_image = nil
    }
}
