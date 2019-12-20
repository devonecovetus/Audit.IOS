//
//  MyAuditCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 31/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol MyAuditDelegate {
    func viewAudit(index: Int)
    func syncAudit(index: Int)
    func refreshList(index: Int)
}

protocol ReAuditDelegate {
    func previewReport(index: Int)
    func reEditAudit(index: Int)
    func generateFinalReport(index: Int)
}

class MyAuditCell: UITableViewCell {

    @IBOutlet weak var btnSyncWidthConstraint: NSLayoutConstraint!
    
    
    @IBAction func btn_FinalReport(_ sender: Any) {
        reAuditDelegate?.generateFinalReport(index: intIndex)
    }
    @IBAction func btn_ReEditAudit(_ sender: Any) {
        reAuditDelegate?.reEditAudit(index: intIndex)
    }
    @IBAction func btn_Preview(_ sender: Any) {
        reAuditDelegate?.previewReport(index: intIndex)
    }
    @IBOutlet weak var view_ReAudit: UIView!
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var view_Progress: UIView!
    @IBAction func btn_Sync(_ sender: Any) {
        delegate?.syncAudit(index: intIndex)
    }
    @IBOutlet weak var btn_Sync: DesignableButton!
    var delegate: MyAuditDelegate?
    var reAuditDelegate: ReAuditDelegate?
    var intIndex = Int()
    private var intAuditId = Int()
    
    @IBAction func btn_ViewAudit(_ sender: Any) {
        delegate?.viewAudit(index: intIndex)
    }
    
    @IBOutlet weak var btn_ViewAudit: UIButton!
    @IBOutlet weak var lbl_TargetDate: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_AssignDate: UILabel!
    @IBOutlet weak var lbl_TargetText: UILabel!
    @IBOutlet weak var lbl_TitleText: UILabel!
    @IBOutlet weak var lbl_AssignText: UILabel!
    @IBOutlet weak var imgView_Status: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setUpLangaugeSetting()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setMyAuditData(obAudit: MyAuditListModel?) {
        
        intAuditId = (obAudit?.audit_id!)!
        lbl_Title.text = obAudit?.audit_title!
        lbl_AssignDate.text = obAudit?.assign_by!
    //    //print("obAudit?.assignDate = \(obAudit?.assignDate!)")
        if (obAudit?.assignDate?.count)! > 0 {
            let end_date = dc.change(date: (obAudit?.assignDate!)!, format: "yyyy-MM-dd", to: "dd-MMM-yyyy")
            lbl_TargetDate.text = end_date
        }
        
        if btn_Sync != nil {
            btn_Sync.alpha = 1.0
            btn_Sync.setImage(UIImage(named: "ic_cloud"), for: UIControlState.normal)
        }
        
        setAuditStatus(status: (obAudit?.audit_status!)!, syncStatus: obAudit!.isSyncCompleted!, isFinallySynced: (obAudit?.isFinallySynced!)!)
        setUpSyncView(obAudit: obAudit!)
        manageSyncOperation(obAudit: obAudit!)
        if obAudit?.isSyncCompleted == 0 {
            getAuditWorkCompletionStatus(obAudit: obAudit!)
        }
        if obAudit?.auditorLink?.count == 0 && obAudit?.inspectorLink?.count == 0 {
            //if btnPre
        }
        
        if (obAudit?.totalAnswersForSync!)! > 0 {
          //  btn_Sync.alpha = 1.0
        } else {
       //     btn_Sync.alpha = 0.0
        }
        
    }
    
