//
//  EditProfileProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 20/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol EditProfileDelegate {
    func submitUpdateProfileRequest()
    func checkValidations() -> String
}

extension EditProfileViewController: EditProfileDelegate {
    func submitUpdateProfileRequest() {
        let imgBase64String = imgView_User?.image?.imageQuality(.low)?.base64EncodedString(options: .lineLength64Characters)
        
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(tf_FirstName?.text, forKey: "firstname")
        dictP.setValue(tf_LastName?.text, forKey: "lastname")
        dictP.setValue(tf_ContactNumber?.text, forKey: "phone")
        dictP.setValue(imgBase64String, forKey: "photo")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.UpdateUser, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
             //   SHOWALERT.showAlertViewWithDuration(ValidationMessages.profileUpdatedSuccessfully)
                self.showAlertViewWithDuration(ValidationMessages.profileUpdatedSuccessfully, vc: self)
                UserProfile.initWith(dict: (dictJson["response"] as! NSDictionary).mutableCopy() as! NSDictionary)
                let archiveUserData = NSKeyedArchiver.archivedData(withRootObject: (dictJson["response"] as! NSDictionary).mutableCopy())
                Preferences?.set(archiveUserData , forKey: "UserData")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
    }
    
    func checkValidations() -> String {
        var strMsg = String()
        
        if tf_FirstName?.text?.count == 0 {
            strMsg = ValidationMessages.validationMsgFirstName
        } else if tf_LastName?.text?.count == 0 {
            strMsg = ValidationMessages.validationMsgLastName
        } else if tf_ContactNumber?.text?.count == 0 {
            strMsg = ValidationMessages.validationMsgMobileNo
        } else if (tf_ContactNumber?.text?.count)! < ValidationConstants.MobileNumberLength {
            strMsg = ValidationMessages.validationMsgMobileNoLength
        }
        return strMsg
    }
}
