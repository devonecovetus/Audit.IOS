//
//  CustomPopUpViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 26/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
@objc protocol PopUpDelegate {
    @objc optional func checkUnCheck()
    @objc optional func actionOnYes()
    @objc optional func actionOnNo()
    @objc optional func actionOnOk()
}
class CustomPopUpViewController: UIViewController {

    @IBOutlet weak var viewYesNo: UIStackView!
    var popUpDelegate: PopUpDelegate?
    @IBOutlet weak var btn_Ok: UIButton!
    @IBOutlet weak var viewOk: UIStackView!
    @IBOutlet weak var spacing_okbtn_constraint: NSLayoutConstraint!
    @IBOutlet weak var btn_No: UIButton!
    @IBOutlet weak var spacing_Yesno_constraint: NSLayoutConstraint!
    @IBOutlet weak var btn_Yes: UIButton!
    @IBOutlet weak var btn_DontShow: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Message: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewYesNo.alpha = 0.0
        viewOk.alpha = 0.0
   //     btn_Ok.alpha = 0.0
        btn_DontShow.alpha = 0.0
        // Do any additional setup after loading the view.
        setUpLanguageSetting()
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Message.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Ok.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Yes.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_No.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        viewYesNo.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        viewOk.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Ok.setTitle(NSLocalizedString("Ok", comment: ""), for: UIControlState.normal)
        btn_No.setTitle(NSLocalizedString("No", comment: ""), for: UIControlState.normal)
        btn_Yes.setTitle(NSLocalizedString("Yes", comment: ""), for: UIControlState.normal)
    }
    
    // MARK: - Navigation

    @IBAction func btn_DontShow(_ sender: Any) {
        if kAppDelegate.currentViewController.className ==  String(describing: Home_VC.self) {
            let status = Preferences?.value(forKey: PreferencesKeys.questionScreen) as! Bool
            Preferences?.setValue(!status , forKey: PreferencesKeys.questionScreen)
        }
        setCheckUnCheckStatus(status: Preferences?.value(forKey: PreferencesKeys.questionScreen) as! Bool)
    }
    @IBAction func btn_No(_ sender: Any) {
        self.executeUIProcess {
            self.dismiss(animated: false, completion: nil)
            self.popUpDelegate?.actionOnNo!()
        }
    }
    @IBAction func btn_Yes(_ sender: Any) {
        self.executeUIProcess {
            self.dismiss(animated: false, completion: nil)
            self.popUpDelegate?.actionOnYes!()
        }
    }
    @IBAction func btn_Ok(_ sender: Any) {
        self.executeUIProcess {
            self.view.removeFromSuperview()
            self.dismiss(animated: false, completion: nil)
            self.popUpDelegate?.actionOnOk!()
        }
    }
    
    func ShowPopUpWithCheckUnCheck(title: String, message:String, delegate: UIViewController) {
        lbl_Title.text = title
        lbl_Message.text = message
      //  popUpDelegate = (delegate as! PopUpDelegate)
        viewYesNo.alpha = 1.0
        btn_DontShow.alpha = 1.0
    }
    
    func ShowPopUpWithOk(title: String, message:String) {
        lbl_Title.text = title
        lbl_Message.text = message
        //btn_Ok.alpha = 1.0
        viewOk.alpha = 1.0
        spacing_okbtn_constraint.constant = 40
        spacing_Yesno_constraint.constant = 40
    }
    
    func ShowPopUpWithOkAction(title: String, message:String, delegate: UIViewController) {
        lbl_Title.text = title
        lbl_Message.text = message
        popUpDelegate = (delegate as! PopUpDelegate)
        viewOk.alpha = 1.0
        spacing_okbtn_constraint.constant = 40
        spacing_Yesno_constraint.constant = 40
    }
    
    func ShowPopUpWithAction(title: String, message:String, delegate: UIViewController) {
        lbl_Title.text = title
        lbl_Message.text = message
        popUpDelegate = (delegate as! PopUpDelegate)
        viewYesNo.alpha = 1.0
        spacing_okbtn_constraint.constant = 40
        spacing_Yesno_constraint.constant = 40
    }
    
    func ShowPopUpToast(title: String, message:String, delegate: UIViewController) {
        lbl_Title.text = title
        lbl_Message.text = message
        viewYesNo.alpha = 0.0
        spacing_okbtn_constraint.constant = 0
        spacing_Yesno_constraint.constant = 0
    }
    
    private func setCheckUnCheckStatus(status: Bool) {
        //print("status = \(status)")
        if status == true {
            btn_DontShow.setImage(UIImage(named: "check_icon"), for: UIControlState.normal)
        } else {
            btn_DontShow.setImage(UIImage(named: "uncheck_icon"), for: UIControlState.normal)
        }
    }
    
}
