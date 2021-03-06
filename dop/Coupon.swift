//
//  Coupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 06/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class Coupon: NSObject {
    let id: Int
    let name: String
    let coupon_description: String
    let limit: String
    let exp: String
    let logo: String
    let branch_id: Int
    let company_id: Int
    var total_likes: Int
    var user_like: Bool
    let location: CLLocationCoordinate2D
    let banner: String
    var category_id: Int = 2
    var available: Int
    var taken: Bool!
    var end_date: String!
    var taken_date: String!
    var start_date: String!
    var adult_branch: Bool?
    var distance: Double?
    var branch_folio: String!
    var is_global: Bool

    init(id: Int?, name: String?, description: String?, limit: String?, exp: String?, logo: String? ,branch_id:Int?, company_id: Int?, total_likes: Int?, user_like: Bool?, latitude: Double, longitude: Double, banner: String, category_id: Int, available: Int, taken: Bool, adult_branch: Bool, branch_folio: String, is_global: Bool) {
        
        self.id = id ?? 0
        self.name = name ?? ""
        self.coupon_description = description ?? ""
        self.limit = limit ?? ""
        self.exp = exp ?? ""
        self.logo = logo ?? ""
        self.branch_id = branch_id ?? 0
        self.company_id = company_id ?? 0
        self.total_likes = total_likes ?? 0
        self.user_like = user_like ?? false
        self.location = CLLocationCoordinate2DMake(latitude, longitude) 
        self.banner = banner
        self.category_id = category_id
        self.available = available
        self.taken = taken
        self.adult_branch = adult_branch ?? false
        self.branch_folio = branch_folio
        self.is_global = is_global
        
    }
    init(id: Int?, name: String?, description: String?, limit: String?, exp: String?, logo: String? ,branch_id:Int?, company_id: Int?, total_likes: Int?, user_like: Bool?, latitude: Double, longitude: Double, banner: String, category_id: Int, available: Int, taken: Bool, start_date: String, branch_folio: String, is_global: Bool) {
        
        self.id = id ?? 0
        self.name = name ?? ""
        self.coupon_description = description ?? ""
        self.limit = limit ?? ""
        self.exp = exp ?? ""
        self.logo = logo ?? ""
        self.branch_id = branch_id ?? 0
        self.company_id = company_id ?? 0
        self.total_likes = total_likes ?? 0
        self.user_like = user_like ?? false
        self.location = CLLocationCoordinate2DMake(latitude, longitude) 
        self.banner = banner
        self.category_id = category_id
        self.available = available
        self.taken = taken
        self.start_date = start_date
        self.branch_folio = branch_folio
        self.is_global = is_global
        
        self.adult_branch = false
    }
    
    init(id: Int?, name: String?, description: String?, limit: String?, exp: String?, logo: String? ,branch_id:Int?, company_id: Int?, total_likes: Int?, user_like: Bool?, latitude: Double, longitude: Double, banner: String, category_id: Int, available: Int, taken: Bool, taken_date: String, branch_folio: String, is_global: Bool){
        
        self.id = id ?? 0
        self.name = name ?? ""
        self.coupon_description = description ?? ""
        self.limit = limit ?? ""
        self.exp = exp ?? ""
        self.logo = logo ?? ""
        self.branch_id = branch_id ?? 0
        self.company_id = company_id ?? 0
        self.total_likes = total_likes ?? 0
        self.user_like = user_like ?? false
        self.location = CLLocationCoordinate2DMake(latitude, longitude) 
        self.banner = banner
        self.category_id = category_id
        self.available = available
        self.taken = taken
        self.taken_date = taken_date
        self.branch_folio = branch_folio
        self.is_global = is_global
        
        self.adult_branch = false
    }
    
    init(model: JSON) {
        self.id = model["coupon_id"].int!
        self.name = model["name"].string ?? ""
        self.coupon_description = model["description"].string ?? ""
        self.limit = model["limit"].string ?? ""
        self.exp = "2017-09-30"
        self.logo = model["logo"].string ?? ""
        self.company_id = model["company_id"].int!
        self.total_likes = model["total_likes"].int ?? 0
        self.user_like = model["user_like"].bool ?? false
        self.location = CLLocationCoordinate2DMake(model["latitude"].double!, model["longitude"].double!)
        self.banner = model["banner"].string ?? ""
        self.category_id = model["category_id"].int!
        self.available = model["available"].int!
        self.taken = model["taken"].bool!
        self.start_date = model["start_date"].string ?? ""
        self.branch_folio = model["folio"].string!
        self.branch_id = model["branch_id"].int!
        self.is_global = model["is_global"].bool!
        
        self.adult_branch = false
    }
    
    func setUserLike(_ user_like: Bool!,total_likes: Int!){
        self.user_like = user_like
        self.total_likes = total_likes
    }
    
    func setTakenCoupons(_ user_take: Bool!, available: Int!){
        self.taken = user_take
        self.available = available
    }

}
