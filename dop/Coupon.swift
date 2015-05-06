//
//  Coupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 06/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class Coupon:NSObject,Printable{
    let name:String
    let limit:String
    let exp: String
    
    init(name: String?, limit: String?, exp: String? ) {
        self.name = name ?? ""
        self.limit = limit ?? ""
        self.exp = exp ?? ""
    }
}