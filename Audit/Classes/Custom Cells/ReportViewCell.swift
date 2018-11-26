//
//  ReportViewCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 30/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ReportViewCell: UITableViewCell {

    @IBAction func btn_DownloadFile(_ sender: Any) {
        
    }
    @IBOutlet weak var btn_DownloadFile: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var lbl_AssignedDate: UILabel!
    @IBOutlet weak var lbl_Name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setReportData(obReport: ReportModel) {
        lbl_Name.text = obReport.name
        lbl_AssignedDate.text = obReport.assignedDate
        lbl_Title.text = obReport.reportTitle
        lbl_Description.text = obReport.reportDescription
        
    }
    
}
