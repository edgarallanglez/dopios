//
//  Coupon.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 06/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class Coupon:NSObject {
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
    let location: CLLocationCoordinate2D
    let banner: String
    let categoryId: Int

    init(id: Int?, name: String?, description: String?, limit: String?, exp: String?, logo: String? ,branch_id:Int?, company_id: Int?, total_likes: Int?, user_like: Int?, latitude: Double, longitude: Double, banner: String, category_id: Int) {
        self.id = id ?? 0
        self.name = name ?? ""
        self.couponDescription = description ?? ""
        self.limit = limit ?? ""
        self.exp = exp ?? ""
        self.logo = logo ?? ""
        self.branch_id = branch_id ?? 0
        self.company_id = company_id ?? 0
        self.total_likes = total_likes ?? 0
        self.user_like = user_like ?? 0
        self.location = CLLocationCoordinate2DMake(latitude, longitude) ?? CLLocationCoordinate2DMake(0.0, 0.0)
        self.banner = banner
        self.categoryId = category_id
    }
    
    func setUserLike(user_like: Int!,total_likes: Int!){
        self.user_like = user_like
        self.total_likes = total_likes
    }
}