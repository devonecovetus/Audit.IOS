//
//  Menu+TableView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 20/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MF.setUpMenuContent().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceType.IS_PHONE ? 65 : 85
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menu_cell", for: indexPath) as! menu_cell
        cell.setUpMenuData(dict: MF.setUpMenuContent()[indexPath.row] as! NSDictionary)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.executeUIProcess {
            self.delegate?.redirectToSelectedIndex(indexPath: indexPath)
        }
    }
}
