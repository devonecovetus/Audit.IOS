//
//  AuditViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 24/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class AuditViewController: UIViewController {

   // var arrMyAuditList = NSMutableArray()
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var btn_Sorting: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    var arrMyAuditList = [MyAuditListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
        
        arrMyAuditList = obSqlite.getAuditListWith(status: AuditStatus.InComplete)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    //    arrMyAuditList = NSMutableArray()
    //    getMyAuditList()
     //   tblView.rowHeight = UITableViewAutomaticDimension
    }
    
    //MARK: Button Actions:
    @IBAction func btn_Sorting(_ sender: Any) {
    }
    
    // MARK: - Supporting Methods
    
    func getMyAuditList() {
        /// API code here
    }

    func setUpLanguageSetting() {
       // self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
       // lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
}

extension AuditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMyAuditList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAuditCell", for: indexPath) as! MyAuditCell
        cell.intIndex = indexPath.row
        cell.delegate = self
        if arrMyAuditList.count > 0 {
            cell.setMyAuditData(obAudit: arrMyAuditList[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension AuditViewController: MyAuditDelegate {
    func viewAudit(index: Int) {
    }
    
    /*
    func viewAudit(index: Int) {
        let arr = obSqlite.checkAnyBuiltAuditEntryExistOrNot()
        if arr[0] as! Bool == true {
            if arr[1] as? Int == arrMyAuditList[index].audit_id {
                self.showAlertViewWithMessage("Data for this audit is already downloaded", vc: self)
            } else {
                self.showAlertViewWithMessage("You cannot download another audit data until you sync previous one", vc: self)
            }
        } else {
            getModulesSubModulesAndQuestionnaries(auditId: arrMyAuditList[index].audit_id!)
        }
    }
    
    func getModulesSubModulesAndQuestionnaries(auditId: Int) {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(auditId, forKey: "audit_id")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetQuestions, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                let arrResponse = dictJson["response"] as! NSArray
                
                for i in 0..<arrResponse.count {
                    let dictR = arrResponse[i] as! NSDictionary
                    let arrModules = dictR["Milti_lang_modules"] as! NSArray
                    for j in 0..<arrModules.count {
                        let dictM = arrModules[j] as! NSDictionary
                        print("dictM = \(dictM)")
                        
                        ///Saving Location obj
                        let obLocation = LocationModel()
                        obLocation.initWith(dict: dictM, auditId: auditId)
                        obSqlite.insertLocationData(obLocation: obLocation)
                        
                        /// Saving Sublocation Obj
                        let arrSubLocation = dictM["categories"] as! NSArray
                        for k in 0..<arrSubLocation.count {
                            let dictSubLoc = arrSubLocation[k]as! NSDictionary
                            let obSubLoc = SubLocationModel()
                            obSubLoc.initWith(dict: dictSubLoc, auditId: auditId, locationId: obLocation.locationId!)
                            obSqlite.insertSubLocationData(obSubLoc: obSubLoc)
                        }
                    }
                }
                
                /// This will update the audit list and audit status to incomplete to pending
                let arr = obSqlite.updateAuditWorkStatus(auditStatus: AuditStatus.Pending, auditId: auditId)
                
                if arr[0] as! Bool == true {
                    self.showAlertViewWithDuration(arr[1] as! String, vc: self)
                    self.arrMyAuditList = obSqlite.getAuditListWith(status: AuditStatus.InComplete)
                    self.tblView.reloadData()
                     
                }
            }
        }
    }
 */
}
