//
//  SocketIOManager.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 01/03/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "https://inmoon.com.mx:443")!, options:["log": true])
    override init() {
        super.init()
    }
    func establishConnection() {
        socket.connect()
        
        socket.on("connect") {data, ack in
            print(data)
        }
        
        socket.on("disconnect") {data, ack in
            print("socket disconnected")
        }
        socket.on("notification") {data, ack in
            print("G N")
        }
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    func connectToServerWithNickname(nickname: String, completionHandler: (notification: [[String: AnyObject]]!) -> Void) {
        //socket.emit("joinRoom", nickname)

    }
    func getNotification(completionHandler: (info: [String: AnyObject]) -> Void) {
        socket.on("notification") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            completionHandler(info: messageDictionary)
        }
    }
}
