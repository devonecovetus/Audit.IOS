//
//  ContactUsViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController {
    //MARK: Variables & Outlets
    
    @IBOutlet weak var btn_Send: UIButton!
    @IBOutlet weak var tv_Description: UITextView!
    @IBOutlet weak var tf_Subject: DesignableUITextField!
    @IBOutlet weak var tf_Email: DesignableUITextField!
    @IBOutlet weak var tf_Name: DesignableUITextField!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Suggestion: UILabel!
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    //MARK: BUtton Actions:
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btn_Send(_ sender: Any) {
        if checkValidations().count > 0 {
            self.showAlertViewWithMessage(checkValidations(), vc: self)
        } else {
            submitContactUsRequest()
        }
    }
    
    //MARK: Supporting Functions:
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_Name.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_Email.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_Subject.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tv_Description.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Suggestion.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Send.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_Name.textAlignment = NSTextAlignment.right
            tf_Email.textAlignment = NSTextAlignment.right
            tf_Subject.textAlignment = NSTextAlignment.right
            tv_Description	.textAlignment = NSTextAlignment.right
        }
        
        tf_Name.placeholder = NSLocalizedString("NAME", comment: "")
        tf_Email.placeholder = NSLocalizedString("EMAIL", comment: "")
        tf_Subject.placeholder = NSLocalizedString("SUBJECT", comment: "")
        lbl_Title.text = NSLocalizedString("CONTACTUS", comment: "")
        lbl_Suggestion.text = NSLocalizedString("SUGGESTION", comment: "")
        btn_Send.setTitle(NSLocalizedString("Send", comment: ""), for: UIControlState.normal)
        
    }
    
    func checkValidations() -> String {
        var strMsg = String()
        
        if tf_Name.text?.count == 0 {
            strMsg = ValidationMessages.enterUserName
        } else if tf_Name.text?.count == 0 {
            strMsg = ValidationMessages.strEnterEmail
        } else if Validation.isValidEmail(testStr: tf_Email.text!) == false {
            strMsg = ValidationMessages.strEnterValidEmail
        } else if(tf_Subject.text?.count == 0) {
            strMsg = ValidationMessages.enterSubject
        } else if tv_Description.text.count == 0 || tv_Description.text == "Description"{
            strMsg = ValidationMessages.enterDescription
        }
        return strMsg
    }
    
    func submitContactUsRequest() {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(tf_Name.text, forKey: "fullname")
        dictP.setValue(tf_Email.text, forKey: "email")
        dictP.setValue(tf_Subject.text, forKey: "subject")
        dictP.setValue(tv_Description.text, forKey: "description")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.ContactUs, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
               let vc = MainStoryBoard.instantiateViewController(withIdentifier: "ThankYouViewController") as! ThankYouViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
    }
}

extension ContactUsViewController: UITextFieldDelegate {
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
        return true
    }
}

extension ContactUsViewController: UITextViewDelegate {
    
    // Textview Delegate Method
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text == "Description"
        {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text == ""
        {
            textView.textColor = UIColor.lightGray
            textView.text = "Description"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.autocorrectionType = .no
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        let currentCharacterCount = tv_Description.text?.count ?? 0
        let newLength = currentCharacterCount + text.count - range.length
        if(newLength <= ValidationConstants.MaxDescriptionLimit) {
            return true
        } else{
            return false
        }
    }

}
