//
//  CategoryCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 28/11/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var lbl_Count: UILabel!
    @IBOutlet weak var lbl_Category: UILabel!
    
    func setCategoryData(obCat: CategoryModel?) {
        lbl_Category.text = obCat?.title
        if obCat?.isSelected == 1 {
            self.backgroundColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.clear
        }
        if obCat?.count == 0 {
            lbl_Count.alpha = 0.0
        } else {
            lbl_Count.alpha = 1.0
            lbl_Count.text = String(format: "%d", obCat!.count!)
        }
    }
}
