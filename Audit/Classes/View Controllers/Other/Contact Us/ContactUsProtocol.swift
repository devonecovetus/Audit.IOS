//
//  ContactUsProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 22/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol ContactUsDelegate {
    func checkValidations() -> String
    func submitContactUsRequest()
}

extension ContactUsViewController: ContactUsDelegate {
    func checkValidations() -> String {
        var strMsg = String()
        if tf_Name?.text?.count == 0 {
            strMsg = ValidationMessages.validationMsgUserName
        } else if tf_Name?.text?.count == 0 {
            strMsg = ValidationMessages.validationMsgEmail
        } else if Validation.isValidEmail(testStr: (tf_Email?.text!)!) == false {
            strMsg = ValidationMessages.validationMsgValidEmail
        } else if(tf_Subject?.text?.count == 0) {
            strMsg = ValidationMessages.validationMsgSubject
        } else if tv_Description?.text.count == 0 || tv_Description?.text == decs_str {
            strMsg = ValidationMessages.validationMsgDescription
        }
        return strMsg
    }
    
    func submitContactUsRequest() {
        let dictP = MF.initializeDictWithUserId()
        self.executeUIProcess {
            dictP.setValue(self.tf_Name?.text, forKey: "fullname")
            dictP.setValue(self.tf_Email?.text, forKey: "email")
            dictP.setValue(self.tf_Subject?.text, forKey: "subject")
            dictP.setValue(self.tv_Description?.text, forKey: "description")
       
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.Contact, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                self.redirectToThankYouScreen()
            }
         }
        }
    }
    
    private func redirectToThankYouScreen() {
        self.executeUIProcess {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "ThankYouViewController") as! ThankYouViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
