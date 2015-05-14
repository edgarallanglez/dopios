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
    let limit:String
    let exp: String
    
    init(id:Int!,name: String!, limit: String!, exp: String! ) {
        self.id=id
        self.name = name ?? ""
        self.limit = limit ?? ""
        self.exp = exp ?? ""
    }
}