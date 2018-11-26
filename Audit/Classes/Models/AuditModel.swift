//
//  AuditModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 31/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class AuditModel: NSObject {
    var assignDate:String? = String()
    var targetDate:String? = String()
    var title:String? = String()
    var auditStatus:Int? = Int()
    var auditId:String? = String()
    
    override init() { }
    
    func initWith(dict: NSDictionary) {
        self.assignDate = dict["assignDate"] as? String
        self.title = dict["assignDate"] as? String
        self.targetDate = dict["assignDate"] as? String
        self.auditId = dict["assignDate"] as? String
        self.auditStatus = dict["assignDate"] as? Int
    }
}
