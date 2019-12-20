//
//  BuiltAudit+Search.swift
//  Audit
//
//  Created by Rupesh Chhabra on 01/10/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension BuiltAuditViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text!.count > 0 {
            flagIsSearch = true;
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //flagIsSearch = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        flagIsSearch = false;
       // self.arrLocationList = self.arrLocationTempList
        self.colView_LocationList?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.count > 0 {
            flagIsSearch = true
        } else {
            flagIsSearch = false;
        }
        self.colView_LocationList?.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (arrLocationList.count) > 0 {
            
            arrSearch = (arrLocationList.filter({ (obReport) -> Bool in
                let tmp: NSString = obReport.locationName! as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            }) )
            
            if searchText.count == 0 {
                flagIsSearch = false;
            } else {
                flagIsSearch = true
            }
            self.colView_LocationList?.reloadData()
        }
    }
}
