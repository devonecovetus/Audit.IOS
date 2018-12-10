//
//  AgentListSectionModel.swift
//  Audit
//
//  Created by Mac on 11/30/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class AgentListSectionModel: NSObject {

    var section:String? = String()
    var arrList = [AgentListModel]()
    
    override init() { }
    
    func initWith(section:String, arrList: [AgentListModel]) {
        self.arrList = arrList
        self.section = section
    }
    
}
