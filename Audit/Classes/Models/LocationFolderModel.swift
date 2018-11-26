//
//  LocationFolderModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 20/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class LocationFolderModel: NSObject {
    var locationId: Int? = Int()
    var folderName:String? = String()
    var folderCount:Int? = Int()
    var auditId:Int? = Int()
    var primaryId:Int? = 0

    override init() { }
    
    func initWith(dict: NSDictionary, auditId: Int, locationId: Int) {
        self.folderName = dict["folder_name"] as? String
        self.folderCount = dict["folder_count"] as? Int
        self.locationId = locationId
        self.auditId = auditId
    }
    
}
