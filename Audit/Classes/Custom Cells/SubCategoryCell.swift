//
//  SubCategoryCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 28/11/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class SubCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var lbl_SubCategory: UILabel!
    
    func setSubCategoryData(obSC: SubCategoryModel?) {
        lbl_SubCategory.text = obSC?.title
        if obSC?.isSelected == 1 {
            lbl_SubCategory.backgroundColor = CustomColors.themeColorGreen
            lbl_SubCategory.textColor = UIColor.white
        } else {
            lbl_SubCategory.backgroundColor = UIColor.white
            lbl_SubCategory.textColor = CustomColors.themeColorGreen
        }
    }
    
}
