//
//  SettingsViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 24/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    func setUpLanguageSetting() {
     //   self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
      //  lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
      //  lbl_Title.text = NSLocalizedString("TitleSetting", comment: "")
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("MF.setUpSettingContent().count = \(MF.setUpSettingContent().count)")
        return MF.setUpSettingContent().count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view_Header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 65.0))
        view_Header.backgroundColor = UIColor.white
        let lbl_Name = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 65.0))
        lbl_Name.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Name.backgroundColor = UIColor.clear
        lbl_Name.text = (MF.setUpSettingContent()[section] as! NSDictionary)["SectionName"] as? String
        lbl_Name.font = UIFont.systemFont(ofSize: 25.0)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_Name.textAlignment = NSTextAlignment.right
        }
        let btn_Switch = UISwitch(frame: CGRect(x: tableView.bounds.width - 70, y: 10, width: 75.0, height: 45.0))
        btn_Switch.isOn = true
        btn_Switch.onTintColor = CustomColors.themeColorGreen
        btn_Switch.offImage = UIImage(named: "toggle-black")
        view_Header.addSubview(btn_Switch)
        view_Header.addSubview(lbl_Name)
        
        if lbl_Name.text == SettingContent.Sections.PushNotification {
            btn_Switch.alpha = 1.0
        } else {
            btn_Switch.alpha = 0.0
        }
        
        return view_Header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("section Part = \(MF.setUpSettingContent()[section] as! NSDictionary)")
        return ((MF.setUpSettingContent()[section] as! NSDictionary)["SectionArray"] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (MF.setUpSettingContent()[section] as! NSDictionary)["SectionName"] as? String
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsViewCell", for: indexPath) as! SettingsViewCell
        cell.cellIndex = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = (MF.setUpSettingContent()[indexPath.section] as! NSDictionary)
        let strSettingContent = (section["SectionArray"] as! NSArray)[indexPath.row] as! String
       
        if strSettingContent == SettingContent.Notification {
            
        } else if strSettingContent == SettingContent.ChangePassword {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as? ChangePasswordViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.AboutUs {
             let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "WebContentViewController") as? WebContentViewController
            vc?.strTitle = WebContentName.AboutUs
            vc?.strLinkType = "https://www.google.com"
             self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.TermsConditions {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "WebContentViewController") as? WebContentViewController
            vc?.strTitle = WebContentName.TermsAndConditions
            vc?.strLinkType = "https://www.facebook.com"
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.Standars {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "WebContentViewController") as? WebContentViewController
            vc?.strTitle = WebContentName.Standards
            vc?.strLinkType = "https://www.facebook.com"
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.ContactUs {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "ContactUsViewController") as? ContactUsViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.Logout {
            logout()
        }
        
    }
    
    func logout() {
        let alert = UIAlertController(title: "", message: ValidationMessages.strLogout, preferredStyle: UIAlertControllerStyle.alert)
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 16.0)!]
        let messageAttrString = NSMutableAttributedString(string: ValidationMessages.strLogout, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let okButton = UIAlertAction(title:"Yes", style: UIAlertActionStyle.default) { (UIAlertAction) in
            
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.submitLogoutRequest()
            }
        }
        let cancelButton = UIAlertAction(title:"No", style: UIAlertActionStyle.default) { (UIAlertAction) in
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func clearUserAndAppSession() {
        disMissView()
        MF.logoutAndClearAllSessionData()
    }
    
    func submitLogoutRequest() {
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.Logout, methodType: 1, forContent: 1, OnView: self, withParameters: MF.initializeDictWithUserId()) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                self.clearUserAndAppSession()
                SHOWALERT.showAlertViewWithDuration(ValidationMessages.logoutSuccessfully)
            }
        }
    }
    
    func disMissView() {
        var menuFrame = self.view.frame
        UIView.animate(withDuration: 0.40, delay: 0, options: [.curveEaseOut], animations: {
            menuFrame.origin.x = -menuFrame.width
            self.view.frame     = menuFrame
        }) { (compelete) in
            self.view.removeFromSuperview()
            if DeviceType.IS_IPHONE_4_OR_LESS {
                self.parent?.parent?.dismiss(animated: true, completion: nil)
                self.dismiss(animated: false, completion: nil)
            } else {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}
