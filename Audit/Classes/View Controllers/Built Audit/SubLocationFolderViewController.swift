//
//  SubLocationFolderListViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 12/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class SubLocationFolderViewController: UIViewController {
    //MARK: Variables & outlets:
    var intAuditId = Int()
    var intLocationId = Int()
    var intFolderId = Int()
    var intSubFolderId = Int()
    var arrSubLocationSubFolder = [SubLocationSubFolderModel]()
    var arrSubLocationFolder = [BuiltAuditSubLocationModel]()
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lbl_Msg: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        setUpLanguageSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        arrSubLocationFolder = obSqlite.getBuiltAuditSubLocationList(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subFolderId: intSubFolderId)
        tblView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        arrSubLocationSubFolder = obSqlite.getSubLocationSubFolderList(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, sub_locationId: intSubFolderId , subFolderId: intSubFolderId)
    }
    
    //MARK: Supporting Functions
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.text = NSLocalizedString("BuiltAudit", comment: "")
        lbl_Msg.text = NSLocalizedString("ContentMessage", comment: "")
    }
    
    func removeUnusedMemory() {
        arrSubLocationSubFolder.removeAll()
        arrSubLocationSubFolder = [SubLocationSubFolderModel]()
        tblView.delegate = nil
        tblView.dataSource = nil
        self.view.removeAllSubViews()
    }
    
    //MARK: Button Actions:
    @IBAction func btn_Back(_ sender: Any) {
        removeUnusedMemory()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btn_NavigateToBuiltSubAudit(_ sender: Any) {
        removeUnusedMemory()
        MF.navigateToBuiltSubAudit(vc: self)
    }
    @IBAction func btn_NavigateToBuiltAudit(_ sender: Any) {
        removeUnusedMemory()
        MF.navigateToBuiltAudit(vc: self)
    }
}

extension SubLocationFolderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceType.IS_PHONE ? 70 : 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSubLocationFolder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubLocationFolderCell", for: indexPath) as! SubLocationFolderCell
        cell.intIndex = indexPath.row
        cell.delegate = self
        cell.lbl_Title.text = arrSubLocationFolder[indexPath.row].subLocationName!
        cell.lbl_Counter.text = String(arrSubLocationFolder[indexPath.row].subLocationCount!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension SubLocationFolderViewController: SubLocationFolderDelegate {
    func movetoNext(index: Int) {
        let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "SubLocationSubFolderListViewController") as! SubLocationSubFolderListViewController
        
        var arrSubFolderModel = [SubLocationSubFolderModel]()
        arrSubFolderModel = arrSubLocationFolder[index].arrFolders
        
        if arrSubFolderModel.count == 0 {
            let foldercount = arrSubLocationFolder[index].subLocationCount!
            
            for _ in 0..<(foldercount) {
                autoreleasepool {
                    let obAudit = SubLocationSubFolderModel()
                    var desc = arrSubLocationFolder[index].subLocationDescription
                    if arrSubLocationFolder[index].subLocationDescription!.count == 0 {
                        desc = "This is a description for \(arrSubLocationFolder[index].subLocationName!) folder"
                    }
                    
                    obAudit.initWith(auditId: arrSubLocationFolder[index].auditId!, locationId: arrSubLocationFolder[index].locationId!, subLocationId: arrSubLocationFolder[index].subLocationId!, folderId: arrSubLocationFolder[index].folderId!, subFolderId: arrSubLocationFolder[index].subFolderId!, subFolderName: arrSubLocationFolder[index].subLocationName!, subFolderDesc: desc!)
                    obSqlite.insertintoSubLocationSubFolderList(oblist: obAudit)
                }
            }
        } else {
            let previouscount = arrSubFolderModel.count
            let currentcount = arrSubLocationFolder[index].subLocationCount!
            
            if previouscount != currentcount {
                var foldercount = Int()
                /// Means user has decrease the quantity, in that case the data will be deleted
                if currentcount < previouscount {
                    
                    obSqlite.deleteSubLocationSubFolder(incId: 0, auditId: arrSubLocationFolder[index].auditId!, locationId: arrSubLocationFolder[index].locationId!, folderId: arrSubLocationFolder[index].folderId!, subFolderId: arrSubLocationFolder[index].subFolderId!, sub_locationId: arrSubLocationFolder[index].subLocationId!, deleteType: "subLocation")

                    foldercount = arrSubLocationFolder[index].subLocationCount!
                } else if currentcount > previouscount {
                    foldercount = currentcount - previouscount
                }
                
                for _ in 0..<(foldercount) {
                    autoreleasepool {
                        let obAudit = SubLocationSubFolderModel()
                        obAudit.initWith(auditId: arrSubLocationFolder[index].auditId!, locationId: arrSubLocationFolder[index].locationId!, subLocationId: arrSubLocationFolder[index].subLocationId!, folderId: arrSubLocationFolder[index].folderId!, subFolderId: arrSubLocationFolder[index].subFolderId!, subFolderName: arrSubLocationFolder[index].subLocationName!, subFolderDesc: arrSubLocationFolder[index].subLocationDescription!)
                        obSqlite.insertintoSubLocationSubFolderList(oblist: obAudit)
                    }
                }
            }
        }
        
        vc.intSubLocIncId = arrSubLocationFolder[index].incId!
        vc.strSubFolderName = arrSubLocationFolder[index].subLocationName!
        vc.strSubLocationName = arrSubLocationFolder[index].subLocationName!
        vc.intAuditId = arrSubLocationFolder[index].auditId!
        vc.intLocationId = arrSubLocationFolder[index].locationId!
        vc.intFolderId = arrSubLocationFolder[index].folderId!
        vc.intSubFolderId = arrSubLocationFolder[index].subFolderId!
        vc.intSubLocationId = arrSubLocationFolder[index].subLocationId!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
