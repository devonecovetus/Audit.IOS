//
//  SectionModel.swift
//  ios-swift-collapsible-table-section
//
//  Created by Mac on 11/16/18.
//  Copyright © 2018 Yong Su. All rights reserved.
//

import UIKit

class SectionModel: NSObject {
    
    var name: String
    var items: [ITEMS]
    var collapsed: Bool
    
    public init(name: String, items: [ITEMS], collapsed: Bool = true) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }

}


