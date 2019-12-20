//
//  SubLocationFolderModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 11/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class SubLocationFolderModel: NSObject {
    var subLocationId: Int? = Int()
    var folderName:String? = String()
    var folderCount:Int? = Int()
    var auditId:Int? = Int()
    var incId:Int? = 0
    
    // --- Folders --> Sub Folders List Holder ------
    var arrSubFolders = [LocationSubFolderListModel]()
    
    
    
}
