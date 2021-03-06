//
//  ChatWithAdminViewController.swift
//  Audit
//
//  Created by Mac on 11/29/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ChatWithAdminViewController: UIViewController {
    //MARK: Variables & Outlets
    var decs_str = ""
    @IBOutlet weak var tf_name: DesignableUITextField!
    @IBOutlet weak var tv_description: UITextView!
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        decs_str = "Description"
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
        tf_name.text = UserProfile.name
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: BUtton Actions:
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Send(_ sender: Any) {
        if checkValidations().count > 0 {
            self.showAlertViewWithMessage(checkValidations(), vc: self)
        } else {
            submitChatRequest()
        }
    }
    
    //MARK: Supporting Functions:
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_name.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tv_description.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_name.textAlignment = NSTextAlignment.right
            tv_description.textAlignment = NSTextAlignment.right
            tv_description.text = "مرحبًا ، مسؤول أود الدردشة معك."
            decs_str = "وصف"
        }
    }
    
    func submitChatRequest() {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(tv_description.text, forKey: "msg")

        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.RequesttoAdminforChat, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func checkValidations() -> String {
        var strMsg = String()
        if tf_name.text?.count == 0 {
            strMsg = ValidationMessages.validationMsgUserName
        } else if tv_description.text.count == 0 || tv_description.text == decs_str {
            strMsg = ValidationMessages.validationMsgDescription
        }
        return strMsg
    }
}

extension ChatWithAdminViewController: UITextViewDelegate {
    
    // Textview Delegate Method
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == decs_str {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGray
            textView.text = decs_str
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.autocorrectionType = .no
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
