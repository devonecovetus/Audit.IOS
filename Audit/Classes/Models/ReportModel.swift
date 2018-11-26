//
//  ReportModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 30/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ReportModel: NSObject {
    var name: String? = String()
    var assignedDate: String? = String()
    var reportTitle: String? = String()
    var reportDescription: String? = String()
    var isDownloaded: Bool? = Bool()

    override init() {}
    
    func initWith(dict: NSDictionary) {
        self.name = dict["name"] as? String
        self.assignedDate = dict["assignedDate"] as? String
        self.reportTitle = dict["reportTitle"] as? String
        self.reportDescription = dict["reportDescription"] as? String
        self.isDownloaded = false
    }
    
}

