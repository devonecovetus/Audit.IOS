//
//  BuiltSubAudit+Search.swift
//  Audit
//
//  Created by Rupesh Chhabra on 01/10/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit


extension BuiltSubAuditViewController: UISearchBarDelegate {
   
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
            self.colView_SubLocation?.reloadData()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            if searchBar.text!.count > 0 {
                flagIsSearch = true
            } else {
                flagIsSearch = false;
            }
            self.colView_SubLocation?.reloadData()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            
            if (arrSubLocationList.count) > 0 {
                
                arrSearch = (arrSubLocationList.filter({ (obReport) -> Bool in
                    let tmp: NSString = obReport.subLocationName! as NSString
                    let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                    return range.location != NSNotFound
                }) )
                
                if searchText.count == 0 {
                    flagIsSearch = false;
                } else {
                    flagIsSearch = true
                }
                self.colView_SubLocation?.reloadData()
            }
        }
    }

