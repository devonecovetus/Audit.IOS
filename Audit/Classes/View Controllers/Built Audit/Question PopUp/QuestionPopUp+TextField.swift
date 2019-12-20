//
//  QuestionPopUp+TextField.swift
//  Audit
//
//  Created by Rupesh Chhabra on 02/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension QusetionPopupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) { }
    
    @objc func textFieldDidChange(textField: UITextField){
        
        if textField.text?.count == 0 {
            obAnswer.isUpdate = 0
        } else {
            obAnswer.isUpdate = 1
        }
        obAnswer.savedAnswer = textField.text
        obAnswer.savedAnswer_id = "0"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text!.count > 0 {
            obAnswer.savedAnswer = textField.text
            obAnswer.savedAnswer_id = "0"
            obAnswer.isUpdate = 1
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
