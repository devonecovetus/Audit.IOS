//
//  ChangePasswordViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 25/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    var delegate: ChangePasswordDelegate?
    
    //MARK: Outlets and Variables
    @IBOutlet weak var imfView_Logo: UIImageView?
    @IBOutlet weak var btn_Submit: UIButton?
    @IBOutlet weak var lbl_Msg: UILabel?
    @IBOutlet weak var lbl_TItle: UILabel?
    @IBOutlet weak var tf_ConfirmPassword: DesignableUITextField?
    @IBOutlet weak var tf_NewPassword: DesignableUITextField?
    @IBOutlet weak var tf_OldPassword: DesignableUITextField?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        IQKeyboardManager.sharedManager().enable = true
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
    }
    
    //MARK: Button Actions:
    @IBAction func btn_Back(_ sender: Any) {
        delegate?.backToPreviousScreen()
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
        imfView_Logo?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_OldPassword?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_NewPassword?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_ConfirmPassword?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_TItle?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Msg?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Submit?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_OldPassword?.textAlignment = NSTextAlignment.right
            tf_NewPassword?.textAlignment = NSTextAlignment.right
            tf_ConfirmPassword?.textAlignment = NSTextAlignment.right
        }
    }
    
    func checkValidations() -> String {
        var strMsg = String()
        if tf_OldPassword?.text?.count == 0 {
            strMsg = ValidationMessages.validationMsgOldPswd
        } else if tf_NewPassword?.text?.count == 0 {
            strMsg = ValidationMessages.validationMsgNewPswd
        } else if (tf_NewPassword?.text?.count)! < ValidationConstants.PasswordLength {
            strMsg = ValidationMessages.validationMsgPswdLength
        } else if(tf_ConfirmPassword?.text?.count == 0) {
            strMsg = ValidationMessages.validationMsgComfirmPswd
        } else if tf_ConfirmPassword?.text != tf_NewPassword?.text {
            strMsg = ValidationMessages.validationMsgPswdMatch
        }
        return strMsg
    }
    
    func submitChangePasswordRequest() {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(tf_OldPassword?.text, forKey: "current_password")
        dictP.setValue(tf_NewPassword?.text, forKey: "new_password")
        dictP.setValue(tf_ConfirmPassword?.text, forKey: "confirm_password")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.ChangePassword, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                SHOWALERT.showAlertViewWithDuration(dictJson["message"] as! String)
                self.executeUIProcess({
                    Preferences?.set(self.tf_NewPassword?.text, forKey: "password")
                })
                self.delegate?.redirectToLoginScreen()
            }
        }
    }
}

