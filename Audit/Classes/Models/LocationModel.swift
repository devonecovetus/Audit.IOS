//
//  LocationModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 03/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class LocationModel: NSObject {
 
    var locationId: Int? = Int()
    var locationName:String? = String()
    var locationCount:Int? = Int()
    var locationDescription:String? = String()
    var auditId:Int? = Int()
    var isModified:Int? = Int()
    var arrSubFolders = [LocationFolderModel]()
    var collapsed: Bool = true

    override init() { }
    
    func initWith(dict:NSDictionary, auditId: Int) {
        self.arrSubFolders = []
        self.collapsed = true

        if let lId = dict["id"] as? Int {
           self.locationId = lId
        } else {
            self.locationId = Int(dict["id"] as! String)
        }
        self.locationName = dict["title"] as? String
        self.locationCount = 0
        
        if let desc = dict["desc"] as? String {
            self.locationDescription = desc
        } else {
            self.locationDescription = "This is a test description for the location/ module topic"
        }
        
        self.auditId = auditId
        self.isModified = 0
        
    }
    
}
