//
//  ReportViewCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 30/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol ReportDelegate {
    func downloadReport(index: Int)
}

class ReportViewCell: UITableViewCell {

    var intIndex: Int? = Int()
    var delegate: ReportDelegate?
    
    @IBAction func btn_DownloadFile(_ sender: Any) {
        delegate?.downloadReport(index: intIndex!)
    }
    @IBOutlet weak var btn_DownloadFile: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var lbl_AssignedDate: UILabel!
    @IBOutlet weak var lbl_Name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setReportData(obReport: ReportModel, setDelegate: ReportDelegate, indexPath: Int) {
        
        delegate = setDelegate
        intIndex = indexPath
        
        lbl_Name.attributedText = MF.setBoldTextInLabel(boldText: NSLocalizedString("Name", comment: ""), normalText: obReport.agentName!, fontSize: 20.0)
        
        let assignDate = dc.change(date: obReport.startDate!, format: "yyyy-MM-dd", to: "dd-MMM-yyyy")
        
        lbl_AssignedDate.attributedText = MF.setBoldTextInLabel(boldText: NSLocalizedString("AssignedDate", comment: ""), normalText: assignDate, fontSize: 20.0)
        lbl_Title.attributedText = MF.setBoldTextInLabel(boldText: NSLocalizedString("AuditTitle", comment: ""), normalText: obReport.reportTitle!, fontSize: 19.0)
        lbl_Description.attributedText = MF.setBoldTextInLabel(boldText: NSLocalizedString("Description", comment: ""), normalText: obReport.reportDescription!, fontSize: 17.0)
    }
    
}
