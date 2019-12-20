//
//  ForgotPassword_VC.swift
//  Audit
//
//  Created by Mac on 10/9/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ForgotPassword_VC: UIViewController {
    //MARK: Variable & Outlets
    var delegate: ForgotPasswordDelegate?
    @IBOutlet weak var lbl_Msg: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var imgView_Logo: UIImageView!
    @IBOutlet weak var tf_email: DesignableUITextField!
    @IBOutlet weak var btn_Submit: UIButton!
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
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
        
        if (delegate?.isValidInput().count)! > 0 {
            self.showAlertViewWithMessage((delegate?.isValidInput())!, vc: self)
        } else {
            tf_email.resignFirstResponder()
            delegate?.submitForgotPaswordRequest()
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
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_email.textAlignment = NSTextAlignment.right
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

extension ForgotPassword_VC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
