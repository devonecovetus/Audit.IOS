//
//  QuestionPopUpSuperAuditProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 02/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol QuestionPopUpSuperUserAuditDelegate {
    func getAndSetInspectorData()
}

extension QusetionPopupViewController: QuestionPopUpSuperUserAuditDelegate {
    func getAndSetInspectorData() {
        /// if super user audit exist
        if obAnswer.isSuperUserAudit == 1 {
            lbl_InspectorQuestion.text = obInspectorAnswer?.question
            setQuestionPriorityForSuperAuditInspectorData()
            setSuperAuditInspectorImageData()
            setInspectorPreviousDataSelected()
            if (obAnswer.answerDescription?.count)! > 0 {
                //print("obAnswer.answerDescription = \(obAnswer.answerDescription)")
                tv_AuditorDescription.text = obAnswer.answerDescription
                tv_AuditorDescription.textColor = UIColor.black
            }
        }
    }
    
    func setInspectorPreviousDataSelected() {
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
    }
    
    func setAnswerValueForSuperAuditInspector() {
        btn_InspectorYes.backgroundColor = UIColor.darkGray
        btn_InspectorNo.backgroundColor = UIColor.darkGray
        if obInspectorAnswer?.savedAnswer == NSLocalizedString("Yes", comment: "") {
            btn_InspectorYes.backgroundColor = CustomColors.themeColorGreen
        } else if obInspectorAnswer?.savedAnswer == NSLocalizedString("No", comment: "") {
            btn_InspectorNo.backgroundColor = UIColor.red
        }
    }
    
    func setQuestionPriorityForSuperAuditInspectorData() {
        
        if obInspectorAnswer?.priority == QuestionPriority.Low {
            btn_InspectorPriority.setTitle(QuestionPriorityName.Low, for: UIControlState.normal)
            btn_InspectorPriority.backgroundColor = PriorityColor.Low
        } else if obInspectorAnswer?.priority == QuestionPriority.Medium {
            btn_InspectorPriority.setTitle(QuestionPriorityName.Medium, for: UIControlState.normal)
            btn_InspectorPriority.backgroundColor = PriorityColor.Medium
        } else if obInspectorAnswer?.priority == QuestionPriority.High {
            btn_InspectorPriority.setTitle(QuestionPriorityName.High, for: UIControlState.normal)
            btn_InspectorPriority.backgroundColor = PriorityColor.High
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
}


