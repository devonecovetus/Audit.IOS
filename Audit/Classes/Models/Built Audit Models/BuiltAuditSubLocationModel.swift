//
//  BuiltAuditSubLocationModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 04/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class BuiltAuditSubLocationModel: NSObject {
    var subLocationId: Int? = Int()
    var subLocationName:String? = String()
    var subLocationCount:Int? = Int()
    var subLocationDescription:String? = String()
    var auditId:Int? = Int()
    var isModified:Int? = Int()
    var locationId:Int? = Int()
    var workStatus:Int? = Int()
    var folderId: Int? = Int()
    var subFolderId: Int? = Int()
    var incId:Int? = Int()
    var isLocked:Int? = Int()
    var arrFolders = [SubLocationSubFolderModel]()

    override init() { }
    
    func initWith(auditId: Int, locationId: Int, subLocationId: Int, folderId: Int, subFolderId: Int, workStatus: Int, subLocationCount: Int, subLocationName: String, subLocationDesc: String) {
        
        self.arrFolders = []
        self.auditId = auditId
        self.locationId = locationId
        self.subLocationId = subLocationId
        self.folderId = folderId
        self.subFolderId = subFolderId
        self.workStatus = workStatus
        self.subLocationCount = subLocationCount
        self.subLocationName = subLocationName
        self.subLocationDescription = subLocationDesc
        self.isModified = 1
        self.isLocked = 0
    }
    
}
