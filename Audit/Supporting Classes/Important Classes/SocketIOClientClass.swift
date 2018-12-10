//
//  SocketIOClientClass.swift
//  Audit
//
//  Created by Mac on 12/3/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import SocketIO

struct ChatEvents {
    static let Admin_SendMsg  = "chat auditor message"
    static let Admin_GetMsg = "get auditor past chats"
    
    static let Auditor_SendMsg  = "chat auditor to auditor message"
    static let Auditor_GetMsg = "get auditor to auditor past chats"
    
    static let Agent_SendMsg  = "chat agent auditor message"
    static let Agent_GetMsg = "get agent auditor past chats"
}

enum ChatType {
    static let text = "1"
    static let image = "2"
    static let video = "3"
    static let document = "4"
}

public class SocketIOClientClass {
    
    static let instance = SocketIOClientClass()
    
    let manager = SocketManager(socketURL: URL(string: "http://dev.covetus.com:8090")!, config: [.log(true), .compress])
    var socket:SocketIOClient
    
    private init() {
        self.socket = manager.defaultSocket
    }
}
