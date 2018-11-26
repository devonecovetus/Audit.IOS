//
//  FolderCounterModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 05/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class FolderCounterModel: NSObject {
    var folderDescription:String? = String()
    var counter: Int? = Int()
    
    override init() { }
    
    func initWith(dict: NSDictionary) {
        self.folderDescription = ""
        self.counter = 0
    }
    
}
