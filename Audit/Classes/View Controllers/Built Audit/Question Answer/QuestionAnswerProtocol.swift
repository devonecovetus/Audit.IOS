//
//  QuestionAnswerProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 01/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol QuestionAnswerActionDelegate {
    func removeInspectorImage()
    func inspectorActionYes()
    func inspectorActionNo()
    func captureInpsectorImage()
    func saveAuditAnswerData()
    func deleteMainPhoto()
    func addMainPhoto()
}

extension QuestionAnswerViewController: QuestionAnswerActionDelegate {
    func removeInspectorImage() {
        imgView_Inspector.alpha = 0.0
        btn_RemoveInspectorImg.alpha = 0.0
        obInspectorAnswer?.imgName = ""
        obInspectorAnswer?.isUpdate = 1
    }
    
    func inspectorActionYes() {
        btn_Yes.backgroundColor = CustomColors.themeColorGreen
        btn_No.backgroundColor = UIColor.darkGray
        obInspectorAnswer?.isUpdate = 1
        obInspectorAnswer?.savedAnswer = "yes"
        obInspectorAnswer?.savedAnswer_id = "1"
        updateInspectorArray()
    }
    
    func inspectorActionNo() {
        btn_No.backgroundColor = UIColor.red
        btn_Yes.backgroundColor = UIColor.darkGray
        obInspectorAnswer?.isUpdate = 1
        obInspectorAnswer?.savedAnswer = "no"
        obInspectorAnswer?.savedAnswer_id = "2"
        updateInspectorArray()
    }
    
