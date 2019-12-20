//
//  ChangePassword+TextField.swift
//  Audit
//
//  Created by Rupesh Chhabra on 20/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) { }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.isFirstResponder {
            if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
                return false
            }
        }
        if textField == tf_OldPassword {
            let currentCharacterCount = tf_OldPassword?.text?.count ?? 0
            let newLength = currentCharacterCount + string.count - range.length
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            return newLength <= ValidationConstants.MaxPasswordLength
        } else if textField == tf_NewPassword {
            let currentCharacterCount = tf_NewPassword?.text?.count ?? 0
            let newLength = currentCharacterCount + string.count - range.length
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            return newLength <= ValidationConstants.MaxPasswordLength
        }
        return true
    }
}
