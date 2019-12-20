//
//  SubLocationSubFolderModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 11/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class SubLocationSubFolderModel: NSObject {
    var workStatus: Int? = Int()
    var isLocked:Int? = Int()
    var locationId: Int? = Int()
    var subLocationId: Int? = Int()
    var subFolderName:String? = String()
    var subFolderDescription:String? = String()
    var folderId:Int? = Int()
    var subFolderId: Int? = Int()
    var auditId:Int? = Int()
    // It is the auto increment value
    var incId: Int? = Int()
    var isArchive: Int? = Int()
    var answeredCount: Int? = Int()
    var totalCount: Int? = Int()
    
    override init() { }
    
    func initWith(auditId: Int, locationId: Int, subLocationId: Int, folderId: Int, subFolderId: Int, subFolderName: String, subFolderDesc: String) {
        
        //print("folderId = \(folderId), subFolderId = \(subFolderId)")
        
        self.isLocked = 0
        self.workStatus = AuditStatus.InComplete
        self.isArchive = 0
        self.auditId = auditId
        self.locationId = locationId
        self.subLocationId = subLocationId
        self.folderId = folderId
        self.subFolderId = subFolderId
        self.subFolderName = subFolderName
        self.subFolderDescription = subFolderDesc
        self.answeredCount = 0
        self.totalCount = 0
    }
}
