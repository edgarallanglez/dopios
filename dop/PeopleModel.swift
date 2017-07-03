//
//  PeopleModel.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/20/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PeopleModel: NSObject {
    let names: String
    let surnames: String
    let user_id: Int
    let birth_date: String?
    let facebook_key: String?
    let privacy_status: Int?
    let main_image: String
    var level: Int!
    var exp: Double!
    var is_friend: Bool?
    let total_used: Int?
    let friend_id: Int?
    var operation_id: Int?
    
    // simple people constructor
    init(names: String!, surnames: String!, user_id: Int!, birth_date: String?, facebook_key: String?, privacy_status: Int, main_image: String?, level: Int, exp: Double) {
        
        self.names = names
        self.surnames = surnames
        self.user_id = user_id
        self.birth_date = birth_date ?? ""
        self.facebook_key = facebook_key ?? ""
        self.privacy_status = privacy_status
        self.main_image = main_image ?? ""
        self.level = level
        self.exp = exp
        self.is_friend = nil
        self.total_used = nil
        self.friend_id = nil
        self.operation_id = nil
    }
    
    // friend people constructor
    init(names: String!, surnames: String!, user_id: Int!, birth_date: String?, facebook_key: String?, privacy_status: Int, main_image: String?, is_friend: Bool, level: Int, exp: Double, operation_id: Int!) {
        
        self.names = names
        self.surnames = surnames
        self.user_id = user_id
        self.birth_date = birth_date ?? ""
        self.facebook_key = facebook_key ?? ""
        self.privacy_status = privacy_status
        self.main_image = main_image ?? ""
        self.is_friend = is_friend
        self.level = level
        self.exp = exp
        self.total_used = nil
        self.friend_id = nil
        self.operation_id = operation_id

    }
    
    // ranked by used people constructor
    init(names: String!, surnames: String!, user_id: Int!, birth_date: String?, facebook_key: String?, privacy_status: Int, main_image: String?, total_used: Int, level: Int, exp: Double, is_friend: Bool! ,operation_id: Int!) {
        
        self.names = names
        self.surnames = surnames
        self.user_id = user_id
        self.birth_date = birth_date ?? ""
        self.facebook_key = facebook_key ?? ""
        self.privacy_status = privacy_status
        self.main_image = main_image ?? ""
        self.is_friend = is_friend
        self.total_used = total_used
        self.level = level
        self.exp = exp
        self.friend_id = nil
        self.operation_id = operation_id
    }
    
    init(friend_id: Int!, user_id: Int!,names: String!, surnames: String!, main_image: String!, is_friend: Bool, birth_date: String!, privacy_status: Int!, facebook_key: String!, level: Int, exp: Double, operation_id: Int!) {
        self.friend_id = friend_id ?? 0
        self.user_id = user_id
        self.names = names ?? ""
        self.surnames = surnames ?? ""
        self.main_image = main_image ?? ""
        self.is_friend = is_friend
        self.birth_date = birth_date ?? ""
        self.privacy_status = privacy_status ?? 0
        self.facebook_key = facebook_key
        self.level = level
        self.exp = exp
        self.total_used = nil
        self.operation_id = operation_id
    }
    
    init(model: JSON) {
        self.names = model["names"].string!
        self.surnames = model["surnames"].string ?? ""
        self.facebook_key = model["facebook_key"].string ?? ""
        self.user_id = model["user_id"].int!
        self.birth_date = model["birth_date"].string ?? ""
        self.privacy_status = model["privacy_status"].int ?? 0
        self.main_image = model["main_image"].string ?? ""
        self.level = model["level"].int ?? 0
        self.exp = model["exp"].double ?? 0
        self.is_friend = model["is_friend"].bool ?? false
        self.operation_id = model["operation_id"].int ?? 5
        
        self.total_used = nil
        self.friend_id = nil
    }
}
