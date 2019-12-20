//
//  BusinessCategoryProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 28/11/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit


protocol BusinessCategoryDelegate {
    func getBusinessCategoryAndSubCategory()
    func submitBusinessSectorRequest()
    func clearCategorySelections()
}

extension BusinessCategoryViewController: BusinessCategoryDelegate {
    
     func clearCategorySelections() {
        for i in 0..<(arrCategories?.count)! {
            if i == 0 {
                arrCategories?[i].isSelected = 1
            } else {
                arrCategories?[i].isSelected = 0
            }
            arrCategories?[i].count = 0
            for j in 0..<(arrCategories?[i].subCategory?.count)! {
                arrCategories?[i].subCategory?[j].isSelected = 0
            }
            intSelectedCatIndex = 0
            refreshGridView()
        }
    }
    
    func submitBusinessSectorRequest() {

        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(intAuditId, forKey: "audit_id")
        dictP.setValue(strSubCategoryId, forKey: "business_sector_id")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.SubmitBusinessSectors, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            kAppDelegate.flagIsOrderSubmit = true
            self.executeUIProcess({
                self.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
    
    func getBusinessCategoryAndSubCategory() {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(intAuditId, forKey: "audit_id")
        dictP.setValue(intCountryId, forKey: "country_id")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetBusinessCategories, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                let arr = dictJson["response"] as? NSArray
                
                for i in 0..<(arr?.count)! {
                    let obCat: CategoryModel? = CategoryModel()
                    obCat?.initWith(dict: arr?[i] as? NSDictionary)
                    self.arrCategories?.append(obCat!)
                }
                self.intSelectedCatIndex = 0
                self.arrCategories?[self.intSelectedCatIndex].isSelected = 1
                self.refreshGridView()
            }
        }
    }
}
