//
//  LocationHeaderView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 31/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol ExpandableTableViewHeaderDelegate {
    func toggleSection(_ header: LocationHeaderView, section: Int)
    func methodContactUs(header: LocationHeaderView, section: Int, indexValue: Int)
}

class LocationHeaderView: UITableViewHeaderFooterView {

    @IBAction func btn_Edit(_ sender: Any) {
    }
    @IBOutlet weak var lbl_Count: UILabel!
    @IBOutlet weak var lbl_LocationName: UILabel!
    
}
