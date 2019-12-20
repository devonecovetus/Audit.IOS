//
//  Login+TextField.swift
//  Audit
//
//  Created by Rupesh Chhabra on 20/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension Login_VC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (tf_name.text?.count)! > 0 && (tf_password.text?.count)! > 0 {
            submitUserLoginRequest()
        }
        return textField.resignFirstResponder()
    }
}
