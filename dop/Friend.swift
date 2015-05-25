//
//  Friends.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class Friend: NSObject {
    let id:Int
    let names:String
    let surnames:String
    let main_image: String
    
    init(id:Int!,names: String!, surnames: String!, main_image: String! ) {
        self.id=id
        self.names = names ?? ""
        self.surnames = surnames ?? ""
        self.main_image = main_image ?? ""
    }
}
