//
//  AuditHistoryViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 22/01/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class AuditHistoryViewController: UIViewController {
    //MARK: Variables & Outlets
    var intSelectedIndex: Int? = Int()
    var intAlertIndex: Int? = Int()
    var arrMyAuditList:[MyAuditListModel]? = [MyAuditListModel]()
    @IBOutlet weak var tblView: UITableView?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.arrMyAuditList = obSqlite.getAuditList(status: AuditStatus.Completed, fetchType: "syncCompleted")
        self.executeUIProcess {
            self.tblView?.reloadData()
        }
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
    // MARK: - Navigation
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Supporting Functions:
    func resetAuditForReAudit(index: Int) -> Bool {
        /**
         1. Reset the is_sync = 0 in Audit Answers table
         2.Reset the startsync = 0, sync_complete = 0, Audit_status =  pending in MyAuditList
         */
        return obSqlite.resetAuditForReAudit(auditId: (arrMyAuditList?[index].audit_id!)!)
    }
    
    func submitRequestForFinalizeSyned(intAuditId: Int?) {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(intAuditId, forKey: "audit_id")
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.FinallySync, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                obSqlite.updateAuditSyncedStatusAndPreview(auditId: intAuditId!, updateType: "auditFinalSync", isFinallySync: 1, auditorReport: "", inspectorReport:  "")
                self.viewWillAppear(true)
            }
        }
    }
}

