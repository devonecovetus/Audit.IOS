//
//  MyAuditListModel.swift
//  Audit
//
//  Created by Mac on 11/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyAuditListModel: NSObject {

    var id: Int? = Int()
    var audit_id: Int? = Int()
    var audit_title: String? = String()
    var audit_status: Int? = Int()
    var assign_by: String? = String()
    var target_date: String? = String()
    
    override init() { }
    
    func initWith(dict: NSDictionary) {
        //self.id = dict["id"] as? Int
        self.audit_id = (dict["auditDetails"] as! NSDictionary)["id"] as? Int
        self.audit_title =  (dict["auditDetails"] as! NSDictionary)["title"] as? String
        self.audit_status =  AuditStatus.InComplete
        if let dictP = dict["contactPerson"] as? NSDictionary {
            self.assign_by =  dictP["name"] as? String
        }
        self.target_date =  (dict["auditDetails"] as! NSDictionary)["end_date"] as? String
    }
    
}
