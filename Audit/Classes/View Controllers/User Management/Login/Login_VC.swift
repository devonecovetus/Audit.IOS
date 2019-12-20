//
//  Login_VC.swift
//  Audit
//
//  Created by Mac on 10/9/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class Login_VC: UIViewController {
    //MARK: Variables & Outlets
    var strUserType: String? = String()
    
    @IBOutlet weak var lbl_TypeText: UILabel!
    @IBOutlet weak var btn_SignIn: UIButton!
    @IBOutlet weak var imgView_Logo: UIImageView!
    @IBOutlet weak var btn_ForgotPassword: UIButton!
    @IBOutlet weak var btn_auditor: UIButton!
    @IBOutlet weak var btn_inspector: UIButton!
    @IBOutlet weak var tf_name: DesignableUITextField!
    @IBOutlet weak var tf_password: DesignableUITextField!
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lbl_TypeText.text = "Full Audit By"
        resetButtonBorder()
        setBorderBelowButton(button: btn_auditor)
        setUpLanguageSetting()
        strUserType = UserRoles.Auditor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        rememberMeSetting()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Supporting Function
    private func rememberMeSetting() {
        if Preferences?.value(forKey: "email") != nil && Preferences?.value(forKey: "password") != nil {
            tf_name.text = Preferences?.value(forKey: "email") as? String
            tf_password.text = Preferences?.value(forKey: "password") as? String
        }
    }
    
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
    }
    
    func isValidInput() -> String {
        var errorMessage = String()
        if tf_name.text?.count == 0 {
            errorMessage = ValidationMessages.validationMsgEmail
        } else if Validation.isValidEmail(testStr: tf_name.text!) == false {
            errorMessage = ValidationMessages.validationMsgValidEmail
        } else if tf_password.text?.count == 0 {
            errorMessage = ValidationMessages.validationMsgPassword
        }
        return errorMessage
    }
    
    func submitUserLoginRequest() {
        tf_name.resignFirstResponder()
        tf_password.resignFirstResponder()
        
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
        self.executeUIProcess({
        UserProfile.initWith(dict: dictJson["response"] as! NSDictionary)
        Preferences?.set(true, forKey: "isLogin")
        Preferences?.set(self.tf_name.text, forKey: "email")
        Preferences?.set(self.tf_password.text, forKey: "password")
        
        let archiveUserData = NSKeyedArchiver.archivedData(withRootObject: (dictJson["response"] as! NSDictionary).mutableCopy())
        Preferences?.set(archiveUserData , forKey: "UserData")
        
        let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
        navigationController.viewControllers = [MF.setUpTabBarView()]
        MF.animateViewNavigation(navigationController: navigationController)
            kAppDelegate.window?.rootViewController = navigationController
        })
    }
    
    //MARK: Button Actions:
    @IBAction func action_auditor_inspector(_ sender: UIButton) {
        resetButtonBorder()
        if sender.tag == 1 {
            strUserType = UserRoles.Auditor
            setBorderBelowButton(button: btn_auditor)
             lbl_TypeText.text = "Full Audit By"
        }else{
            strUserType = UserRoles.Inspector
            setBorderBelowButton(button: btn_inspector)
             lbl_TypeText.text = "Mini Audit By"
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
}

