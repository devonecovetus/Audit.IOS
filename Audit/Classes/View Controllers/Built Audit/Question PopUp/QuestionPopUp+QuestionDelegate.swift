//
//  QuestionPopUp+QuestionDelegate.swift
//  Audit
//
//  Created by Rupesh Chhabra on 02/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension QusetionPopupViewController: QuestionDelegate, UIPopoverPresentationControllerDelegate {
    func showConfirmPopUpOnTextDescription(index: Int?, obAns: AuditAnswerModel) {
        intPopUpStatus = 1
        intQuestionIndex = index
        MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: "", message: NSLocalizedString("TextMessageAlert", comment: ""))
    }
    
    
    func setTextData(index: Int, obAns: AuditAnswerModel) {
        arrSubAnswers.append(obAns)
        tblView_SubQuestions.reloadData()
    }
    
    func removeLastObject(index: Int) {
        //print(" arrSubAnswers.count = \( arrSubAnswers.count), index = \(index)")
        
        if index == arrSubAnswers.count - 1 {
            
        } else {
          //  arrSubAnswers.removeLast()
            arrSubAnswers.removeSubrange(ClosedRange(uncheckedBounds: (lower: index + 1 , upper: arrSubAnswers.count - 1)))
            tblView_SubQuestions.reloadData()
        }
    }
    
    func setDataOnNextScreen(index: Int, obAns: AuditAnswerModel, selectedAnswer: String) {
        let arrLocal = arrSubAnswers
        for i in index..<arrLocal.count {
            //print(" i =\(i)")
        }
        if arrSubAnswers.count >= 2 {
        //    arrSubAnswers.removeLast()
        }
        arrSubAnswers.append(obAns)
        tblView_SubQuestions.reloadData()
    }
    
    func setYesNoAnswerOnClick(index: Int, obAns: AuditAnswerModel) {
        arrSubAnswers[index] = obAns
        tblView_SubQuestions.reloadData()
    }
    
    func selectAnswerFromDropDown(index: Int, obAns: AuditAnswerModel) { }
    
    func setQuestionDescription(index: Int, obAns: AuditAnswerModel) {  }
    
    func setQuestionPriority(index: Int, obAns: AuditAnswerModel) {  }
    
    func setQuestionImage(index: Int, obAns: AuditAnswerModel) { }
    
    func setMultipleAnswerData(index: Int, obAns: AuditAnswerModel) { }
    
    func selectAnswerFromDropDown(index: Int) {  }
    
    func setYesAnswerOnClick(index: Int) {
        //print("arrNornal = \(arrSubAnswers[index].savedAnswer)")
    }
    
    func setNoAnswerOnClick(index: Int) {
        //print("arrNornal = \(arrSubAnswers[index].savedAnswer)")
    }
    
    func priorityClick(index: Int, btn: UIButton) {
        globalindex = index
        globalbtn = btn
       openPriorityPickerView()
    }
    
    func callbackpriorityset( name:String,  value:Int, _ selectedcolor:UIColor) -> () {
        
        if globalbtn == btn_Priority {
            obAnswer.priority = value
            obAnswer.isUpdate = 1
            btn_Priority.setTitle(name, for: UIControlState.normal)
            btn_Priority.backgroundColor = selectedcolor
        } else if globalbtn == btn_InspectorPriority {
            obInspectorAnswer?.priority = value
            obInspectorAnswer?.isUpdate = 1
            btn_InspectorPriority.setTitle(name, for: UIControlState.normal)
            btn_InspectorPriority.backgroundColor = selectedcolor
        } else {
            globalbtn.setTitle(name, for: .normal)
            globalbtn.backgroundColor = selectedcolor
            self.arrSubAnswers[globalindex].priority = value
            let indexPath = IndexPath(item: globalindex, section: 0)
            self.tblView_SubQuestions.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func cameraClick(index: Int, btn: UIButton) {
        self.intImagePickingType = 2
        globalindex = index
        MF.openActionSheet(with: imagePicker, and: self, targetFrame: CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0), isShowArrow: false)
    }
    
    func deletephotoClick(index: Int) {
        self.arrSubAnswers[index].imgName = ""
        let indexPath = IndexPath(item: index, section: 0)
        self.tblView_SubQuestions.reloadRows(at: [indexPath], with: .none)
    }
}
