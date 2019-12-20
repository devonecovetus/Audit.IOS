//
//  ChatModel.swift
//  Audit
//
//  Created by Mac on 11/2/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation

class ChatModel: NSObject {
    var incId: Int? = Int()
    var fromid: Int? = Int()
    var from_name: String? = String()
    var msg: String? = String()
    var msgtime:String? = String()
    var msgtype:Int? = Int()
    var to_user_id:Int? = Int()
    var is_download:Int? = Int()
    
   // var lastId:Int? = Int()

    override init() { }
    
    func initWith(to_user_id:Int, is_download:Int, from_name:String, dict: NSDictionary) {
        
        self.incId = 0
        self.to_user_id = to_user_id
        self.is_download = is_download
        
        if let form_id = dict["from"] as? Int {
            self.fromid = form_id
        } else if let strform_id = dict["from"] as? String {
            self.fromid = Int(strform_id)
        }
        self.from_name = from_name
        self.msg = dict["msg"] as? String
        
        self.msgtime = dict["msgtime"] as? String
        
        if let msg_type = dict["msgtype"] as? Int {
            self.msgtype = msg_type
        } else if let strmsg_type = dict["msgtype"] as? String {
            self.msgtype = Int(strmsg_type)
        }
    }
    
    func initWithCopy(to_user_id:Int, is_download:Int, from_name:String, dict: NSDictionary, time: String) {
        
        self.incId = 0
        self.to_user_id = to_user_id
        self.is_download = is_download
        
        if let form_id = dict["from"] as? Int {
            self.fromid = form_id
        } else if let strform_id = dict["from"] as? String {
            self.fromid = Int(strform_id)
        }
        self.from_name = from_name
        self.msg = dict["msg"] as? String
        
        self.msgtime = time
        
        if let msg_type = dict["msgtype"] as? Int {
            self.msgtype = msg_type
        } else if let strmsg_type = dict["msgtype"] as? String {
            self.msgtype = Int(strmsg_type)
        }
    }
    
    private static var chatmodel: ChatModel?
    
    class func sharedInstance() -> ChatModel {
        if self.chatmodel == nil {
            //print("chat object nil and initiates")
            self.chatmodel = ChatModel()
            // Here user profile data will be inserted.
        } else {
            //print("chat object not nil")
        }
        return self.chatmodel!
    }
}

