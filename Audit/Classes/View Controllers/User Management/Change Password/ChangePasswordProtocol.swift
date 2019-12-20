//
//  ChangePasswordProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 20/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol ChangePasswordDelegate {
    func backToPreviousScreen()
    func redirectToLoginScreen()
}

extension ChangePasswordViewController: ChangePasswordDelegate {
    func redirectToLoginScreen() {
        self.executeUIProcess {
            var initialViewController1: Login_VC?
            initialViewController1 = MainStoryBoard.instantiateViewController(withIdentifier: "Login_VC") as? Login_VC
            let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
            navigationController.viewControllers = [initialViewController1!]
            kAppDelegate.window?.rootViewController = navigationController
        }
    }
    
    func backToPreviousScreen() {
        self.navigationController?.popViewController(animated: true)
        releasedUnusedMemory()
    }
    
   fileprivate func releasedUnusedMemory() {
        tf_OldPassword = nil
        tf_ConfirmPassword = nil
        tf_NewPassword = nil
        tf_OldPassword?.delegate = nil
        tf_ConfirmPassword?.delegate = nil
        tf_NewPassword?.delegate = nil
        view.removeAllSubViews()
    }
    
}
