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
    
    init(id: Int!, name: String!, description: String!, limit: String!, exp: String!, logo: String! ,branch_id:Int!) {
        self.id = id
        self.name = name ?? ""
        self.couponDescription = description ?? ""
        self.limit = limit ?? ""
        self.exp = exp ?? ""
        self.logo = logo ?? ""
        self.branch_id = branch_id
    }
}