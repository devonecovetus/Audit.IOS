//
//  BusinessCategoryViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 28/11/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class BusinessCategoryViewController: UIViewController {
    var intAuditId = Int()
    var intCountryId = Int()
    var intSelectedCatIndex:Int = Int()
    var strSubCategoryId = ""
    var arrCategories: [CategoryModel]? = [CategoryModel]()
    
  
    var delegate: BusinessCategoryDelegate?
    @IBOutlet weak var colView_SubCategory: UICollectionView!
    @IBOutlet weak var colView_Category: UICollectionView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        arrCategories = [CategoryModel]()
        delegate?.getBusinessCategoryAndSubCategory()
    }
  
    //MARK: BUtton Actions
    
    @IBAction func btn_Back(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Sync(_ sender: Any) {
        
        if checkValidation().count == 0 {
            self.showAlertViewWithMessage("Please select business sector types", vc: self)
        } else {
            delegate?.submitBusinessSectorRequest()
        }
    }
    
    @IBAction func btn_Clear(_ sender: Any) {
        delegate?.clearCategorySelections()
    }
    
    //MARK: Supporting Functions
    
    func checkValidation() -> String {
        strSubCategoryId = ""
        
        for i in 0..<arrCategories!.count {
            let arrSC = arrCategories?[i].subCategory
            for j in 0..<arrSC!.count {
                if arrSC?[j].isSelected == 1 {
                    strSubCategoryId = String(format: "%d,%@", (arrSC?[j].id)! , strSubCategoryId)
                }
            }
        }
        if strSubCategoryId.count > 1 {
            strSubCategoryId = String(strSubCategoryId.dropLast())
        }
        return strSubCategoryId
    }
    
    func refreshGridView() {
        self.executeUIProcess {
            self.colView_SubCategory.reloadData()
            self.colView_Category.reloadData()
        }
    }
}
