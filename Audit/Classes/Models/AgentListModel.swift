//
//  AgentListModel.swift
//  Audit
//
//  Created by Mac on 11/29/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class AgentListModel: NSObject {

    var profilePic: String? = String()
    var name: String? = String()
    var agentid: Int? = Int()
    var role: String? = String()
    var email: String? = String()
    var phone: String? = String()
    
    func initWith(dict: NSDictionary) {
        self.profilePic = dict["photo"] as? String
        self.name = dict["username"] as? String
        self.role = dict["role"] as? String
        self.agentid = dict["user_id"] as? Int
        self.email = dict["email"] as? String
        self.phone = dict["phone"] as? String
    }
    
}
