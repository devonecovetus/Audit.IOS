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
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        viewDidLoad()
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
        kAppDelegate.currentViewController = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeUnusedMemory()
    }
    
    func removeUnusedMemory() {
        tblView.delegate = nil
        tblView.dataSource = nil
        //view.removeAllSubViews()
        
        
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //print("MF.setUpSettingContent().count = \(MF.setUpSettingContent().count)")
        return MF.setUpSettingContent().count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return DeviceType.IS_PHONE ? 45.0 : 70.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view_Header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: DeviceType.IS_PHONE ? 40.0 : 65.0))
        view_Header.backgroundColor = UIColor.white
        let lbl_Name = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: DeviceType.IS_PHONE ? 40.0 : 65.0))
        lbl_Name.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Name.backgroundColor = UIColor.clear
        lbl_Name.text = (MF.setUpSettingContent()[section] as! NSDictionary)["SectionName"] as? String
        lbl_Name.font = UIFont.systemFont(ofSize: DeviceType.IS_PHONE ? 20.0 : 25.0)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_Name.textAlignment = NSTextAlignment.right
        }
        let btn_Switch = UISwitch(frame: CGRect(x: tableView.bounds.width - 70, y: 10, width: 75.0, height: DeviceType.IS_PHONE ? 36.0 : 45.0))
        
        if UserProfile.allPush == 0 {
            btn_Switch.isOn = false
        } else {
            btn_Switch.isOn = true
        }
        btn_Switch.onTintColor = CustomColors.themeColorGreen
      //  btn_Switch.tintColor = CustomColors.themeColorGreen
        btn_Switch.addTarget(self, action: #selector(setAppNotificationStatus(sender:)), for: .valueChanged)
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
        //print("section Part = \(MF.setUpSettingContent()[section] as! NSDictionary)")
        return ((MF.setUpSettingContent()[section] as! NSDictionary)["SectionArray"] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (MF.setUpSettingContent()[section] as! NSDictionary)["SectionName"] as? String
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceType.IS_PHONE ? 34.0 : 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsViewCell", for: indexPath) as! SettingsViewCell
        cell.intIndex = indexPath.row
        cell.delegate = self
        cell.cellIndex = indexPath
        if indexPath.section == 0 {
            let arrNotif = (MF.setUpSettingContent()[(0)] as! NSDictionary)
            let notifStatus = (arrNotif["NotificationStatus"] as! NSMutableArray)[indexPath.row] as! Int
            //print("notif Status = \(notifStatus)")
            cell.btn_Switch.setOn(Bool(truncating: notifStatus as NSNumber), animated: true)
        }
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
            vc?.strLinkType = WebContentData.AboutUs
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.TermsConditions {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "WebContentViewController") as? WebContentViewController
            vc?.strTitle = WebContentName.TermsAndConditions
            vc?.strLinkType = WebContentData.TermsAndConditions
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.Standars {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "WebContentViewController") as? WebContentViewController
            vc?.strTitle = WebContentName.Standards
            vc?.strLinkType = WebContentData.StandardsAndPractices
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.News {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "WebContentViewController") as? WebContentViewController
            vc?.strTitle = WebContentName.News
            vc?.strLinkType = WebContentData.News
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.ContactUs {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "ContactUsViewController") as? ContactUsViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.Help {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "WebContentViewController") as? WebContentViewController
            vc?.strTitle = WebContentName.Help
            vc?.strLinkType = WebContentData.Help
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if strSettingContent == SettingContent.Logout {
            executeUIProcess {
                self.logout()
            }
        }
    }
    
    func logout() {
        
        MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: NSLocalizedString("AppLogout", comment: "") , message: ValidationMessages.strLogout)
        
        let alert = UIAlertController(title: "", message: ValidationMessages.strLogout, preferredStyle: UIAlertControllerStyle.alert)
        let messageFont = [NSAttributedStringKey.font: UIFont(name: CustomFont.themeFont, size: 16.0)!]
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
     //   self.present(alert, animated: true, completion: nil)
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
    
    @objc func setAppNotificationStatus(sender: UISwitch) {
        let dictP = MF.initializeDictWithUserId()
        var token = ""
        if UserProfile.allPush == 1 {
            token = ""
        } else {
            token = kAppDelegate.strDeviceToken.count == 0 ? "sdjfgh43543kjsh47835" : kAppDelegate.strDeviceToken
        }
        dictP.setValue(token, forKey: "devicetoken")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.SetNotifySetting, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                UserProfile.auditPush = (dictJson["response"] as! NSDictionary)["audit_push"] as? Int
                UserProfile.reportPush = (dictJson["response"] as! NSDictionary)["report_push"] as? Int
                UserProfile.messagePush = (dictJson["response"] as! NSDictionary)["msg_push"] as? Int
                UserProfile.allPush = (dictJson["response"] as! NSDictionary)["push_all"] as? Int
                kAppDelegate.getAndSetUserDetailsInBackground()
                self.executeUIProcess({
                  self.tblView.reloadSections(IndexSet(arrayLiteral: 0), with: UITableViewRowAnimation.automatic)
                })
            }
        }
    }
    
    @objc func setAuditNotificationStatus(sender: UISwitch) {  }
    
    @objc func setReportNotificationStatus(sender: UISwitch) {  }
    
    @objc func setMessageNotificationStatus(sender: UISwitch) {   }
}

extension SettingsViewController: SettingsDelegate {
    func setNotificationOnOff(index: Int, status: Int) {
        //print("index \(index)")
        
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(MF.setUpNotificationStatusArray()[0], forKey: "audit_push")
        dictP.setValue(MF.setUpNotificationStatusArray()[1], forKey: "report_push")
        dictP.setValue(MF.setUpNotificationStatusArray()[2], forKey: "msg_push")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.SetNotificationStatusByType, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                UserProfile.auditPush = (dictJson["response"] as! NSDictionary)["audit_push"] as? Int
                UserProfile.reportPush = (dictJson["response"] as! NSDictionary)["report_push"] as? Int
                UserProfile.messagePush = (dictJson["response"] as! NSDictionary)["msg_push"] as? Int
                kAppDelegate.getAndSetUserDetailsInBackground()
                self.tblView.reloadSections(IndexSet(arrayLiteral: 0), with: UITableViewRowAnimation.automatic)
                
                if UserProfile.auditPush == 0  && UserProfile.reportPush == 0 && UserProfile.messagePush == 0 {
                    UserProfile.allPush = 0
                    self.viewWillAppear(true)
                }
            }
        }
    }
}

extension SettingsViewController: PopUpDelegate {
    func actionOnYes() {
        self.submitLogoutRequest()
    }
    
    func actionOnNo() {
    }
}
