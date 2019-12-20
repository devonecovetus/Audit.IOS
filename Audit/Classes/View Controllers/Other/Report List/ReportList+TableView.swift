//
//  ReportList+TableView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension ReportListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flagIsSearch! {
            return (arrSearch?.count)!
        }
        return (arrReportList?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportViewCell", for: indexPath) as! ReportViewCell
        if flagIsSearch! {
            cell.setReportData(obReport: (arrSearch?[indexPath.row])!, setDelegate: self, indexPath: indexPath.row)
        } else {
            if (arrReportList?.count)! > 0 {
                cell.setReportData(obReport: (arrReportList?[indexPath.row])! , setDelegate: self, indexPath: indexPath.row)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {  }
}
