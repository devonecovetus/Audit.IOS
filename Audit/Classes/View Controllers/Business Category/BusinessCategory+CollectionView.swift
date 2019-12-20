//
//  BusinessCategory+CollectionView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 28/11/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension BusinessCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView ==  colView_Category {
            return CGSize(width: (collectionView.frame.size.width - 30), height: DeviceType.IS_PHONE ? 50 : 72)
        } else {
            let font:UIFont? = UIFont(name: CustomFont.themeFont, size: DeviceType.IS_PHONE ? 18 : 23.0)
            let size = (arrCategories?[intSelectedCatIndex].subCategory?[indexPath.row].title)?.size(withAttributes: [NSAttributedStringKey.font : font ?? UIFont()])
            return CGSize(width: size!.width + 50, height: DeviceType.IS_PHONE ? 50 : 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colView_Category {
            return arrCategories!.count
        } else if collectionView == colView_SubCategory {
            if arrCategories!.count > 0 {
                return (arrCategories?[intSelectedCatIndex].subCategory!.count)!
            }
            return 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if collectionView == colView_Category {
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
             cell.setCategoryData(obCat: arrCategories?[indexPath.row])
            return cell
        } else if collectionView == colView_SubCategory {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCell
            cell.setSubCategoryData(obSC: arrCategories?[intSelectedCatIndex].subCategory?[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colView_Category {
            intSelectedCatIndex = indexPath.row
           
            for i in 0..<(arrCategories?.count)! {
                arrCategories?[i].isSelected = 0
            }
            arrCategories?[indexPath.row].isSelected = 1
            refreshGridView()
        } else if collectionView == colView_SubCategory {
            if arrCategories?[intSelectedCatIndex].subCategory?[indexPath.row].isSelected == 0 {
                arrCategories?[intSelectedCatIndex].subCategory?[indexPath.row].isSelected = 1
            } else {
                arrCategories?[intSelectedCatIndex].subCategory?[indexPath.row].isSelected = 0
            }
            var counter = 0
            for i in 0..<(arrCategories?[intSelectedCatIndex].subCategory?.count)! {
                if arrCategories?[intSelectedCatIndex].subCategory?[i].isSelected == 1 {
                    counter += 1
                }
            }
            arrCategories?[intSelectedCatIndex].count = counter
            refreshGridView()
        }
    }
}
