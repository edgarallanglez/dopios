//
//  NotificationViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NotificacionViewController: UIViewController, SocketIODelegate {
    let socketIO : SocketIO = SocketIO()
    
    override func viewDidLoad() {
        socketIO.delegate = self
        socketIO.useSecure = true
        socketIO.connectToHost("inmoon.com.mx", onPort: 443, withParams: nil, withNamespace: "/test")

    }
    
    func socketIODidConnect(socket: SocketIO) {
        NSLog("socket.io connected.")
        socketIO.sendEvent("my event", withData: "sd")
    }
    
    func socketIO(socket: SocketIO, didReceiveEvent packet: SocketIOPacket) {
        NSLog("didReceiveEvent >>> data: %@", packet.data)
        
        let cb: SocketIOCallback = { argsData in
            let response: [NSObject : AnyObject] = argsData as! [NSObject : AnyObject]
            NSLog("ack arrived: %@", response)
            self.socketIO.disconnectForced()
            
        }
        socketIO.sendMessage("hello back!", withAcknowledge: cb)
    }
    
}
