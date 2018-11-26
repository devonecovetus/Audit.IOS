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
}

class MyAuditCell: UITableViewCell {

    var delegate: MyAuditDelegate?
    var intIndex = Int()
    
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
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setMyAuditData(obAudit: MyAuditListModel) {
//        self.imgView_Status.backgroundColor = MF.setAuditStatus(intStatus: obAudit.auditStatus!)
//
//        lbl_AssignDate.text = obAudit.assignDate
//        lbl_Title.text = obAudit.title
//        lbl_TargetDate.text = obAudit.targetDate
        
        self.contentView.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_TitleText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AssignText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_TargetText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AssignDate.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_TargetDate.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        lbl_TitleText.text = String(format: "%@:", NSLocalizedString("Title", comment: ""))
        lbl_AssignText.text = String(format: "%@:", NSLocalizedString("Assign By", comment: ""))
        lbl_TargetText.text = String(format: "%@:", NSLocalizedString("Target Date", comment: ""))
        btn_ViewAudit.setTitle(NSLocalizedString("View", comment: ""), for: UIControlState.normal)
        
        lbl_Title.text = obAudit.audit_title!
        lbl_AssignDate.text = obAudit.assign_by!
        lbl_TargetDate.text = obAudit.target_date!
        setAuditStatus(status: obAudit.audit_status!)
    }
    
    private func setAuditStatus(status: Int) {
        if status == AuditStatus.InComplete {
            imgView_Status.backgroundColor = UIColor.red
        } else if status == AuditStatus.Pending {
            imgView_Status.backgroundColor = UIColor.yellow
        } else if status == AuditStatus.Pending {
            imgView_Status.backgroundColor = CustomColors.themeColorGreen
        }
        
        
    }
    
    func setUpLangaugeSetting() {
        
        self.contentView.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_TitleText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AssignText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_TargetText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AssignDate.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_TargetDate.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        lbl_TitleText.text = String(format: "%@:", NSLocalizedString("Title", comment: ""))
        lbl_AssignText.text = String(format: "%@:  ", NSLocalizedString("Assign By", comment: ""))
        lbl_TargetText.text = String(format: "%@:", NSLocalizedString("TargetDate", comment: ""))
        btn_ViewAudit.setTitle(NSLocalizedString("View", comment: ""), for: UIControlState.normal)
    }
    
}
