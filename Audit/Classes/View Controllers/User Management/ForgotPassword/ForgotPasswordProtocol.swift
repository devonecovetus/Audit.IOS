//
//  ForgotPasswordProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol ForgotPasswordDelegate {
    func isValidInput() -> String
    func submitForgotPaswordRequest()
}

extension ForgotPassword_VC: ForgotPasswordDelegate {
    func isValidInput() -> String {
        var errorMessage = String()
        if tf_email.text?.count == 0 {
            errorMessage = ValidationMessages.validationMsgEmail
        } else if Validation.isValidEmail(testStr: tf_email.text!) == false {
            errorMessage = ValidationMessages.validationMsgValidEmail
        }
        return errorMessage
    }
    
    func submitForgotPaswordRequest() {
        self.executeUIProcess {
            
            let dictP = NSMutableDictionary()
            dictP.setValue(self.tf_email.text, forKey: "email")
            
            OB_WEBSERVICE.getWebApiData(webService: WebServiceName.ForgotPassword, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
                if dictJson["status"] as? Int == 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.showAlertViewWithDuration(dictJson["message"] as! String, vc: self)
                }
            }
        }
    }
}
