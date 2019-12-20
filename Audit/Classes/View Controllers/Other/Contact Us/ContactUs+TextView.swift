//
//  ContactUs+TextView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 22/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension ContactUsViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == decs_str {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGray
            textView.text = decs_str
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.autocorrectionType = .no
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        let currentCharacterCount = tv_Description?.text?.count ?? 0
        let newLength = currentCharacterCount + text.count - range.length
        if(newLength <= ValidationConstants.MaxDescriptionLimit) {
            return true
        } else {
            return false
        }
    }
}
