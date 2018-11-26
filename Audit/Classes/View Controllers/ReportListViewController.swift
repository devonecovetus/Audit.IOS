//
//  ReportListViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 30/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ReportListViewController: UIViewController {
    var flagIsSearch: Bool? = Bool()
    var arrReport = NSMutableArray()
    var arrSearch = NSMutableArray()
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBAction func btn_DownloadAll(_ sender: Any) {
    }
    @IBOutlet weak var lbl_Title: UILabel!
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        arrReport = NSMutableArray()
        
    }
    
    // MARK: - Supporting Methods
    
    func getReportList() {
        ///API code here
    }

}

extension ReportListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flagIsSearch! {
            return arrSearch.count
        }
        return 10//arrReport.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportViewCell", for: indexPath) as! ReportViewCell
        if flagIsSearch! {
            cell.setReportData(obReport: arrSearch[indexPath.row] as! ReportModel)
        } else {
            if arrReport.count > 0 {
                cell.setReportData(obReport: arrReport[indexPath.row] as! ReportModel)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ReportListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        flagIsSearch = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        flagIsSearch = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        flagIsSearch = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        flagIsSearch = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if arrReport.count > 0 {
            arrSearch = arrReport.filter({ (text) -> Bool in
                let tmp: NSString = text as! NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            }) as! NSMutableArray
            if(arrSearch.count == 0){
                flagIsSearch = false;
            } else {
                flagIsSearch = true;
            }
            self.tblView.reloadData()
        }
    }
}
