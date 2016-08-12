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
    
    init(branch_id: Int, name: String, company_id: Int, banner: String?, logo: String?, branch_follower_id: Int){
        self.branch_id = branch_id
        self.name = name
        self.company_id = company_id
        self.banner = banner
        self.logo = logo
        self.branch_follower_id = branch_follower_id
    }
    
}