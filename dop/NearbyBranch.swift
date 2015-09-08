//
//  NearbyBranch.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 08/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NearbyBranch: NSObject {
    let id:Int
    let name:String
    let distance:String
    
    
    init(id: Int?, name: String?, distance: Double?) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.distance = String(stringInterpolationSegment: distance) ?? ""
    }
    
}
