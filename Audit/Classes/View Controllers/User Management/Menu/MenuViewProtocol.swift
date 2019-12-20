//
//  MenuViewProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 20/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol MenuViewDelegate {
    func disMissView()
    func submitLogoutRequest()
    func redirectToSelectedIndex(indexPath: IndexPath)
}

extension MenuViewController: MenuViewDelegate {
    func disMissView() {
        self.executeUIProcess {
            var menuFrame = self.view.frame
            UIView.animate(withDuration: 0.40, delay: 0, options: [.curveEaseOut], animations: {
                if kAppDelegate.strLanguageName == LanguageType.Arabic {
                    menuFrame.origin.x = menuFrame.width
                } else {
                    menuFrame.origin.x = -menuFrame.width
                }
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
    
    func submitLogoutRequest() {
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.Logout, methodType: 1, forContent: 1, OnView: self, withParameters: MF.initializeDictWithUserId()) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                self.clearUserAndAppSession()
                SHOWALERT.showAlertViewWithDuration(ValidationMessages.logoutSuccessfully)
            }
        }
    }
    
    func redirectToSelectedIndex(indexPath: IndexPath) {
        let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
        if (MF.setUpMenuContent()[indexPath.row] as! NSDictionary)["name"] as! String == MenuContent.Account {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController
            navigationController.viewControllers.append(vc!)
            MF.animateViewNavigation(navigationController: navigationController)
        } else if (MF.setUpMenuContent()[indexPath.row] as! NSDictionary)["name"] as! String == MenuContent.Report {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "ReportListViewController") as? ReportListViewController
            navigationController.viewControllers.append(vc!)
            MF.animateViewNavigation(navigationController: navigationController)
        } else if (MF.setUpMenuContent()[indexPath.row] as! NSDictionary)["name"] as! String == MenuContent.History {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "AuditHistoryViewController") as? AuditHistoryViewController
            navigationController.viewControllers.append(vc!)
            MF.animateViewNavigation(navigationController: navigationController)
        } else if (MF.setUpMenuContent()[indexPath.row] as! NSDictionary)["name"] as! String == MenuContent.Help {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "WebContentViewController") as? WebContentViewController
            vc?.strTitle = WebContentName.Help
            vc?.strLinkType = WebContentData.Help
            navigationController.viewControllers.append(vc!)
            MF.animateViewNavigation(navigationController: navigationController)
        } else if (MF.setUpMenuContent()[indexPath.row] as! NSDictionary)["name"] as! String == MenuContent.Logout {
            self.executeUIProcess {
                self.logout()
            }
        }
        
        /// This code manage the condition for logout feature, if we click logout then menu view will not dismissed
        if (MF.setUpMenuContent()[indexPath.row] as! NSDictionary)["name"] as! String !=  MenuContent.Logout {
            navigationController.isNavigationBarHidden = true
            kAppDelegate.window?.rootViewController = navigationController
            disMissView()
        }
    }
    
}
