//
//  AuditOverViewProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 05/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol AuditOverViewDelegate {
    func getAuditOverViewDetails()
    func AcceptRejectAudit(status:String)
    func manageAttachmentFiles(arrAttachment: NSArray)
}

extension AuditOverViewController: AuditOverViewDelegate {
    func getAuditOverViewDetails() {
        ///API Code here
        let dictP = NSMutableDictionary()
        dictP.setValue(UserProfile.id, forKey: "id")
        dictP.setValue(UserProfile.authToken, forKey: "auth_token")
        dictP.setValue(str_notify_id, forKey: "notify_id")
        dictP.setValue("Audit", forKey: "type")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.NotificationDetails, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means notification detail
                self.dictData = dictJson["response"] as? NSDictionary
                 self.executeUIProcess({
                if let dictAudit = self.dictData!["auditDetails"] as? NSDictionary {
                    self.setAuditOverViewDetail(dict: dictAudit)
                }
                if let dictAgent = self.dictData!["agentDetails"] as? NSDictionary {
                    self.setAgentDetail(dict: dictAgent)
                }
                if let dictPerson = self.dictData!["contactPerson"] as? NSDictionary {
                    self.setContactPerson(dict:dictPerson)
                }
                })
            }
        }
    }
    
    func AcceptRejectAudit(status:String) {
        
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue((dictData!["auditDetails"] as! NSDictionary)["id"], forKey: "audit_id")
        dictP.setValue(status, forKey: "status")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetAuditStatus, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means notification detail
                if status == "1" {
                    let obAudit = MyAuditListModel()
                    obAudit.initWith(dict: self.dictData!)
                    obSqlite.insertMyAuditList(obAudit: obAudit)
                    self.executeUIProcess({
                        let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
                        navigationController.viewControllers = [MF.setUpTabBarView(selectedIndex:4)]
                        MF.animateViewNavigation(navigationController: navigationController)
                        kAppDelegate.window?.rootViewController = navigationController
                    })
                } else {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
                        navigationController.viewControllers = [MF.setUpTabBarView(selectedIndex:0)]
                        MF.animateViewNavigation(navigationController: navigationController)
                        kAppDelegate.window?.rootViewController = navigationController
                    }
                    self.showAlertViewWithDuration(NSLocalizedString("AuditRejectedSuccessfully", comment: ""), vc: self)
                }
            }
        }
    }
    
    func manageAttachmentFiles(arrAttachment: NSArray) {
        if arrAttachment.count == 0 {
            imgView_File.image = UIImage.init(named: "")
            imgView_File.image = UIImage.init(named: "icon_pdf")
            let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showpdf(_:)))
            tapGestureRecognizer11.numberOfTapsRequired = 1
            imgView_File.addGestureRecognizer(tapGestureRecognizer11)
        } else {
            imgView_File.image = UIImage.init(named: "icon_pdf")
            self.arrFiles = arrAttachment.mutableCopy() as? NSMutableArray
            if arrAttachment.count > 1 {
                str_pdf = arrAttachment[0] as! String
                imgView_File.image = UIImage.init(named: "icon_pdf")
                let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showpdf(_:)))
                tapGestureRecognizer11.numberOfTapsRequired = 1
                imgView_File.addGestureRecognizer(tapGestureRecognizer11)
            } else {
                str_pdf = arrAttachment[0] as! String
                imgView_File.image = UIImage.init(named: "icon_pdf")
                let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showpdf(_:)))
                tapGestureRecognizer11.numberOfTapsRequired = 1
                imgView_File.addGestureRecognizer(tapGestureRecognizer11)
            }
        }
    }
}
