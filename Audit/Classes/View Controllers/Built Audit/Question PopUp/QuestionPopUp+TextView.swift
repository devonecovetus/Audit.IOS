//
//  QuestionPopUp+TextView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 02/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension QusetionPopupViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write something here..." {
            intPopUpStatus = 3
            MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: "", message: NSLocalizedString("TextMessageAlert", comment: ""))
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGray
            textView.text = "Write something here..."
        }
        if textView.text.count > 0 {
            obAnswer.answerDescription = textView.text
            obAnswer.isUpdate = 1
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            obAnswer.answerDescription = textView.text
            obAnswer.isUpdate = 1
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.autocorrectionType = .no
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension QusetionPopupViewController: PopUpDelegate {
    func actionOnYes() {
        if intPopUpStatus == 2 {
            view_TextDescription.alpha = 1.0
            if (obInspectorAnswer?.answerDescription?.count)! > 0  {
                tv_AuditorDescription?.text = obInspectorAnswer?.answerDescription
            }
        } else if intPopUpStatus == 3 {
            tv_Description.textColor = UIColor.black
            tv_Description.text = ""
        }
    }
    
    func actionOnNo() {
        if intPopUpStatus == 1 {
            self.view.endEditing(true)
            reloadTableCell(reloadindex: intQuestionIndex!)
        }
    }
    
}
