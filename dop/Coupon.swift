//
//  Coupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 06/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class Coupon:NSObject,Printable{
    let id:Int
    let name:String
    let couponDescription:String
    let limit:String
    let exp: String
    let logo: String
    let branch_id:Int
    let company_id: Int
    var total_likes: Int
    var user_like: Int

    init(id: Int!, name: String!, description: String!, limit: String!, exp: String!, logo: String! ,branch_id:Int!, company_id: Int!, total_likes: Int!, user_like:Int!) {
        self.id = id
        self.name = name ?? ""
        self.couponDescription = description ?? ""
        self.limit = limit ?? ""
        self.exp = exp ?? ""
        self.logo = logo ?? ""
        self.branch_id = branch_id
        self.company_id = company_id
        self.total_likes = total_likes
        self.user_like = user_like
    }
    
    func setUserLike(user_like: Int!,total_likes: Int!){
        self.user_like = user_like
        self.total_likes = total_likes
    }
}