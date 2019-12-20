//
//  QuestionAnswer+QuestionDelegate.swift
//  Audit
//
//  Created by Rupesh Chhabra on 01/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension QuestionAnswerViewController: QuestionDelegate, UIPopoverPresentationControllerDelegate {
    func removeLastObject(index: Int) {   }
    
    func showConfirmPopUpOnTextDescription(index: Int?, obAns: AuditAnswerModel) {
        intPopUpStatus = 1
        intQuestionIndex = index
        MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: "", message: NSLocalizedString("TextMessageAlert", comment: ""))
    }
    
    func cameraClick(index: Int, btn: UIButton) {
        photobtnclick = "question"
        globalindex = index
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        MF.openActionSheet(with: imagePicker!, and: self, targetFrame: CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0), isShowArrow: false)
    }
    
    func deletephotoClick(index: Int) {
        self.flagIsReloadTableView = true
        let obFM: FileDownloaderManager? = FileDownloaderManager()
        obFM?.deleteAuditImage(fileName: self.arrNormalQuestions[index].imgName!)
        self.arrNormalQuestions[index].imgName = ""
        self.arrNormalQuestions[index].isUpdate = 1
        reloadTablecell(reloadindex: index)
    }
    
    func openPriorityPickerView() {
        let storyboard = UIStoryboard(name: "UI", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "Prirority_VC") as? Prirority_VC {
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .popover
            navController.isNavigationBarHidden = true
            if let pctrl = navController.popoverPresentationController {
                navController.preferredContentSize = CGSize(width: 375, height: 200)
                pctrl.delegate = self
                pctrl.sourceView = self.view
                pctrl.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                pctrl.permittedArrowDirections = []
                viewController.callbackpriorityset = callbackpriorityset
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func priorityClick(index: Int, btn: UIButton) {
        globalindex = index
        globalbtn = btn
        openPriorityPickerView()
    }
    
    func callbackpriorityset(_ name:String, _ value:Int, _ selectedcolor:UIColor) -> () {
        if view_InspectorQuestion.alpha == 1.0 {
            btn_Priority.setTitle(name, for: .normal)
            btn_Priority.backgroundColor = selectedcolor
            obInspectorAnswer?.priority = value
            obInspectorAnswer?.isUpdate = 1
        } else {
            globalbtn.setTitle(name, for: .normal)
            globalbtn.backgroundColor = selectedcolor
            self.arrNormalQuestions[globalindex].priority = value
            self.arrNormalQuestions[globalindex].isUpdate = 1
            reloadTablecell(reloadindex: globalindex)
        }
    }
    
    func setMultipleAnswerData(index: Int, obAns: AuditAnswerModel) {
        self.arrNormalQuestions[index] = obAns
        reloadTablecell(reloadindex: index)
    }
    
    func setYesNoAnswerOnClick(index: Int, obAns: AuditAnswerModel) {
        self.arrNormalQuestions[index] = obAns
        reloadTablecell(reloadindex: index)
    }
    
    func setTextData(index: Int, obAns: AuditAnswerModel) {
        self.arrNormalQuestions[index] = obAns
        reloadTablecell(reloadindex: index)
    }
    
    func setQuestionDescription(index: Int, obAns: AuditAnswerModel) {
        
        func getDescriptionTextCount() -> Int {
            var strDesc = obAns.savedAnswer!.replacingOccurrences(of: " ", with: "")
            strDesc = strDesc.replacingOccurrences(of: "\n", with: "")
            return strDesc.count
        }
        if getDescriptionTextCount() == 0 {
            obAns.savedAnswer = ""
            obAns.isUpdate = 0
        }
        //print("index = \(index)")
        let flagIsExist = self.arrNormalQuestions.indices.contains(index)
        if flagIsExist {
            self.arrNormalQuestions[index] = obAns
            reloadTablecell(reloadindex: index)
        }
    }
    
    func setDataOnNextScreen(index: Int, obAns: AuditAnswerModel, selectedAnswer: String) {
        if obAns.questionType != QuestionType.PopUp {
            let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "QusetionPopupViewController") as! QusetionPopupViewController
            vc.selectedIndex = index
            vc.obAnswer = obAns /// SubAnswer of selected question fetched by quesry
            vc.obNormalAnswer = arrNormalQuestions[index] /// Normal question object passed
            //print("arrNormalQuestions[index] = \(arrNormalQuestions[index].question!)")
            vc.intQuestionCategoryType = QuestionCategory.Normal
            vc.strSelectedAnswer = selectedAnswer /// selected answer passed on fetched.
            vc.normalSubQuestionDataCallBack =  normalSubQuestionDataCallBack
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func reloadTablecell(reloadindex: Int) {
        
        let offset: CGPoint =  tblView.contentOffset
        if self.flagIsReloadTableView {
            self.flagIsReloadTableView = false
            
            let indexPath = IndexPath(row: reloadindex, section: 0)
            tblView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        } else {
            let indexPath = IndexPath(row: reloadindex, section: 0)
            tblView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
        tblView.layoutIfNeeded() // Force layout so things are updated before resetting the contentOffset.
        tblView.contentOffset = offset
    }
    
    func normalSubQuestionDataCallBack( selectedIndex: Int, obQuestion: AuditAnswerModel, arrSubAnswer: [AuditAnswerModel]) -> () {
        arrNormalQuestions[selectedIndex] =  obQuestion
        arrNormalSubAnswer = arrSubAnswer
        //print("arrSubAnswer = \(arrSubAnswer.count)")
        tblView.reloadData()
    }
    
    func measurementSubQuestionDataCallBack( selectedIndex: Int, obQuestion: AuditAnswerModel, arrSubAnswer: [AuditAnswerModel]) -> () {
        //print("obQuestion = \(obQuestion.savedAnswer)")
        arrMesurementQuestions[selectedIndex] =  obQuestion
        arrMeasurementSubAnswer = arrSubAnswer
        colView_Question.reloadData()
    }
    
    func superUserAuditDataCallBack(selectedIndex: Int, obInspector: AuditAnswerModel?) -> () {
        if (arrInspectorQuestions?.count)! > 0 {
            arrInspectorQuestions?[selectedIndex] = obInspector!
        }
    }
}
