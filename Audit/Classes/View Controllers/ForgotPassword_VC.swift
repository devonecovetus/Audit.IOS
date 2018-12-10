//
//  ForgotPassword_VC.swift
//  Audit
//
//  Created by Mac on 10/9/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ForgotPassword_VC: UIViewController {
    
    @IBOutlet weak var lbl_Msg: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var imgView_Logo: UIImageView!
    @IBOutlet weak var tf_email: DesignableUITextField!

    @IBOutlet weak var btn_Submit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a padding view for padding on left
        tf_email.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: tf_email.frame.height))
        tf_email.leftViewMode = .always
        
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func action_submit(_ sender: Any) {
        
        if isValidInput().count > 0 {
            self.showAlertViewWithMessage(isValidInput(), vc: self)
        } else {
            tf_email.resignFirstResponder()
            self.submitForgotPaswordRequest()
        }
    }

    // MARK: Helper Methods validations
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_email.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Msg.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Submit.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_Logo.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        tf_email.placeholder = NSLocalizedString("Email Address", comment: "")
        lbl_Msg.text = NSLocalizedString("ForgotPasswordMsg", comment: "")
        lbl_Title.text = NSLocalizedString("ForgotPasswordTitle", comment: "")
        btn_Submit.setTitle(NSLocalizedString("Submit", comment: ""), for: UIControlState.normal)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_email.textAlignment = NSTextAlignment.right
        }
    }
    
    func isValidInput() -> String {
        var errorMessage = String()
        if tf_email.text?.count == 0 {
            errorMessage = ValidationMessages.strEnterEmail
        } else if Validation.isValidEmail(testStr: tf_email.text!) == false {
            errorMessage = ValidationMessages.strEnterValidEmail
        }
        return errorMessage
    }
    
    func submitForgotPaswordRequest() {
        
        let dictP = NSMutableDictionary()
        dictP.setValue(tf_email.text, forKey: "email")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.ForgotPassword, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationController?.popViewController(animated: true)
                }
                self.showAlertViewWithDuration(dictJson["message"] as! String, vc: self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ForgotPassword_VC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}
