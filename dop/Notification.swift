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
    let catcher_id: Int
    let launcher_name: String
    let launcher_surnames: String
    let branches_name: String
    let operation_id: Int
    var read: Bool
    var date: String
    var image_name: String
    var company_id: Int
    var object_id: Int
    var branch_id: Int

    init(type: String!, notification_id: Int!, launcher_id: Int!, catcher_id: Int!, launcher_name: String!, launcher_surnames: String!, branches_name: String!, operation_id: Int!, read: Bool, date: String!, image_name: String!, company_id: Int!, object_id: Int!, branch_id: Int!) {
        
        self.type = type ?? ""
        self.notification_id = notification_id ?? 0
        self.launcher_id = launcher_id ?? 0
        self.launcher_name = launcher_name ?? ""
        self.launcher_surnames = launcher_surnames ?? ""
        self.branches_name = branches_name ?? ""
        self.operation_id = operation_id ?? 0
        self.read = read ?? false
        self.date = date ?? ""
        self.image_name = image_name
        self.company_id = company_id ?? 0
        self.object_id = object_id ?? 0
        self.branch_id = branch_id ?? 0
        self.catcher_id = catcher_id ?? 0
    }
}