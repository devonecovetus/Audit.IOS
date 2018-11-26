//
//  ChangePasswordViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 25/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    //MARK: Outlets and Variables
    @IBOutlet weak var imfView_Logo: UIImageView!
    
    @IBOutlet weak var btn_Submit: UIButton!
    @IBOutlet weak var lbl_Msg: UILabel!
    @IBOutlet weak var lbl_TItle: UILabel!
    @IBOutlet weak var tf_ConfirmPassword: DesignableUITextField!
    @IBOutlet weak var tf_NewPassword: DesignableUITextField!
    @IBOutlet weak var tf_OldPassword: DesignableUITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    //MARK: Button Actions:
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btn_Submit(_ sender: Any) {
        
        if checkValidations().count > 0 {
            self.showAlertViewWithMessage(checkValidations(), vc: self)
        } else {
            submitChangePasswordRequest()
        }
    }
   
    //MARK: Supporting Functions:
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imfView_Logo.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_OldPassword.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_NewPassword.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_ConfirmPassword.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_TItle.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Msg.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Submit.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_OldPassword.textAlignment = NSTextAlignment.right
            tf_NewPassword.textAlignment = NSTextAlignment.right
            tf_ConfirmPassword.textAlignment = NSTextAlignment.right
        }
        
        tf_OldPassword.placeholder = NSLocalizedString("OldPassword", comment: "")
        tf_NewPassword.placeholder = NSLocalizedString("NewPassword", comment: "")
        tf_ConfirmPassword.placeholder = NSLocalizedString("ConfirmPassword", comment: "")
        lbl_TItle.text = NSLocalizedString("TitleChangePassword", comment: "")
        lbl_Msg.text = NSLocalizedString("MsgChangePassword", comment: "")
        btn_Submit.setTitle(NSLocalizedString("Submit", comment: ""), for: UIControlState.normal)
    }
    
    func checkValidations() -> String {
        var strMsg = String()
        
        if tf_OldPassword.text?.count == 0 {
            strMsg = ValidationMessages.strOldPassword
        } else if tf_NewPassword.text?.count == 0 {
            strMsg = ValidationMessages.strNewPassword
        } else if (tf_NewPassword.text?.count)! < ValidationConstants.PasswordLength {
            strMsg = ValidationMessages.strPasswordLength
        } else if(tf_ConfirmPassword.text?.count == 0) {
            strMsg = ValidationMessages.strEnterConfirmPassword
        } else if tf_ConfirmPassword.text != tf_NewPassword.text {
            strMsg = ValidationMessages.strEnterConfirmPassword
        }
        return strMsg
    }
    
    func submitChangePasswordRequest() {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(tf_OldPassword.text, forKey: "current_password")
        dictP.setValue(tf_NewPassword.text, forKey: "new_password")
        dictP.setValue(tf_ConfirmPassword.text, forKey: "confirm_password")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.ChangePassword, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                SHOWALERT.showAlertViewWithDuration(dictJson["message"] as! String)
                
                var initialViewController1: Login_VC?
                initialViewController1 = MainStoryBoard.instantiateViewController(withIdentifier: "Login_VC") as? Login_VC
                let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
                navigationController.viewControllers = [initialViewController1!]
                kAppDelegate.window?.rootViewController = navigationController
                
            }
        }
    }
}

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
            
            let currentCharacterCount = tf_OldPassword.text?.count ?? 0
            let newLength = currentCharacterCount + string.count - range.length
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            return newLength <= ValidationConstants.MaxPasswordLength
        } else if textField == tf_NewPassword {
            
            let currentCharacterCount = tf_NewPassword.text?.count ?? 0
            let newLength = currentCharacterCount + string.count - range.length
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            return newLength <= ValidationConstants.MaxPasswordLength
        }
        return true
    }
}
