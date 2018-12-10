//
//  DraftsViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 24/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class DraftsViewController: UIViewController {

    var arrDraftAuditList = [MyAuditListModel]()
    @IBOutlet weak var tblView: UITableView!
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        arrDraftAuditList = obSqlite.getAuditListWith(status: AuditStatus.Pending)
        tblView.reloadData()
    }
        
    func setUpLanguageSetting() {
        // self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        // lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
}

extension DraftsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDraftAuditList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAuditCell", for: indexPath) as! MyAuditCell
        cell.intIndex = indexPath.row
        cell.delegate = self
        if arrDraftAuditList.count > 0 {
            cell.setMyAuditData(obAudit: arrDraftAuditList[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension DraftsViewController: MyAuditDelegate {
    func viewAudit(index: Int) {
        let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltAuditViewController") as! BuiltAuditViewController
        vc.intAuditId = arrDraftAuditList[index].audit_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
