//
//  QuestionAnswer+TextView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 02/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension QuestionAnswerViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write something here..." {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGray
            textView.text = "Write something here..."
        }
        if textView.text.count > 0 {
             textView.textColor = UIColor.black
            
            arrNormalQuestions[intIndexInspector!].answerDescription = textView.text
            arrNormalQuestions[intIndexInspector!].isUpdate = 1
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
       // if textView.text.count > 0 {
            arrNormalQuestions[intIndexInspector!].answerDescription = textView.text
            arrNormalQuestions[intIndexInspector!].isUpdate = 1
        //}
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
