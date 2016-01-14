//
//  TrophyModel.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/15/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

struct BadgeModel {
    let badge_id: Int
    let name: String
    let info: String
    let user_id: Int?
    let reward_date: String?
    let earned: Bool
    let users_badges_id: Int?
    
    init(badge_id: Int, name: String, info: String, user_id: Int, reward_date: String, earned: Bool, users_badges_id: Int) {
        self.badge_id = badge_id
        self.name = name
        self.info = info
        self.user_id = user_id
        self.reward_date = reward_date
        self.earned = earned
        self.users_badges_id = users_badges_id
    }
    
    init(badge_id: Int, earned: Bool, name: String, info: String) {
        self.badge_id = badge_id
        self.earned = earned
        self.name = name
        self.info = info
        
        self.user_id = nil
        self.reward_date = nil
        self.users_badges_id = nil
        
    }
}