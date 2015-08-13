//
//  NewsfeedNote.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NewsfeedNote: NSObject {
    let friend_id:String
    let user_id: Int
    let branch_id: Int
    let coupon_name: String
    let branch_name: String
    let names: String
    let surnames: String
    let user_image: String
    let branch_image: String
    
    init(friend_id:String!, user_id:Int!, branch_id:Int!, coupon_name: String!, branch_name: String!, names: String!, surnames: String!, user_image: String!, branch_image: String! ) {
        self.friend_id = friend_id ?? ""
        self.user_id = user_id ?? 0
        self.branch_id = branch_id ?? 0
        self.coupon_name = coupon_name ?? ""
        self.branch_name = branch_name ?? ""
        self.names = names ?? ""
        self.surnames = surnames ?? ""
        self.user_image = user_image ?? ""
        self.branch_image = branch_image ?? ""
    }
}
