//
//  AuditHistory+TableView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension AuditHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (arrMyAuditList?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAuditCell", for: indexPath) as! MyAuditCell
        cell.intIndex = indexPath.row
        cell.reAuditDelegate = self
        if (arrMyAuditList?.count)! > 0 {
            cell.setMyAuditData(obAudit: arrMyAuditList?[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if arrMyAuditList?[indexPath.row].audit_status == AuditStatus.Completed  && arrMyAuditList?[indexPath.row].isSyncCompleted == 1 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            obSqlite.deleteSelectedAudit(auditId: arrMyAuditList?[indexPath.row].audit_id)
            viewWillAppear(true)
        }
    }
}
