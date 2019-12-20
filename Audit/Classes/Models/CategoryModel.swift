//
//  CategoryModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 28/11/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class CategoryModel: NSObject {
    var id: Int? = Int()
    var count:Int? = Int()
    var isSelected:Int? = Int()
    var title:String? = String()
    var details: String? = String()
    var subCategory: [SubCategoryModel]? = [SubCategoryModel]()
    
    func initWith(dict: NSDictionary?) {
        self.id = dict?["id"] as? Int
        self.title = dict?["title"] as? String
        self.details = dict?["details"] as? String
        self.count = 0
        self.isSelected = 0
        
        let arr = dict?["businessTypes"] as? NSArray
        for i in 0..<(arr?.count)! {
            let obSC: SubCategoryModel? = SubCategoryModel()
            obSC?.initWith(dict: arr?[i] as? NSDictionary)
            self.subCategory?.append(obSC!)
        }
    }
}


class SubCategoryModel: NSObject {
    
    
    var id: Int? = Int()
    var title:String? = String()
    var details:String? = String()
    var subCategoryId:Int? = Int()
    var isSelected:Int? = Int()
    
    func initWith(dict: NSDictionary?) {
        self.isSelected = 0
        self.id = dict?["id"] as? Int
        self.title = dict?["title"] as? String
        self.details = dict?["details"] as? String
        self.subCategoryId = dict?["business_sector_id"] as? Int
    }
}
