//
//  ConnectionModel.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/31/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

struct ConnectionModel {
    let branch_id: Int
    let name: String
    let company_id: Int
    let banner: String?
    let logo: String?
    let branch_follower_id: Int
    
    init(model: JSON){
        self.name = model["name"].string!
        self.company_id = model["company_id"].int ?? 0
        self.branch_id =  model["branch_id" ].int!
        self.logo =  model["logo"].string
        self.banner = model["banner"].string ?? ""
        self.branch_follower_id  = model["branch_follower_id"].int!
    }
    
}
