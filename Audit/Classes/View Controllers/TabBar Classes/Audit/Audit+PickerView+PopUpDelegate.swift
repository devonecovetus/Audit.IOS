//
//  Audit+PickerView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 27/11/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension AuditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: UIPickerViewDelegate Methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if intPickerStatus == 1 {
            return arrCountryList.count
        } else if intPickerStatus == 2 {
            return arrLanguageList.count
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if intPickerStatus == 1 {
            return (arrCountryList[row] as! NSDictionary)["country"] as? String
        } else {
            return (arrLanguageList[row] as! NSDictionary)["title"] as? String
        }
    }
}

extension AuditViewController: PopUpDelegate {
    func actionOnYes() {
        
        self.executeUIProcess({
            SVProgressHUD.show(withStatus: "Downloading Files\n\nProcessing the download, Please wait.....")
        })
        
        if auditType == 0 { /// MEANS a default audit data will be downloaed via file to json
            //    self.getFullAuditData(auditId: intAuditId)
            self.getLocationList(auditId: intAuditId)
        } else { /// means in as usual way
            self.getLocationList(auditId: intAuditId)
            //self.getLocationData(auditId: intAuditId)
        }
        
    }
    
    func actionOnNo() {
    }
    
    func actionOnOk() {
        if intPopUpIndex == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
                let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "AuditHistoryViewController") as? AuditHistoryViewController
                navigationController.viewControllers.append(vc!)
                MF.animateViewNavigation(navigationController: navigationController)
            }
        } else if intPopUpIndex == 2 {
            if kAppDelegate.intViewFlipStatus == 1 {
                self.tabBarController?.selectedIndex = 2
            } else{
                self.tabBarController?.selectedIndex = 4
            }
        }
    }
}
