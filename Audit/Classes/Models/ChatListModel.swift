//
//  ChatListModel.swift
//  Audit
//
//  Created by Mac on 11/30/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ChatListModel: NSObject {
    
    var role: String? = String()
    var profilePic: String? = String()
    var name: String? = String()
    var user_id: Int? = Int()
    var msg: String? = String()
    var time: String? = String()
    var email: String? = String()
    var phone: String? = String()
    var msg_type: String? = String()

    func initWith(dict: NSDictionary) {
        
        self.role = dict["role"] as? String
        self.user_id = dict["user_id"] as? Int
        self.name = dict["username"] as? String
        if let imgUrl1 = dict["photo"] as? String {
            if imgUrl1.count > 0 {
                self.profilePic = imgUrl1
                self.profilePic = self.profilePic?.replacingOccurrences(of: " ", with: "%20")
            } else {
                self.profilePic = ""
            }
        } else {
            self.profilePic = ""
        }
        self.msg = dict["msg"] as? String
        self.time = dict["time"] as? String
        self.email = dict["email"] as? String
        self.phone = dict["phone"] as? String
        
        self.msg_type = ""
    }

}
