//
//  PeopleModel.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/20/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PeopleModel: NSObject {
    let names: String
    let surnames: String
    let user_id: Int
    let birth_date: String
    let facebook_key: String
    let privacy_status: Int
    let main_image: String
    
    init(names: String!, surnames: String!, user_id: Int!, birth_date: String?, facebook_key: String?, privacy_status: Int, main_image: String?) {
        
        self.names = names
        self.surnames = surnames
        self.user_id = user_id
        self.birth_date = birth_date ?? ""
        self.facebook_key = facebook_key ?? ""
        self.privacy_status = privacy_status
        self.main_image = main_image ?? ""
    }
}