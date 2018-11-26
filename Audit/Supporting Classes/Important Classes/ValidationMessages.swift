//
//  ValidationMessages.swift
//  Tyvo
//
//  Created by Gourav Joshi on 04/02/17.
//  Copyright © 2017 Gourav Joshi. All rights reserved.
//
import UIKit
import Foundation


struct ValidationMessages {
    
    // MARK: Registration Msgs
    static let strEnterFirstName = NSLocalizedString("strEnterFirstName", comment: "")
    static let strEnterLastName = NSLocalizedString("strEnterLastName", comment: "")
    static let strEnterEmail = NSLocalizedString("strEnterEmail", comment: "")
    static let strEnterValidEmail = NSLocalizedString("strEnterValidEmail", comment: "")
    static let strEnterMobile = NSLocalizedString("strEnterMobile", comment: "")
    static let strMobileLength = NSLocalizedString("strMobileLength", comment: "")
    static let strValidMobile = NSLocalizedString("strValidMobile", comment: "")
    static let strOldPassword = NSLocalizedString("strOldPassword", comment: "")
    static let strNewPassword = NSLocalizedString("strNewPassword", comment: "")
    static let strEnterPassword = NSLocalizedString("strEnterPassword", comment: "")
    static let strEnterConfirmPassword = NSLocalizedString("strEnterConfirmPassword", comment: "")
    static let passwordNotMatch = NSLocalizedString("passwordNotMatch", comment: "")
    static let strPasswordLength = NSLocalizedString("strPasswordLength", comment: "")
    static let strEnterValidCredentials = NSLocalizedString("strEnterValidCredentials", comment: "")
    static let strInternalError = NSLocalizedString("strInternalError", comment: "")
    static let strLogout = NSLocalizedString("strLogout", comment: "")
    static let strServerError = NSLocalizedString("strServerError", comment: "")
    static let strInternetIsNotAvailable = NSLocalizedString("strInternetIsNotAvailable", comment: "")
    static let enterUserName = NSLocalizedString("enterUserName", comment: "")
    static let forgotPasswordMessage = NSLocalizedString("forgotPasswordMessage", comment: "")
    static let registrationSuccessFull = NSLocalizedString("registrationSuccessFull", comment: "")
    static let passwordChangedSuccesfully = NSLocalizedString("passwordChangedSuccesfully", comment: "")
    static let notificationStatusChanged = NSLocalizedString("notificationStatusChanged", comment: "")
    static let profileUpdatedSuccessfully = NSLocalizedString("profileUpdatedSuccessfully", comment: "")
    static let deleteNotification = NSLocalizedString("deleteNotification", comment: "")
    static let logoutSuccessfully = NSLocalizedString("logoutSuccessfully", comment: "")
    
    static let enterDescription = NSLocalizedString("enterDescription", comment: "")
    static let enterSubject = NSLocalizedString("enterSubject", comment: "")
    
    static let enterFolderName = NSLocalizedString("enterFolderName", comment: "")

}

class ShowAlert {
    func showAlertViewWithDuration(_ message: String)  {
        let alert = UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: nil)
        
        alert.alertViewStyle = .default
        alert.show()
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            alert.dismiss(withClickedButtonIndex: -1, animated: true)
        })
    }
    
    func showAlertViewWithMessage(_ strMessage: String){
        let alert = UIAlertView(title: "", message: strMessage, delegate: nil, cancelButtonTitle: "Ok")
        alert.alertViewStyle = .default
        alert.show()
    }
}
