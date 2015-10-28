//
//  Notifications.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 24/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

protocol NotificationDelegate {
    func getNotification(packet: SocketIOPacket)
}

class NotificationButton: UIBarButtonItem, SocketIODelegate {
    var delegate:NotificationDelegate? = nil
    let socketIO : SocketIO = SocketIO()
    
    func startListening(){
        if let delegate = self.delegate {
            socketIO.delegate = self
            socketIO.useSecure = true
            

            socketIO.connectToHost("inmoon.com.mx", onPort: 443, withParams: nil, withNamespace: "/app")

        }
    }
    func socketIODidConnect(socket: SocketIO) {
        print("socket.io connected.")
        socketIO.sendEvent("join room", withData: User.userToken)
        //socketIO.sendEvent("notification", withData: User.userToken)
    }
    
    func socketIO(socket: SocketIO, didReceiveEvent packet: SocketIOPacket) {
        print("didReceiveEvent >>> data: %@", packet.dataAsJSON())
   
        if(packet.name == "my response"){
            //socketIO.sendMessage("hello back!", withAcknowledge: cb)
        }
        if(packet.name == "notification"){
             self.delegate?.getNotification(packet)
        }
       
        /*let cb: SocketIOCallback = { argsData in
            let response: [NSObject : AnyObject] = argsData as! [NSObject : AnyObject]
            print("ack arrived: %@", response)
            self.socketIO.disconnectForced()
            
        }*/
        
        
       
    }
    func socketIODidDisconnect(socket: SocketIO!, disconnectedWithError error: NSError!) {
        socketIO.connectToHost("inmoon.com.mx", onPort: 443, withParams: nil, withNamespace: "/app")
    }
    
    override init() {
        super.init()

    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
    }
}
