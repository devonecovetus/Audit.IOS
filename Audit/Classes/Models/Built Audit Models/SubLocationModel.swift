//
//  CategoryModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 19/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class SubLocationModel: NSObject {
    var subLocationId: Int? = Int()
    var subLocationName:String? = String()
    var subLocationCount:Int? = Int()
    var subLocationDescription:String? = String()
    var auditId:Int? = Int()
    var isModified:Int? = Int()
    var locationId:Int? = Int()
    var work_status:Int? = Int()
    
    override init() { }
    
    func initWith(dict:NSDictionary, auditId: Int, locationId: Int) {
        if let lId = dict["id"] as? Int {
            self.subLocationId = lId
        } else {
            self.subLocationId = Int(dict["id"] as! String)
        }
        self.subLocationName = dict["title"] as? String
        self.subLocationCount = 0
        
        if let desc = dict["desc"] as? String {
            self.subLocationDescription = desc
        } else {
            self.subLocationDescription = "This is a test description for the location/ module topic"
        }
        
        self.auditId = auditId
        self.isModified = 0
        self.work_status = 0
        self.locationId = locationId
        
    }
}
