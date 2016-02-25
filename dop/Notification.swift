//
//  Notification.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 26/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation

class Notification:NSObject{
    let type: String
    let notification_id: Int
    let launcher_id: Int
    let launcher_name: String
    let launcher_surnames: String
    let newsfeed_activity: String
    let friendship_status: Int
    var read: Bool
    var date: String
    var image_name: String
    var company_id: Int
    var object_id: Int
    var launcher_friend: Int

    init(type:String!, notification_id:Int!, launcher_id:Int!, launcher_name: String!, launcher_surnames: String!, newsfeed_activity:String!, friendship_status:Int!, read:Bool, date:String!, image_name:String!, company_id: Int!, object_id: Int!, launcher_friend: Int!) {
        self.type = type ?? ""
        self.notification_id = notification_id ?? 0
        self.launcher_id = launcher_id ?? 0
        self.launcher_name = launcher_name ?? ""
        self.launcher_surnames = launcher_surnames ?? ""
        self.newsfeed_activity = newsfeed_activity ?? ""
        self.friendship_status = friendship_status ?? 0
        self.read = read ?? false
        self.date = date ?? ""
        self.image_name = image_name
        self.company_id = company_id ?? 0
        self.object_id = object_id ?? 0
        self.launcher_friend = launcher_friend ?? 0
    }
}