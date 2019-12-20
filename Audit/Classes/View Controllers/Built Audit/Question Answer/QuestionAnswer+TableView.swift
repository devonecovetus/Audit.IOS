//
//  QuestionAnswer+TableView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 01/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension QuestionAnswerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblView {
            return arrNormalQuestions.count
        } else if tableView == tblView_Inspector {
            return arrInspectorAnswers.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblView {
        
        if arrNormalQuestions[indexPath.row].questionType == QuestionType.Text {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Text", for: indexPath) as! QuestionTypeCell
            cell.intIndex = indexPath.row
            cell.delegate = self
            cell.superAuditDelegate = self
            cell.setQuestionData(obQuestion: arrNormalQuestions[indexPath.row])
            return cell
        } else if arrNormalQuestions[indexPath.row].questionType == QuestionType.Radio {
            guard let cell: QuestionTypeCell = tableView.dequeueReusableCell(withIdentifier: "RadioType", for: indexPath) as? QuestionTypeCell else {
                return UITableViewCell()
            }
            
            //let cell = tableView.dequeueReusableCell(withIdentifier: "RadioType", for: indexPath) as! QuestionTypeCell
            cell.intIndex = indexPath.row
            cell.delegate = self
            cell.superAuditDelegate = self
            cell.setQuestionData(obQuestion: arrNormalQuestions[indexPath.row])
            return cell
        }  else if arrNormalQuestions[indexPath.row].questionType == QuestionType.CheckBox {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckBox", for: indexPath) as! QuestionTypeCell
            cell.intIndex = indexPath.row
            cell.delegate = self
            cell.superAuditDelegate = self
            cell.setQuestionData(obQuestion: arrNormalQuestions[indexPath.row])
            return cell
        } else if arrNormalQuestions[indexPath.row].questionType == QuestionType.DropDown {
            guard let cell: QuestionTypeCell = tableView.dequeueReusableCell(withIdentifier: "DropDown", for: indexPath) as? QuestionTypeCell else {
                return UITableViewCell()
            }
         //   let cell = tableView.dequeueReusableCell(withIdentifier: "DropDown", for: indexPath) as! QuestionTypeCell
            cell.intIndex = indexPath.row
            cell.superAuditDelegate = self
            cell.delegate = self
            cell.setQuestionData(obQuestion: arrNormalQuestions[indexPath.row])
            return cell
        } else if arrNormalQuestions[indexPath.row].questionType == QuestionType.TrueFalse {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrueFalse", for: indexPath) as! QuestionTypeCell
            cell.intIndex = indexPath.row
            cell.delegate = self
            cell.superAuditDelegate = self
            cell.setQuestionData(obQuestion: arrNormalQuestions[indexPath.row])
            return cell
        }  else if arrNormalQuestions[indexPath.row].questionType == QuestionType.PopUp {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Popup", for: indexPath) as! QuestionTypeCell
            cell.intIndex = indexPath.row
            cell.delegate = self
            cell.superAuditDelegate = self
            cell.setQuestionData(obQuestion: arrNormalQuestions[indexPath.row])
            return cell
        }
            ///Inspector  Feature
        } else if tableView == tblView_Inspector {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckUncheck_Cell", for: indexPath) as! CheckUncheck_Cell
            cell.setRadioData(obAns: arrInspectorAnswers[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblView_Inspector {
            var strAnswers = String()
            var strAnswerId = String()
            for i in  0..<arrInspectorAnswers.count {
                arrInspectorAnswers[i].status = 0
                tblView_Inspector.reloadData()
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
