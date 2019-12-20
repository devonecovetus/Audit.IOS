//
//  ReportList+SearchBar.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension ReportListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        flagIsSearch = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        flagIsSearch = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        flagIsSearch = false;
        self.tblView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        flagIsSearch = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (arrReportList?.count)! > 0 {
            
            arrSearch = (arrReportList?.filter({ (obReport) -> Bool in
                let tmp: NSString = obReport.reportTitle! as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            }) )
            
            if searchText.count == 0 {
                flagIsSearch = false;
            } else {
                flagIsSearch = true
            }
            self.tblView?.reloadData()
        }
    }
}