    func captureInpsectorImage() {
        self.photobtnclick = "superAudit"
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        MF.openActionSheet(with: imagePicker!, and: self, targetFrame: CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0), isShowArrow: false)
    }
    
    func saveAuditAnswerData() {
        self.view.endEditing(true)
        var arrAnswerLocal:[AuditAnswerModel]? = [AuditAnswerModel]()
        for item in arrNormalQuestions {
            autoreleasepool {
                resetSubQuestionData(item: item)
                
                if (item.savedAnswer?.count)! > 0 {
                    item.isUpdate = 1
                } else {
                    item.isUpdate = 0
                }
                _ = obSqlite.updateAuditAnswerData(obAns: item, incId: item.incId!, updateType: "updatedata")
            }
        }
        for item in arrMesurementQuestions {
            autoreleasepool {
                ///Here comment only for checking the flow is going perfect or not
                // resetSubQuestionData(item: item)
                
                if (item.savedAnswer?.count)! > 0 {
                    item.isUpdate = 1
                } else {
                    item.isUpdate = 0
                }
                _ = obSqlite.updateAuditAnswerData(obAns: item, incId: item.incId!, updateType: "updatedata")
            }
        }
        
        /// Saving Inspector question for Super Audit Case
        for item in arrInspectorQuestions! {
            autoreleasepool {
                if (item.savedAnswer?.count)! > 0 {
                    item.isUpdate = 1
                } else {
                    item.isUpdate = 0
                }
                _ = obSqlite.updateAuditAnswerData(obAns: item, incId: item.incId!, updateType: "updatedata")
            }
        }
        
        /// Now here is a loop for noraml sub questions
        for item in arrNormalSubAnswer! {
            autoreleasepool {
                if (item.savedAnswer?.count)! > 0 {
                    item.isUpdate = 1
                } else {
                    item.isUpdate = 0
                }
                _ = obSqlite.updateAuditAnswerData(obAns: item, incId: item.incId!, updateType: "updatedata")
            }
        }
        
        for item in arrMeasurementSubAnswer {
            autoreleasepool {
                if (item.savedAnswer?.count)! > 0 {
                    item.isUpdate = 1
                } else {
                    item.isUpdate = 0
                }
                _ = obSqlite.updateAuditAnswerData(obAns: item, incId: item.incId!, updateType: "updatedata")
            }
        }
        
        ///reset subquestion those parent questions status is isUpdate = 0

        /// Here a loop will be called for two types of questions. And in this loop update query will be triggered and all data willbe saved persistantly.
        self.executeUIProcess {
            //self.showAlertViewWithDuration("Your data save successfully", vc: self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.releaseUnusedMemory()
                self.navigationController?.popViewController(animated: true)
            }
            MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Simple, title: "Message", message: NSLocalizedString("QuestionDataSaved", comment: ""))
        }
    }
    
    func resetSubQuestionData(item: AuditAnswerModel) {
        if item.questionType == QuestionType.Radio || item.questionType == QuestionType.CheckBox || item.questionType == QuestionType.DropDown {
            /// Here my logic to reset unslected normal question's subquestions
            if item.savedAnswer_id!.count > 0 {
                if item.hasSubQuestion == 1 {
                    self.resetAllTypeSubQuestions(parentQuestionId: item.parentQuestionId!, obAnswer: item)
                }
            }
        }
    }
    
    func fetchAllTypeSubQuestionsDataForReset(parentQuestionId: Int, obAnswer: AuditAnswerModel) {
        
        let arr = obSqlite.getAuditAnswers(auditId: obAnswer.auditId!, locationId: obAnswer.locationId!, folderId: obAnswer.folderId!, subfolderId: 0, sub_locationId: obAnswer.subLocationId!, sub_locationsub_folderId: obAnswer.sublocation_subfolder_id!, parentQueId: parentQuestionId, selectedAnsId: 0, fetchType: "resetwithParentQueId")
       //print("arr = \(arr.count)")
        for obAns in arr {
            autoreleasepool {
                if obAns.isUpdate == 1 { /// If any ans updated then reset to 0
                    let isUpdate = obSqlite.updateAuditAnswerData(obAns: obAnswer, incId: obAns.incId!, updateType: "reset")
                    if isUpdate {
                        self.fetchAllTypeSubQuestionsDataForReset(parentQuestionId: obAns.questionId!, obAnswer: obAns)
                    }
                }
            }
        }
    }
    
    func deleteMainPhoto() {
        if arrMainPhoto?.count != 0 {
            let isDeleted = obSqlite.deleteSubLocationSubFolderPhoto(incId: (arrMainPhoto?[0].incId!)!, auditId: 0, locationId: 0, sublocationId: 0, deleteType: "incID")
            if isDeleted {
                arrMainPhoto?.remove(at: 0)
                imgView_Photo?.image = UIImage(named: "bg_gallery")
            }
        }
    }
    
    func addMainPhoto() {
        photobtnclick = "all"
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        MF.openActionSheet(with: imagePicker!, and: self, targetFrame: btn_AddPhoto.frame)
    }
    
    func resetUnSelectedSubAnswersFromParentQuestions(savedAnswerId: Int, arrAnswerId: NSArray) {
        let arrUnSelectedAnswerIds = NSMutableArray()
        for i in 0..<arrAnswerId.count {
            if savedAnswerId != arrAnswerId[i] as! Int {
                arrUnSelectedAnswerIds.add(arrAnswerId[i] as! Int)
            }
        }
    }

    func resetAllTypeSubQuestions(parentQuestionId: Int, obAnswer: AuditAnswerModel) {
        
        let arr = obSqlite.getAuditAnswers(auditId: obAnswer.auditId!, locationId: obAnswer.locationId!, folderId: obAnswer.folderId!, subfolderId: 0, sub_locationId: obAnswer.subLocationId!, sub_locationsub_folderId: obAnswer.sublocation_subfolder_id!, parentQueId: parentQuestionId, selectedAnsId: 0, fetchType: "resetwithParentQueId")
       //print("arr = \(arr.count)")
        for obAns in arr {
            autoreleasepool {
                if obAns.hasSubQuestion == 1 { /// If it contains subquestion then execute this condition
                    if obAns.isUpdate == 1 { /// If any ans updated then reset to 0
                        let isUpdate = obSqlite.updateAuditAnswerData(obAns: obAnswer, incId: obAns.incId!, updateType: "reset")
                        if isUpdate {
                            self.resetAllTypeSubQuestions(parentQuestionId: obAns.questionId!, obAnswer: obAns)
                        }
                    }
                }
            }
        }
    }
}
