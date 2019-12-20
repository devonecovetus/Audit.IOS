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
    var delegate: ContactUsDelegate?
    var decs_str = ""
    @IBOutlet weak var btn_Send: UIButton?
    @IBOutlet weak var tv_Description: UITextView?
    @IBOutlet weak var tf_Subject: DesignableUITextField?
    @IBOutlet weak var tf_Email: DesignableUITextField?
    @IBOutlet weak var tf_Name: DesignableUITextField?
    @IBOutlet weak var lbl_Title: UILabel?
    @IBOutlet weak var lbl_Suggestion: UILabel?
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        decs_str = "Description"
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tv_Description = nil
        tf_Name = nil
        tf_Email = nil
        tf_Subject = nil
        delegate = nil
        view.removeAllSubViews()
    }
    
    //MARK: BUtton Actions:
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btn_Send(_ sender: Any) {
        if (delegate?.checkValidations().count)! > 0 {
            self.showAlertViewWithMessage((delegate?.checkValidations())!, vc: self)
        } else {
            delegate?.submitContactUsRequest()
        }
    }
    
    //MARK: Supporting Functions:
    func setUpLanguageSetting() {
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_Name?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_Email?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_Subject?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tv_Description?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Suggestion?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Send?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_Name?.textAlignment = NSTextAlignment.right
            tf_Email?.textAlignment = NSTextAlignment.right
            tf_Subject?.textAlignment = NSTextAlignment.right
            tv_Description?.textAlignment = NSTextAlignment.right
            tv_Description?.text = "وصف"
            decs_str = "وصف"
            tv_Description?.textColor = UIColor.lightGray
        }
    }
    
    
}

extension ContactUsViewController: UITextFieldDelegate {    
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
