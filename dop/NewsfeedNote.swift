//
//  NewsfeedNote.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NewsfeedNote: NSObject {
    let client_coupon_id: Int
    let friend_id:String
    let user_id: Int
    let branch_id: Int
    let coupon_name: String
    let branch_name: String
    let names: String
    let surnames: String
    let user_image: String
    let company_id: Int
    let branch_image: String
    var total_likes: Int
    var user_like: Bool
    var date: String
    var formatedDate: String
    var private_activity: Bool
    
    init(client_coupon_id: Int!,friend_id:String!, user_id:Int!, branch_id:Int!, coupon_name: String!,
         branch_name: String!, names: String!, surnames: String!, user_image: String!, company_id: Int!,
         branch_image: String!, total_likes:Int!,user_like:Bool!, date:String!, formatedDate:String!, private_activity: Bool ) {
        self.client_coupon_id = client_coupon_id ?? 0
        self.friend_id = friend_id ?? ""
        self.user_id = user_id ?? 0
        self.branch_id = branch_id ?? 0
        self.coupon_name = coupon_name ?? ""
        self.branch_name = branch_name ?? ""
        self.names = names ?? ""
        self.surnames = surnames ?? ""
        self.user_image = user_image ?? ""
        self.company_id = company_id
        self.branch_image = branch_image ?? ""
        self.total_likes = total_likes ?? 0
        self.user_like = user_like ?? false
        self.date = date ?? ""
        self.formatedDate = formatedDate ?? ""
        self.private_activity = private_activity ?? false
    }
    
    func setUserLike(_ user_like: Bool!,total_likes: Int!){
        self.user_like = user_like
        self.total_likes = total_likes
    }
}
