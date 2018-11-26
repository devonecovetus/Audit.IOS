//
//  Login_VC.swift
//  Audit
//
//  Created by Mac on 10/9/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class Login_VC: UIViewController {
    
    @IBOutlet weak var btn_SignIn: UIButton!
    @IBOutlet weak var imgView_Logo: UIImageView!
    @IBOutlet weak var btn_ForgotPassword: UIButton!
    var strUserType: String? = String()
    @IBOutlet weak var btn_auditor: UIButton!
    @IBOutlet weak var btn_inspector: UIButton!

    @IBOutlet weak var tf_name: DesignableUITextField!
    @IBOutlet weak var tf_password: DesignableUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resetButtonBorder()
        setBorderBelowButton(button: btn_auditor)
        setUpLanguageSetting()
        strUserType = UserRoles.Auditor
    }
    
    //MARK: Supporting Function
    private func resetButtonBorder() {
        btn_inspector.addBottomBorderWithColor(color: UIColor.white, height: CGFloat(2.0))
        btn_auditor.addBottomBorderWithColor(color: UIColor.white, height: CGFloat(2.0))
    }
    
    private func setBorderBelowButton(button: UIButton) {
        button.addBottomBorderWithColor(color: CustomColors.themeColorGreen, height: CGFloat(2.0))
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_name.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_password.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_Logo.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_inspector.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_auditor.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_ForgotPassword.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_SignIn.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_name.textAlignment = NSTextAlignment.right
            tf_password.textAlignment = NSTextAlignment.right
        }
        
        tf_name.placeholder = NSLocalizedString("Email", comment: "")
        tf_password.placeholder = NSLocalizedString("Password", comment: "")
        btn_auditor.setTitle(NSLocalizedString("AuditorLogin", comment: ""), for: UIControlState.normal)
        btn_inspector.setTitle(NSLocalizedString("InspectorLogin", comment: ""), for: UIControlState.normal)
        btn_SignIn.setTitle(NSLocalizedString("SignIn", comment: ""), for: UIControlState.normal)
        btn_ForgotPassword.setTitle(NSLocalizedString("ForgotPassword", comment: ""), for: UIControlState.normal)
    }
    
    @IBAction func action_auditor_inspector(_ sender: UIButton) {
        resetButtonBorder()
        if sender.tag == 1 {
            strUserType = UserRoles.Auditor
            setBorderBelowButton(button: btn_auditor)
        }else{
            strUserType = UserRoles.Inspector
            setBorderBelowButton(button: btn_inspector)
        }
    }
    
    @IBAction func btn_ForgotPassword(_ sender: Any) {
        let vc = MainStoryBoard.instantiateViewController(withIdentifier: "ForgotPassword_VC") as? ForgotPassword_VC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func action_signin(_ sender: Any) {
        if isValidInput().count > 0 {
            showAlertViewWithMessage(isValidInput(), vc: self)
        } else {
            submitUserLoginRequest()
        }
    }
    
    // MARK: Helper Methods validations
    func isValidInput() -> String {
        var errorMessage = String()
        if tf_name.text?.count == 0 {
            errorMessage = ValidationMessages.strEnterValidCredentials
        } else if Validation.isValidEmail(testStr: tf_name.text!) == false {
            errorMessage = ValidationMessages.strEnterValidEmail
        } else if tf_password.text?.count == 0 {
            errorMessage = ValidationMessages.strEnterValidCredentials
        }
        return errorMessage
    }
    
    func submitUserLoginRequest() {
        let dictP = NSMutableDictionary()
        dictP.setValue(tf_name.text, forKey: "email")
        dictP.setValue(tf_password.text, forKey: "password")
        dictP.setValue(kAppDelegate.strDeviceToken, forKey: "devicetoken")
        dictP.setValue(ValidationConstants.DeviceType, forKey: "platform")
        dictP.setValue(kAppDelegate.strLanguageName, forKey: "lang")
        dictP.setValue(strUserType, forKey: "role")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.UserLogin, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                self.setFeaturesAfterLogin(dictJson: dictJson)
            }
        }
    }
    
    func setFeaturesAfterLogin(dictJson: NSDictionary) {
        UserProfile.initWith(dict: dictJson["response"] as! NSDictionary)
        obSqlite.insertUserProfileData1(obUser: UserProfile)
        Preferences.set(true, forKey: "isLogin")
        let archiveUserData = NSKeyedArchiver.archivedData(withRootObject: (dictJson["response"] as! NSDictionary).mutableCopy())
        Preferences.set(archiveUserData , forKey: "UserData")
        let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
        navigationController.viewControllers = [MF.setUpTabBarView()]
        MF.animateViewNavigation(navigationController: navigationController)
        kAppDelegate.window?.rootViewController = navigationController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension Login_VC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}