    private func setAuditStatus(status: Int, syncStatus: Int, isFinallySynced: Int) {
        if btnSyncWidthConstraint != nil {
            btnSyncWidthConstraint.constant = 45.0
            btn_Sync.setTitle("", for: UIControlState.normal)
        }
        
      //  //print("index: = \(intIndex), status = \(status), syncStatus = \(syncStatus), isFinallySynced = \(isFinallySynced)")
        /**
         1. incomplete
         2. pending and temporary sync and not finally sync
         3. pending and temporary not sync
         4. completed and temporary synced
         5. completed and temporary sync (manages 2 cases)
         6. Completed and finally sync
         */
        
        //view_ReAudit.alpha = 0.0
        if isFinallySynced == 0 {
            if status == AuditStatus.InComplete {
                imgView_Status.backgroundColor = UIColor.red
            } else if status == AuditStatus.Pending && syncStatus == 1 && isFinallySynced == 0 {
                if btn_Sync != nil {
                    btn_Sync.alpha = 1.0
                }
                if btn_ViewAudit != nil {
                    btn_ViewAudit.alpha = 1.0
                }
                view_ReAudit.alpha = 1.0
                imgView_Status.backgroundColor = UIColor(red: 255/255.0, green: 186/255.0, blue: 91/255.0, alpha: 1.0)
            } else if status == AuditStatus.Pending && syncStatus == 0 {
                if btn_Sync != nil {
                    btn_Sync.alpha = 1.0
                }
                if btn_ViewAudit != nil {
                    btn_ViewAudit.alpha = 1.0
                }
                imgView_Status.backgroundColor = UIColor(red: 255/255.0, green: 186/255.0, blue: 91/255.0, alpha: 1.0)
            } else if status == AuditStatus.Completed && syncStatus == 0 {
                imgView_Status.backgroundColor = CustomColors.themeColorGreen
                if btn_Sync != nil {
                    btn_Sync.alpha = 1.0
                }
                
                if btn_ViewAudit != nil {
                    btn_ViewAudit.alpha = 1.0
                }
                
            } else if status == AuditStatus.Completed && syncStatus == 1 { //// This condition will help to show data in history.
                imgView_Status.backgroundColor = CustomColors.themeColorGreen
                if btn_Sync != nil {
                    btn_Sync.alpha = 0.0
                    btn_ViewAudit.alpha = 0.0
                    view_Progress.alpha = 1.0
                    progressBar.value = 100
                    btn_Sync.setImage(UIImage(named: "ic_cloud"), for: UIControlState.normal)
                } else { /// This condition will executes in the audit history section
                    view_ReAudit.alpha = 1.0
                }
            } /*else if status == AuditStatus.Pending && syncStatus == 1 && isFinallySynced == 0 { //// This condition will help to show data in history.
                    view_ReAudit.alpha = 1.0
            } */
        } else {
            view_ReAudit.alpha = 0.0
            imgView_Status.backgroundColor = CustomColors.themeColorGreen
        }
    }
    
    func setUpLangaugeSetting() {
        lbl_TitleText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AssignText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_TargetText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_Status.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)

        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AssignDate.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_TargetDate.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_ViewAudit.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        lbl_TitleText.text = NSLocalizedString("Title", comment: "")
        lbl_AssignText.text = NSLocalizedString("AssignBy", comment: "")
        lbl_TargetText.text = NSLocalizedString("AssignDate", comment: "")
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_Title.textAlignment = NSTextAlignment.right
            lbl_AssignDate.textAlignment = NSTextAlignment.right
            lbl_TargetDate.textAlignment = NSTextAlignment.right
            lbl_TitleText.textAlignment = NSTextAlignment.right
            lbl_AssignText.textAlignment = NSTextAlignment.right
            lbl_TargetText.textAlignment = NSTextAlignment.right
        }
    }
    
    func setUpSyncView(obAudit: MyAuditListModel) {
        if MF.isInternetAvailable() {
            if obAudit.isSynching! {
                view_Progress.alpha = 1.0
                //print("obAudit.syncProgress!= \(obAudit.syncProgress!)")
                progressBar.value = obAudit.syncProgress!
            } else {
                if view_Progress != nil {
                    view_Progress.alpha = 0.0
                }
            }
        } else {
            if view_Progress != nil {
                view_Progress.alpha = 0.0
            }
        }
    }
    
    func manageSyncOperation(obAudit: MyAuditListModel) {
        if obAudit.isSyncStarted == 1 {
            btn_ViewAudit.alpha = 0.0
            if btn_Sync != nil {
                btnSyncWidthConstraint.constant = 105.0
                btn_Sync.setTitle("  Resume  ", for: UIControlState.normal)
                btn_Sync.setImage(UIImage(), for: UIControlState.normal)
                btn_Sync.backgroundColor = CustomColors.themeColorGreen
            }
        }
    }
    
    private func getAuditWorkCompletionStatus(obAudit: MyAuditListModel) {
       
        var flagIsRefresh = false
        var totalCounts = Int()
        let arrQuestion = obSqlite.getAuditWorkingStatus(auditId: obAudit.audit_id!)
        if arrQuestion.count > 0 {
            for i in 0..<arrQuestion.count {
                totalCounts = totalCounts + Int((arrQuestion[i] as! NSDictionary)["isUpdate"] as! Int)
            }
            if arrQuestion.count == totalCounts {
                if obAudit.audit_status != AuditStatus.Completed {
                    flagIsRefresh = true
                    _ = obSqlite.updateAudit(auditId: intAuditId, updateType: "auditStatus", auditStatus: AuditStatus.Completed, countryId: 0, language: "", isSyncCompleted: 0, answersAreSynced: 0, answersForSync: 0)
                }
            } else {
                if obAudit.audit_status != AuditStatus.Pending {
                    flagIsRefresh = true
                    _ = obSqlite.updateAudit(auditId: intAuditId, updateType: "auditStatus", auditStatus: AuditStatus.Pending, countryId: 0, language: "", isSyncCompleted: 0, answersAreSynced: 0, answersForSync: 0)
                }
            }
           // //print("arrQuestion =\(arrQuestion.count), totalCount = \(totalCounts)")
            if flagIsRefresh {
                delegate?.refreshList(index: intIndex)
            }
        }
    }
}





