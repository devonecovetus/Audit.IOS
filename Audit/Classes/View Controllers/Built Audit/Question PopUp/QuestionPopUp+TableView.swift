//
//  QuestionPopUp+TableView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 02/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension QusetionPopupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblView_Inspector {
            return arrInspectorAnswers.count
        } else if tableView == tblView_Measurement {
            return arrAnswers.count
        } else if tableView == tblView_DropDown {
            return arrAnswers.count
        } else {
            return arrSubAnswers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblView_Inspector {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckUncheck_Cell", for: indexPath) as! CheckUncheck_Cell
            cell.setRadioData(obAns: arrInspectorAnswers[indexPath.row])
        } else if tableView == tblView_Measurement {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckUncheck_Cell", for: indexPath) as! CheckUncheck_Cell
            if obAnswer.questionType == QuestionType.CheckBox {
                cell.setCheckUnCheckData(obAns: arrAnswers[indexPath.row])
            } else if obAnswer.questionType == QuestionType.DropDown {
                cell.setDropDownData(obAns: arrAnswers[indexPath.row])
            } else if obAnswer.questionType == QuestionType.Radio {
                cell.setRadioData(obAns: arrAnswers[indexPath.row])
            }
            return cell
        } else if tableView == tblView_DropDown { /// Sub questions for normal
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! CheckUncheck_Cell
            cell.setDropDownData(obAns: arrAnswers[indexPath.row])
            return cell
        } else {
            if arrSubAnswers[indexPath.row].questionType == QuestionType.Radio {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RadioType", for: indexPath) as! QuestionTypeCell
                cell.intIndex = indexPath.row
                cell.delegate = self
                cell.obQuestion = arrSubAnswers[indexPath.row]
                cell.setQuestionData(obQuestion: arrSubAnswers[indexPath.row])
                return cell
            } else if arrSubAnswers[indexPath.row].questionType == QuestionType.CheckBox {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckBox", for: indexPath) as! QuestionTypeCell
                cell.intIndex = indexPath.row
                cell.delegate = self
                cell.obQuestion = arrSubAnswers[indexPath.row]
                cell.setQuestionData(obQuestion: arrSubAnswers[indexPath.row])
                return cell
            } else if arrSubAnswers[indexPath.row].questionType == QuestionType.DropDown {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DropDown", for: indexPath) as! QuestionTypeCell
                cell.intIndex = indexPath.row
                cell.delegate = self
                cell.obQuestion = arrSubAnswers[indexPath.row]
                cell.setQuestionData(obQuestion: arrSubAnswers[indexPath.row])
                return cell
            } else if arrSubAnswers[indexPath.row].questionType == QuestionType.TrueFalse {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrueFalse", for: indexPath) as! QuestionTypeCell
                cell.intIndex = indexPath.row
                cell.delegate = self
                cell.obQuestion = arrSubAnswers[indexPath.row]
                cell.setQuestionData(obQuestion: arrSubAnswers[indexPath.row])
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblView_DropDown {
            return 40.0
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblView_Inspector {
            selectInspectorAnswerOnRadioClick(indexPath: indexPath)
        } else if tableView == tblView_Measurement {
            if obAnswer.questionType == QuestionType.Radio {
                selectAnswerOnRadioClick(indexPath: indexPath)
            } else if obAnswer.questionType == QuestionType.CheckBox {
                selectAnswerOnCheckBoxClick(indexPath: indexPath)
            }
        } else if tableView == tblView_DropDown {
            self.selectAnswerOnDropDownClick(indexPath: indexPath)
        } else if tableView == tblView_SubQuestions { }
    }
    
    func fetchMeasurementSQDataOnCalling(ansId:Int, answer: String, obAnswer: AuditAnswerModel) {
        let arr = obSqlite.getAuditAnswers(auditId: obAnswer.auditId!, locationId: obAnswer.locationId!, folderId: obAnswer.folderId!, subfolderId: 0, sub_locationId: obAnswer.subLocationId!, sub_locationsub_folderId: obAnswer.sublocation_subfolder_id!, parentQueId: obAnswer.questionId!, selectedAnsId: ansId, fetchType: "subQue")
        
        /// Means there is a subquestion on this case string
        if arr.count > 0 {
            arrSubAnswers.append(arr[0])
            tblView_SubQuestions.reloadData()
            //print("arr[0].savedAnswer_id = \(arr[0].savedAnswer_id), arr[0].savedAnswer = \(arr[0].savedAnswer), !(obAnswer.savedAnswer_id?.contains())! = \(!(arr[0].savedAnswer_id?.contains(","))!)")
            if arr[0].savedAnswer_id!.count > 0 && arr[0].savedAnswer!.count > 0 && !(arr[0].savedAnswer_id?.contains(","))! {
                fetchMeasurementSQDataOnCalling(ansId: Int(arr[0].savedAnswer_id!)!, answer: arr[0].savedAnswer!, obAnswer: arr[0])
            }
        }
    }
    
    /// This logic is for measurement question type
    func fetchMeasurementSubQuestionData(ansId:Int, answer: String) {
        let arr = obSqlite.getAuditAnswers(auditId: obAnswer.auditId!, locationId: obAnswer.locationId!, folderId: obAnswer.folderId!, subfolderId: 0, sub_locationId: obAnswer.subLocationId!, sub_locationsub_folderId: obAnswer.sublocation_subfolder_id!, parentQueId: obAnswer.questionId!, selectedAnsId: ansId, fetchType: "subQue")
        
        /// Means there is a subquestion on this case string
        if arr.count > 0 {
            if arrSubAnswers.count > 0 {
                arrSubAnswers.removeAll()
                tblView_SubQuestions.reloadData()
            }
            arrSubAnswers.append(arr[0])
            tblView_SubQuestions.reloadData()
        } else {
            if arrSubAnswers.count > 0 {
                arrSubAnswers.removeAll()
                tblView_SubQuestions.reloadData()
            }
        }
    }
    
    func getNormalSubQuestionsAfterSave(ansId:Int, answer: String, questionId: Int) {
        let arr = obSqlite.getAuditAnswers(auditId: obAnswer.auditId!, locationId: obAnswer.locationId!, folderId: obAnswer.folderId!, subfolderId: 0, sub_locationId: obAnswer.subLocationId!, sub_locationsub_folderId: obAnswer.sublocation_subfolder_id!, parentQueId: questionId, selectedAnsId: ansId, fetchType: "subQue")
        
        if arr.count > 0 {
            
            if arr[0].savedAnswer_id!.count > 0 {
                arrSubAnswers.append(arr[0])
                tblView_SubQuestions.reloadData()
                //print("arr[0].savedAnswer_id = \(arr[0].savedAnswer_id)")
                self.getNormalSubQuestionsAfterSave(ansId: Int(arr[0].savedAnswer_id!)! , answer: arr[0].answers!, questionId:  arr[0].questionId!)
            }
        }
    }
    /// When user click on measurement question option then this method exexutes
    func fetchMeasurementSubQuestionDataOnOptionClick(ansId:Int, answer: String, obAnswer: AuditAnswerModel) {
        let arr = obSqlite.getAuditAnswers(auditId: obAnswer.auditId!, locationId: obAnswer.locationId!, folderId: obAnswer.folderId!, subfolderId: 0, sub_locationId: obAnswer.subLocationId!, sub_locationsub_folderId: obAnswer.sublocation_subfolder_id!, parentQueId: obAnswer.questionId!, selectedAnsId: ansId, fetchType: "subQue")
        /// Means there is a subquestion on this case string
        if arr.count > 0 {
            
            arrSubAnswers.append(arr[0])
            var arrAnswerIds = [String]()
            arrAnswerIds =  (arr[0].answerId?.components(separatedBy: ","))!
            var arrAnswers =  (arr[0].answers?.components(separatedBy: AnswerSeperator))!
            var obATM:AnswerTypeModel?
            for i in 0..<arrAnswerIds.count {
                    let obAns = AnswerTypeModel()
                    obAns.initWith(answer: arrAnswers[i], answerId: arrAnswerIds[i] , type: arr[0].questionType!, status: 0)
                    if Int(obAns.answerId) == Int(arr[0].savedAnswer_id!) {
                        obATM = obAns
                        break
                    }
            }
            //print("arr[0].answerId =\(obATM?.answerId), arr[0].savedAnswer = \(obATM?.strAnswer)")
            if obATM != nil {
                fetchMeasurementSubQuestionDataOnOptionClick(ansId: Int(obATM!.answerId)!, answer: obATM!.strAnswer, obAnswer: arr[0])
            }
            tblView_SubQuestions.reloadData()
        } else {
            if obAnswer.hasSubQuestion == 1 {
                if arrSubAnswers.count > 0 {
                    //        arrSubAnswers.removeAll()
                    arrSubAnswers.remove(at: arrSubAnswers.count - 1)
                    tblView_SubQuestions.reloadData()
                }
            }
        }
    }
    
    //for normal QuestionType
    func fetchSubQuestionData(ansId:Int, answer: String) {
        
        let arr = obSqlite.getAuditAnswers(auditId: obAnswer.auditId!, locationId: obAnswer.locationId!, folderId: obAnswer.folderId!, subfolderId: 0, sub_locationId: obAnswer.subLocationId!, sub_locationsub_folderId: obAnswer.sublocation_subfolder_id!, parentQueId: obAnswer.questionId!, selectedAnsId: ansId, fetchType: "subQue")
     
        //print("arr = \(arr.count)")
        
        for questions in arr {
            //print("questions = \(questions.question), qId = \(questions.questionId)")
        }
        
        
        /// Means there is a subquestion on this case string
        if arr.count > 0 {
            arrSubAnswers.append(arr[0])
            
            tblView_SubQuestions.reloadData()
        } else {
            if obAnswer.hasSubQuestion == 1 {
                if arrSubAnswers.count > 0 {
                    //        arrSubAnswers.removeAll()
                    arrSubAnswers.remove(at: arrSubAnswers.count - 1)
                    tblView_SubQuestions.reloadData()
                }
            }
        }
    }
    
    /**
     Before saving subquestion data I am resetting all the subquestions data related to it.
     */
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
    
    func selectAnswerOnDropDownClick(indexPath: IndexPath) {
        var strAnswers = String()
        var strAnswerId = String()
        for i in  0..<arrAnswers.count {
            arrAnswers[i].status = 0
        }
        
        if arrAnswers[indexPath.row].answerId != "0" {
            if arrAnswers[indexPath.row].status == 0 {
                arrAnswers[indexPath.row].status = 1
                strAnswers = arrAnswers[indexPath.row].strAnswer
                strAnswerId = arrAnswers[indexPath.row].answerId
                btn_DropDown.setTitle(strAnswers, for: UIControlState.normal)
                btn_DropDown.backgroundColor = CustomColors.themeColorGreen
                fetchMeasurementSubQuestionData(ansId: Int(arrAnswers[indexPath.row].answerId)!, answer: arrAnswers[indexPath.row].strAnswer)
            }
            tblView_DropDown.alpha = 0.0
            obAnswer.savedAnswer = strAnswers
            obAnswer.savedAnswer_id = strAnswerId
            obAnswer.isUpdate = 1
            tblView_DropDown.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        } else {
             tblView_DropDown.alpha = 0.0
            btn_DropDown.setTitle(strAnswers, for: UIControlState.normal)
            btn_DropDown.backgroundColor = UIColor.groupTableViewBackground
             btn_DropDown.setTitleColor(UIColor.black, for: UIControlState.normal)
             obAnswer.isUpdate  = 0
            obAnswer.savedAnswer = strAnswers
            obAnswer.savedAnswer_id = strAnswerId
        }
    }
    
    func selectAnswerOnCheckBoxClick(indexPath: IndexPath) {
        var strAnswers = String()
        var strAnswerId = String()
        if arrAnswers[indexPath.row].status == 0 {
            arrAnswers[indexPath.row].status = 1
        } else if arrAnswers[indexPath.row].status == 1 {
            arrAnswers[indexPath.row].status = 0
        }
        
        for i in  0..<arrAnswers.count {
            autoreleasepool {
                if arrAnswers[i].status == 1 {
                    strAnswers = String(format: "%@%@%@", strAnswers, AnswerSeperator, arrAnswers[i].strAnswer)
                    strAnswerId = String(format: "%@,%@", strAnswerId, arrAnswers[i].answerId)
                    if strAnswerId.first == "," {
                        strAnswerId.remove(at: strAnswerId.startIndex)
                    }
                    obAnswer.isUpdate = 1
                    obAnswer.savedAnswer = strAnswers
                    obAnswer.savedAnswer_id = strAnswerId
                    fetchSubQuestionData(ansId: Int(arrAnswers[i].answerId)!, answer: arrAnswers[i].strAnswer)
                }
            }
        }
        tblView_Measurement.reloadData()
    }
    
    func selectAnswerOnRadioClick(indexPath: IndexPath) {
        
        var strAnswers = String()
        var strAnswerId = String()
        for i in  0..<arrAnswers.count {
            arrAnswers[i].status = 0
            arrSubAnswers.removeAll()
            tblView_SubQuestions.reloadData()
        }
        if arrAnswers[indexPath.row].status == 0 {
            arrAnswers[indexPath.row].status = 1
            
            strAnswers = arrAnswers[indexPath.row].strAnswer
            strAnswerId = arrAnswers[indexPath.row].answerId
            fetchMeasurementSubQuestionDataOnOptionClick(ansId: Int(arrAnswers[indexPath.row].answerId)!, answer: arrAnswers[indexPath.row].strAnswer, obAnswer: obAnswer)
       //     fetchSubQuestionData(ansId: Int(arrAnswers[indexPath.row].answerId)!, answer: arrAnswers[indexPath.row].strAnswer)
            // getNormalSubQuestionsAfterSave(ansId: Int(obAnswer.savedAnswer_id!)!, answer: obAnswer.savedAnswer!, questionId: obAnswer.questionId!)
        }
        if strAnswerId.first == "," {
            strAnswerId.remove(at: strAnswerId.startIndex)
        }
        obAnswer.isUpdate = 1
        obAnswer.savedAnswer = strAnswers
        obAnswer.savedAnswer_id = strAnswerId
        tblView_Measurement.reloadData()
    }
    
    func selectInspectorAnswerOnRadioClick(indexPath: IndexPath) {
        
        var strAnswers = String()
        var strAnswerId = String()
        for i in  0..<arrInspectorAnswers.count {
            arrInspectorAnswers[i].status = 0
            
        }
        if arrInspectorAnswers[indexPath.row].status == 0 {
            arrInspectorAnswers[indexPath.row].status = 1
            
            strAnswers = arrInspectorAnswers[indexPath.row].strAnswer
            strAnswerId = arrInspectorAnswers[indexPath.row].answerId
            
        }
        if strAnswerId.first == "," {
            strAnswerId.remove(at: strAnswerId.startIndex)
        }
        obInspectorAnswer?.isUpdate = 1
        obInspectorAnswer?.savedAnswer = strAnswers
        obInspectorAnswer?.savedAnswer_id = strAnswerId
        tblView_Inspector.reloadData()
    }
    
}
