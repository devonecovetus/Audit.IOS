//
//  ModuleModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 25/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ModuleModel: NSObject {
/*
     "id": 2,
     "module_id": "0",
     "title_ar": "مدخل",
     "title_en": "Entrance",
     "slug_ar": "mdkhl",
     "slug_en": "entrance",

     */

    var id: Int? = Int()
    var moduleId: String? = String()
    var titleArabic: String? = String()
    var title:String? = String()
    var slugArabic: String? = String()
    var slug:String? = String()
    var quantity: Int? = Int()
    
    override init() { }
    
    func initWith(dict: NSDictionary) {
        self.id = dict["id"] as? Int
        self.moduleId = dict["module_id"] as? String
        self.titleArabic =  dict["title_ar"] as? String
        self.title =  dict["title_en"] as? String
        self.slugArabic =  dict["slug_ar"] as? String
        self.slug =  dict["slug_en"] as? String
        self.quantity = 0
    }

}
