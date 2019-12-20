//
//  QuestionPopUpProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 02/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol QuestionPopUpActionDelegate {
    func saveAuditAnswers()
    func measurementOrSubNormalActionYes()
    func measurementOrSubNormalActionNo()
    func deleteMeasurementOrSubNormalPhoto()
    func captureMeasurementOrSubNormalPhoto()
    func removeInspectorImage()
    func inspectorActionYes()
    func inspectorActionNo()
    func captureInpsectorImage()
    func setInspectorPriority()
}

extension QusetionPopupViewController: QuestionPopUpActionDelegate {
    
    func saveAuditAnswers() {
        self.view.endEditing(true)
        if intQuestionCategoryType == QuestionCategory.Normal {
            /// Here all the subquestions will be reset (is update = 0), so that previous entries will be vanished and no issue occurred
            //print("obNormalAnswer = \(obNormalAnswer.questionId!)")
            /// Here the normal subquestions will be updated in DB
            self.fetchAllTypeSubQuestionsDataForReset(parentQuestionId: obNormalAnswer.questionId!, obAnswer: obNormalAnswer)
            
            for item in arrSubAnswers {
                if (item.savedAnswer?.count)! > 0 {
                    item.isUpdate = 1
                } else {
                    item.isUpdate = 0
                }
                _ = obSqlite.updateAuditAnswerData(obAns: item, incId: item.incId!, updateType: "updatedata")
            }
            //print("obNormalAnswer = \(obNormalAnswer.question), selectedIndex= \(selectedIndex)")
            self.normalSubQuestionDataCallBack?(selectedIndex, obNormalAnswer, arrSubAnswers)
            /// As per the logic I will pass this data on previous screen and on behalf of that I will update all the questions and subquestions
        } else if intQuestionCategoryType == QuestionCategory.Measurement {
            
            /// Here the normal subquestions will be updated in DB
            self.fetchAllTypeSubQuestionsDataForReset(parentQuestionId: obAnswer.questionId!, obAnswer: obAnswer)
            
            ///Here all data will be saved and updated
            for item in arrSubAnswers {
                if item.isUpdate == 1 && (item.savedAnswer?.count)! > 0 {
                    _ = obSqlite.updateAuditAnswerData(obAns: item, incId: item.incId!, updateType: "updatedata")
                }
            }
            self.measurementSubQuestionDataCallBack?(selectedIndex, obAnswer, arrSubAnswers)
            self.superUserAuditDataCallBack?(intSuperAuditIndex, obInspectorAnswer)
        }
        self.executeUIProcess {
            //self.showAlertViewWithDuration("Your data save successfully", vc: self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.removeUnusedMemory()
                self.navigationController?.popViewController(animated: true)
            }
            MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Simple, title: "Message", message: NSLocalizedString("QuestionDataSaved", comment: ""))
        }
    }
    
    func measurementOrSubNormalActionYes() {
        obAnswer.savedAnswer = arrAnswers[0].strAnswer
        obAnswer.savedAnswer_id = arrAnswers[0].answerId
        obAnswer.isUpdate = 1
        setTrueFalseData()
        fetchSubQuestionData(ansId: Int(arrAnswers[0].answerId)!, answer: arrAnswers[0].strAnswer)
    }
    
    func measurementOrSubNormalActionNo() {
        obAnswer.savedAnswer = arrAnswers[1].strAnswer
        obAnswer.savedAnswer_id = arrAnswers[1].answerId
        obAnswer.isUpdate = 1
        setTrueFalseData()
        fetchSubQuestionData(ansId: Int(arrAnswers[1].answerId)!, answer: arrAnswers[1].strAnswer)
    }
    
    func deleteMeasurementOrSubNormalPhoto() {
        imgView_Photo.image = UIImage()
        imgView_Photo.alpha = 0.0
        obAnswer.imgName = ""
        btn_DeletePhoto.alpha = 0.0
    }
    
    func captureMeasurementOrSubNormalPhoto() {
        intImagePickingType = 1
        MF.openActionSheet(with: imagePicker, and: self, targetFrame: CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0), isShowArrow: false)
    }
    
    func removeInspectorImage() {
        imgView_Inspector.alpha = 0.0
        btn_RemoveInspectorImg.alpha = 0.0
        obInspectorAnswer?.imgName = ""
        obInspectorAnswer?.isUpdate = 1
    }
    
    func inspectorActionYes() {
        btn_InspectorYes.backgroundColor = CustomColors.themeColorGreen
        btn_InspectorNo.backgroundColor = UIColor.darkGray
        obInspectorAnswer?.isUpdate = 1
        obInspectorAnswer?.savedAnswer = NSLocalizedString("Yes", comment: "")
        obInspectorAnswer?.savedAnswer_id = "1"
    }
    
    func inspectorActionNo() {
        btn_InspectorNo.backgroundColor = UIColor.red
        btn_InspectorYes.backgroundColor = UIColor.darkGray
        obInspectorAnswer?.isUpdate = 1
        obInspectorAnswer?.savedAnswer = NSLocalizedString("No", comment: "")
        obInspectorAnswer?.savedAnswer_id = "2"
    }
    
    func captureInpsectorImage() {
        intImagePickingType = 3
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        MF.openActionSheet(with: imagePicker, and: self, targetFrame: CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0), isShowArrow: false)
    }
    
    func setInspectorPriority() {
        globalbtn = btn_InspectorPriority
        openPriorityPickerView()
    }
}
