//
//  QuestionAnswer+CollectionView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 01/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension QuestionAnswerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colView_photo {
            return intDefaultCount
        } else {
            return arrMesurementQuestions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == colView_photo {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuesAns_ColCell", for: indexPath) as? QuesAns_ColCell
            cell?.intIndex = indexPath.row
            cell?.delegate = self
            if arrPhotos?.count == 0 {
                cell?.setphoto(filename: "")
                cell?.btn_DeleteItem.alpha = 0.0
            } else {
                var remain = 0
                remain = intDefaultCount - (arrPhotos?.count)!
                if indexPath.row < (intDefaultCount - remain) {
                    cell?.setphoto(filename: (arrPhotos?[indexPath.row].imgName!)!)
                    cell?.btn_DeleteItem.alpha = 1.0
                } else {
                    cell?.setphoto(filename: "")
                    cell?.btn_DeleteItem.alpha = 0.0
                }
            }
            return cell!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuesAns_ColCell", for: indexPath) as? QuesAns_ColCell
            cell?.lbl_question.text = arrMesurementQuestions[indexPath.row].question
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colView_Question {
            let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "QusetionPopupViewController") as! QusetionPopupViewController
            vc.selectedIndex = indexPath.row
            vc.obAnswer = arrMesurementQuestions[indexPath.row]
            var obInspector = AuditAnswerModel()
            var intSUAIndex = Int()
            for i in 0..<(arrInspectorQuestions?.count)! {
                if arrInspectorQuestions?[i].parentQuestionId == arrMesurementQuestions[indexPath.row].questionId {
                    /// This se tthe inspector question data and mamage the stuff
                    obInspector = (arrInspectorQuestions?[i])!
                    intSUAIndex = i
                    break
                }
            }
            vc.intSuperAuditIndex = intSUAIndex
            vc.obInspectorAnswer = obInspector
            vc.arrInspectorQuestions = arrInspectorQuestions
            vc.intQuestionCategoryType = QuestionCategory.Measurement
            vc.measurementSubQuestionDataCallBack = measurementSubQuestionDataCallBack
            vc.superUserAuditDataCallBack = superUserAuditDataCallBack
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == colView_Question {
            let font:UIFont? = UIFont(name: CustomFont.themeFont, size: DeviceType.IS_PHONE ? 15 : 17.0)
            let size = (arrMesurementQuestions[indexPath.row].question! as NSString).size(withAttributes: [NSAttributedStringKey.font : font ?? UIFont()])
            return CGSize(width: size.width + 50, height: DeviceType.IS_PHONE ? 40 : 50)
        } else {
            return CGSize(width: DeviceType.IS_PHONE ? 55 : 70, height: DeviceType.IS_PHONE ? 55 : 70)
        }
    }
}
