//
//  AuditHistoryProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol AuditHistoryDelegate {
    
}

extension AuditHistoryViewController: ReAuditDelegate {
    
    
    func previewReport(index: Int) {
        /// User can preview the report that generated during synced audit
        if arrMyAuditList?[index].auditType == 0 { /// Normal audit
            openUrl(strUrl: (arrMyAuditList?[index].auditorLink!)!)
        } else { /// Super user audit
            openActionSheet(obAudit: arrMyAuditList?[index])
        }
    }
    
    func reEditAudit(index: Int) {
        let arrDraftAudits = obSqlite.getAuditList(status: AuditStatus.Completed, fetchType: "notSynced")
        if arrDraftAudits.count > 0  {
            MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Simple, title: "" , message: NSLocalizedString("SyncAuditAlert", comment: ""))
        } else {
            intAlertIndex = 1
            intSelectedIndex = index
            MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("ReauditAlert", comment: ""))
        }
    }
    
    func generateFinalReport(index: Int) {
         /// If user is confirm for the audit then he will generate the final audit report for all.
        intSelectedIndex = index
        intAlertIndex = 2
        MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("FinallySyncedAlert", comment: ""))
    }

    func openActionSheet(obAudit: MyAuditListModel?) {
         let optionMenu = UIAlertController(title: NSLocalizedString("ChoosePreview", comment: ""), message: NSLocalizedString("SelectPreviewType", comment: ""), preferredStyle: .actionSheet)
        let auditorAction = UIAlertAction(title: NSLocalizedString("AuditorReport", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            autoreleasepool {
                self.openUrl(strUrl: obAudit?.auditorLink!)
            }
        })
        
        let inspectorAction = UIAlertAction(title: NSLocalizedString("InspectorReport", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            autoreleasepool {
                self.openUrl(strUrl: obAudit?.inspectorLink!)
            }
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(auditorAction)
        optionMenu.addAction(inspectorAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.sourceView = self.view
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func openUrl(strUrl: String?) {
        if (strUrl?.count)! > 0 {
            if let url = URL(string: strUrl!) {
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            self.showAlertViewWithDuration("No file to preview", vc: self)
        }
    }
}

extension AuditHistoryViewController: PopUpDelegate {
    func actionOnYes() {
        if intAlertIndex == 1 {
            /// here user can reedit their synced audit.
            if self.resetAuditForReAudit(index: intSelectedIndex!) {
                self.executeUIProcess {
                    let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltAuditViewController") as! BuiltAuditViewController
                    vc.intAuditId = self.arrMyAuditList?[self.intSelectedIndex!].audit_id
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if intAlertIndex == 2 {
            self.submitRequestForFinalizeSyned(intAuditId: arrMyAuditList?[intSelectedIndex!].audit_id)
        }
    }
    
    func actionOnNo() { }
}
