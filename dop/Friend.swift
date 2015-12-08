//
//  Friends.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class Friend: NSObject {
    let friend_id: Int
    let user_id:Int
    let names:String
    let surnames:String
    let main_image: String
    let friend: Bool
    let birth_date: String
    let privacy_status: Int
    let facebook_key: String
    
    init(friend_id: Int!, user_id: Int!,names: String!, surnames: String!, main_image: String!, friend: Bool, birth_date: String!, privacy_status: Int!, facebook_key: String!) {
        self.friend_id = friend_id ?? 0
        self.user_id = user_id
        self.names = names ?? ""
        self.surnames = surnames ?? ""
        self.main_image = main_image ?? ""
        self.friend = friend
        self.birth_date = birth_date ?? ""
        self.privacy_status = privacy_status ?? 0
        self.facebook_key = facebook_key
    }
}
