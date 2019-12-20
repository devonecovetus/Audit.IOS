//
//  LocationSubFolderListModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 26/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class LocationSubFolderListModel: NSObject {
    var locationId: Int? = Int()
    var subFolderName:String? = String()
    var subFolderDescription:String? = String()
    var folderId:Int? = Int()
    var auditId:Int? = Int()
    // It is the auto increment value
    var incId: Int? = Int()
    var is_archive: Int? = Int()
    var photo:String? = String()
    var isSync: Int? = Int()

    //This variable will holds the sublocation Module counter.
    var arrSubLocationCounter = [BuiltAuditSubLocationModel]()

    override init() { }
    
    func initWith(locationId: Int, auditId: Int, folderId: Int, name: String, description: String) {
        self.arrSubLocationCounter = []
        self.incId = 0
        self.isSync = 0
        self.is_archive = 0
        self.photo = ""
        
        self.locationId = locationId
        self.auditId = auditId
        self.folderId = folderId
        self.subFolderName = name 
        self.subFolderDescription = description
    }
    
}
