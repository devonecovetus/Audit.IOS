//
//  SocketIOManager.swift
//  Socket Demo
//
//  Created by Mac on 9/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SocketIO

protocol Chat_VC {
    func Chat_Load(chat:[ChatModel], loadtype:String, object:NSDictionary)
}

class SocketIOManager: NSObject {
    
    var delegate:Chat_VC?

    static let sharedInstance = SocketIOManager()
    
    let manager = SocketManager(socketURL: URL(string: "http://dev.covetus.com:8090")!, config: [.log(true), .compress])
    var socket:SocketIOClient
    
    var success = Bool()
    
    override init() {
        self.socket = manager.defaultSocket
    }
   
    func establishConnection() {
        socket.connect()
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.socket.emit("load id", UserProfile.id!)
        }
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func reattemptConnection() {
        socket.on(clientEvent: .reconnectAttempt) {data, ack in
            print("socket reconnectAttempt")
            self.socket.manager?.reconnects = true
        }
        socket.manager?.forceNew = true
    }
    
    func userLogin(userIdentifier:NSString) {
     //   socket.emit("load id", userIdentifier)
    }
    
    func Socketon(userid: String, get_event:String, reciver_id:String, sender_id:String, update_chatmessage:String) {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.socket.emit("load id", userid)
            self.loadAllChat(chattype: get_event, receiver_id: reciver_id, sender_id: sender_id, hardcoded_str: "1", update_chatmessage: update_chatmessage)
        }
    }
    
    
    func sendMessage(chat_event:String, reciver_id:String, sender_id:String, message:String, sender_name:String, receiver_name:String, type:String){
        
        let JsonSendToSocket: [String: String] = [
            "yname": sender_id,
            "msg": message,
            "from_name": sender_name,
            "to_name": receiver_name,
            "type": type,
        ]
        
        self.socket.emit(chat_event, reciver_id, JsonSendToSocket)
    }
    
    func loadAllChat(chattype:String, receiver_id:String, sender_id:String, hardcoded_str:String, update_chatmessage:String){
        
        self.socket.off(chattype)
        self.socket.off(update_chatmessage)

        self.socket.emit(chattype, receiver_id, sender_id, hardcoded_str)
        
        self.socket.on(chattype) {data, ack in
            let jsonText = data[0] as! NSString
            var dictonary:NSDictionary?
            
            if let data = jsonText.data(using: String.Encoding.utf8.rawValue) {
                do {
                    dictonary = try ((JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary))
                    if let myDictionary = dictonary
                    {
                        print("Socket response \(myDictionary["chats"]!)")
                        
                        var tempNames = [ChatModel]()
                        
                        for i in 0..<(myDictionary["chats"] as! NSArray).count {
                            let obRequest = ChatModel()
                            obRequest.initWith(to_user_id: Int(receiver_id)!, is_download: 0, from_name: "demo", dict: (myDictionary["chats"] as! NSArray)[i] as! NSDictionary)
                            tempNames.append(obRequest)
                        }

                        self.delegate?.Chat_Load(chat: tempNames, loadtype: "all", object:[:])
                    }
                  //  LoderGifView.MyloaderHide(view: self.view)
                } catch let error as NSError {
                    print(error)
                   // LoderGifView.MyloaderHide(view: self.view)
                }
            }
        }
        
        // message update
        self.socket.on(update_chatmessage) {data, ack in
            let jsonText = data[1] as! NSString
            var dictonary:NSDictionary?
            if let data = jsonText.data(using: String.Encoding.utf8.rawValue) {
                do {
                    dictonary = try ((JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary))
                    if let myDictionary = dictonary {
                        let tempNames: NSArray = (myDictionary["response"] as? NSArray)!
                        let list = tempNames[0] as! NSDictionary
                        self.delegate?.Chat_Load(chat: [], loadtype: "new", object: list)
                        return
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
}
