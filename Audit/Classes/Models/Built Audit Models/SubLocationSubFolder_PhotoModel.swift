//
//  SubLocationSubFolder_PhotoModel.swift
//  Audit
//
//  Created by Mac on 12/19/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class SubLocationSubFolder_PhotoModel: NSObject {

    var incId:Int? = Int()
    var auditId:Int? = Int()
    var locationId:Int? = Int()
    var folderId: Int? = Int()
    var subFolderId: Int? = Int()
    var subLocationId: Int? = Int()
    var subLocation_subFolderId: Int? = Int()
    var locationName:String? = String()
    var folderName:String? = String()
    var subFolderName:String? = String()
    var subLocationName:String? = String()
    var subLocation_subFolderName:String? = String()
    var imgName:String? = String()
    var answeredCount: Int? = Int()
    var totalCount: Int? = Int()
    var main_photo: Int? = Int()
    var isSync: Int? = Int()

    override init() { }
    
    func initWith(auditId: Int, locationId: Int, folderId: Int, subFolderId: Int, subLocationId: Int, subLocation_subFolderId: Int, imgName: String, main_photo: Int) {
        
        self.isSync = 0
        self.incId = 0
        self.auditId = auditId
        self.locationId = locationId
        self.folderId = folderId
        self.subFolderId = subFolderId
        self.subLocationId = subLocationId
        self.subLocation_subFolderId = subLocation_subFolderId
        
        self.locationName = ""
        self.folderName = ""
        self.subFolderName = ""
        self.subLocationName = ""
        self.subLocation_subFolderName = ""
        self.imgName = imgName
        self.main_photo = main_photo
        self.answeredCount = 0
        self.totalCount = 0
    }
}
