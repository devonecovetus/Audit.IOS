//
//  Audit+TableView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 27/11/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension AuditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMyAuditList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAuditCell", for: indexPath) as! MyAuditCell
        cell.intIndex = indexPath.row
        cell.delegate = self
        if arrMyAuditList.count > 0 {
            cell.setMyAuditData(obAudit: arrMyAuditList[indexPath.row])
        }
        return cell
    }
}

extension AuditViewController: MyAuditDelegate {
    func refreshList(index: Int) {
        self.viewWillAppear(true)
    }
    
    func syncAudit(index: Int) {
    }
    
    func viewAudit(index: Int) {
        let arr = obSqlite.checkAnyBuiltAuditEntryExistOrNot()
        if arr[0] as! Bool == true {
            /**
             Here first we check history audit list and then check draft audit list
             */
            //print("history list = \(obSqlite.getAuditList(status: AuditStatus.Completed, fetchType: "needFinallySynced").count)")
            //print("draft list = \(obSqlite.getAuditList(status: 0, fetchType: "pendingComplete").count)")
            if obSqlite.getAuditList(status: AuditStatus.Completed, fetchType: "needFinallySynced").count > 0 { /// If any history audit exist
                intPopUpIndex = 1
                MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.SimpleAction, title:NSLocalizedString("Alert", comment: "") , message: NSLocalizedString("cannotDownloadNewAudit", comment: ""))
                
            } else if obSqlite.getAuditList(status: 0, fetchType: "pendingComplete").count > 0 {
                intPopUpIndex = 2
                MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.SimpleAction, title:NSLocalizedString("Alert", comment: "") , message: NSLocalizedString("cannotDownloadAudit", comment: ""))
                
            } else {
                view_Option.alpha = 1.0
                 imgView_Audit.image = UIImage(named: "ic_cameracolor")
                intAuditId = arrMyAuditList[index].audit_id!
                self.getCountryList()
            }
        } else {
            imgView_Audit.image = UIImage(named: "ic_cameracolor")
            view_Option.alpha = 1.0
            intAuditId = arrMyAuditList[index].audit_id!
            self.performSelector(inBackground: #selector(self.getCountryList), with: nil)
        }
    }
    
    

}
