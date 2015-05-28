//
//  Friends.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class Friend: NSObject {
    let friend_id:String
    let user_id:Int
    let names:String
    let surnames:String
    let main_image: String
    
    init(friend_id:String!, user_id:Int!,names: String!, surnames: String!, main_image: String! ) {
        self.friend_id = friend_id
        self.user_id = user_id
        self.names = names ?? ""
        self.surnames = surnames ?? ""
        self.main_image = main_image ?? ""
    }
}
