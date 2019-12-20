//
//  QuestionAnswerProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 01/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension QuestionAnswerViewController: QuestionSuperUserAuditDelegate {
    
    func viewAndSetTextDescription(index: Int, obAns: AuditAnswerModel) {
        /// This index used when user managed text view in case of inspector
        intIndexInspector = index
        intPopUpStatus = 2
        if (obAns.answerDescription?.count)! > 0  {
            tv_InspectorDescription?.text = obAns.answerDescription
        }
        MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("TextMessageAlert", comment: ""))
    }
    
    func setAndGetInspectorQuestionData(index: Int, obAns: AuditAnswerModel) {
        view_InspectorQuestion.alpha = 1.0
        
        for i in 0..<(arrInspectorQuestions?.count)! {
            if arrInspectorQuestions?[i].parentQuestionId == obAns.questionId {
                /// This se tthe inspector question data and mamage the stuff
                setSuperAuditInspectorData(obSUAudit: arrInspectorQuestions?[i])
                break
            }
        }
    }
    
    func setSuperAuditInspectorData(obSUAudit: AuditAnswerModel?) {
        obInspectorAnswer = obSUAudit
        lbl_InspectorQuestion.text = obSUAudit?.question!
        
        if obInspectorAnswer?.imgName == "" {
            imgView_Inspector.alpha = 0.0
            btn_RemoveInspectorImg.alpha = 0.0
        } else {
            setSuperAuditInspectorImageData()
        }
        
        setQuestionPriorityForSuperAuditInspectorData()
        setPreviousDataSelected()
    }
    
    func setPreviousDataSelected() {
        arrInspectorAnswers = [AnswerTypeModel]()
        var arr_Answer1 = [String]()
        var arrAnswerIds = [String]()
        var arrSaveAnswerId = [String]()
        
        //print("obInspectorAnswer?.answers? = \(obInspectorAnswer?.answers)")
        
        /// To avoid some unintentionally data redundancy I work in this way.
        arr_Answer1 = (obInspectorAnswer?.answers?.components(separatedBy: AnswerSeperator))!
        arrAnswerIds = (obInspectorAnswer?.answerId?.components(separatedBy: ","))!
        /// Here to check if answers are saved in saved answer or not. From this condition I am accessing the answers and ids
        
        if (obInspectorAnswer?.savedAnswer?.count)! > 0 {
            arrSaveAnswerId = (obInspectorAnswer?.savedAnswer_id?.components(separatedBy: ","))!
        }
        //print("arr_Answer1.count = \(arr_Answer1.count)")
        /// On the bbbasis of the condition the loop executes the futher flow.
        if arrInspectorAnswers.count != arr_Answer1.count {
            for i in 0..<arr_Answer1.count {
                autoreleasepool {
                    let obAns = AnswerTypeModel()
                    obAns.initWith(answer: arr_Answer1[i], answerId: arrAnswerIds[i] , type: (obInspectorAnswer?.questionType!)!, status: 0)
                    arrInspectorAnswers.append(obAns)
                }
            }
        }
        
        if (obInspectorAnswer?.savedAnswer?.count)! > 0 {
            if arrInspectorAnswers.count == arr_Answer1.count {
                for j in 0..<arrInspectorAnswers.count {
                    autoreleasepool {
                        for k in 0..<arrSaveAnswerId.count {
                            autoreleasepool {
                                if arrInspectorAnswers[j].answerId == arrSaveAnswerId[k] {
                                    arrInspectorAnswers[j].status = 1
                                }
                            }
                        }
                    }
                }
            }
        }
        tblView_Inspector.reloadData()
        
        //print("sdjkf  =\(tblView_Inspector.contentSize.height)")
        if  tblView_Inspector.contentSize.height > 115.0 {
            tblInspectorHeightConstraint.constant = tblView_Inspector.contentSize.height
        }
    }
    
    func setAnswerValueForSuperAuditInspector() {
        btn_Yes.backgroundColor = UIColor.darkGray
        btn_No.backgroundColor = UIColor.darkGray
        if obInspectorAnswer?.savedAnswer == "yes" {
            btn_Yes.backgroundColor = CustomColors.themeColorGreen
        } else if obInspectorAnswer?.savedAnswer == "no" {
            btn_No.backgroundColor = UIColor.red
        }
    }
    
    func setQuestionPriorityForSuperAuditInspectorData() {
        
        if obInspectorAnswer?.priority == QuestionPriority.Low {
            btn_Priority.setTitle(QuestionPriorityName.Low, for: UIControlState.normal)
            btn_Priority.backgroundColor = PriorityColor.Low
        } else if obInspectorAnswer?.priority == QuestionPriority.Medium {
            btn_Priority.setTitle(QuestionPriorityName.Medium, for: UIControlState.normal)
            btn_Priority.backgroundColor = PriorityColor.Medium
        } else if obInspectorAnswer?.priority == QuestionPriority.High {
            btn_Priority.setTitle(QuestionPriorityName.High, for: UIControlState.normal)
            btn_Priority.backgroundColor = PriorityColor.High
        }
    }
    
    func setSuperAuditInspectorImageData() {
        imgView_Inspector.alpha = 1.0
        btn_RemoveInspectorImg.alpha = 1.0
        let obFM:FileDownloaderManager? = FileDownloaderManager()
        let image_download = UIImage(contentsOfFile: (obFM?.getAuditImagePath(imageName: (obInspectorAnswer?.imgName!)!))!)
        imgView_Inspector.image = image_download
        
        let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showAvatar(_:)))
        tapGestureRecognizer11.numberOfTapsRequired = 1
        imgView_Inspector.addGestureRecognizer(tapGestureRecognizer11)
    }
    
    func updateInspectorArray() {
        for var items in arrInspectorQuestions! {
            ///if these matches then our data will be saved
            if items.parentQuestionId == obInspectorAnswer?.parentQuestionId {
                items = obInspectorAnswer!
                break
            }
        }
    }
}

extension QuestionAnswerViewController: PopUpDelegate {
    func actionOnYes() {
        if intPopUpStatus == 2 {
            view_TextDescription.alpha = 1.0
        }
    }
    
    func actionOnNo() {
        if intPopUpStatus == 1 {
            self.view.endEditing(true)
            reloadTablecell(reloadindex: intQuestionIndex!)
        }
    }
    
}
