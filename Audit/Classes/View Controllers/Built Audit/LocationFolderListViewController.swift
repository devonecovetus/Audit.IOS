//
//  LocationFolderListViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 23/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
/*
 This class provides folder name with subbfolder list for corresponding to location
 */
class LocationFolderListViewController: UIViewController {
    
    var flagIsAddSubFolder = false
    @IBOutlet var view_popover: UIView!
    @IBOutlet weak var tf_subfoldername: DesignableUITextField!
    @IBOutlet weak var tv_description: DesignableTextView!
    
    var arrLocationFolderList = [LocationSubFolderListModel]()
    @IBOutlet weak var lbl_MainLocation: UILabel!
    @IBOutlet weak var lbl_FolderName: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    var auditid = 0
    var locationid = 0
    var folderid = 0
    
    var str_mainlocation = ""
    var str_folderlocation = ""
    var selectedindex = 0

    @IBOutlet weak var btn_AddNew: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Create a padding view for padding on left
        tf_subfoldername.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: tf_subfoldername.frame.height))
        tf_subfoldername.leftViewMode = .always
        
        view_popover.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_popover)
        view_popover.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchHappen(_:)))
        view_popover.addGestureRecognizer(tap)
        
        lbl_MainLocation.text = str_mainlocation
        lbl_FolderName.text = str_folderlocation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        kAppDelegate.currentViewController = self

        let delay = 1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.arrLocationFolderList = obSqlite.getLocationSubFolderList(locationId: self.locationid, auditId: self.auditid, folderId: self.folderid)
            self.tblView.reloadData()
        })
    }
    
    //MARK: Button Actions
    @IBAction func btn_AddNew(_ sender: Any) {
        flagIsAddSubFolder = true
        view_popover.alpha = 1.0
        tf_subfoldername.text = ""
        tv_description.text = ""
    }
    
    @IBAction func action_Done(_ sender: Any) {
        
        if flagIsAddSubFolder {
            if checkValidations().count > 0 {
                self.showAlertViewWithMessage(checkValidations(), vc: self)
            } else {
                self.addNewSubFolderEntry()
                
                view_popover.alpha = 0.0
                tf_subfoldername.text = ""
                tv_description.text = ""
                tf_subfoldername.resignFirstResponder()
                tv_description.resignFirstResponder()
            }
        } else {
            
            let primaryid = arrLocationFolderList[selectedindex].incId
            _ = obSqlite.updateSubFolderData(subfoldertitle: tf_subfoldername.text!, subfolderdescription: tv_description.text!, primaryId: primaryid!)
            view_popover.alpha = 0.0
            tf_subfoldername.text = ""
            tv_description.text = ""
            tf_subfoldername.resignFirstResponder()
            tv_description.resignFirstResponder()
            
            arrLocationFolderList = obSqlite.getLocationSubFolderList(locationId: locationid, auditId: auditid, folderId: folderid)
            tblView.reloadData()
        }
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_NavigateToBuiltAudit(_ sender: Any) {
        MF.navigateToBuiltAudit(vc: self)
    }
    
    //MARK: Supporting Functions:
    func addNewSubFolderEntry() {
        let obAudit = LocationSubFolderListModel()
        obAudit.initWith(locationId: locationid , auditId: auditid, folderId: folderid, name: tf_subfoldername.text!, description: tv_description.text!)
        obSqlite.insertLocationSubFolderListData(obFolder: obAudit)
        
        //Here refreshing or retriving the list
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.arrLocationFolderList = obSqlite.getLocationSubFolderList(locationId: self.locationid, auditId: self.auditid, folderId: self.folderid)
            let str = self.str_folderlocation.components(separatedBy: "(")
            self.lbl_FolderName.text = String(format: "%@ (%d)", str[0], self.arrLocationFolderList.count)
            self.tblView.reloadData()
        })
        
        kAppDelegate.intTotalFolderCount = kAppDelegate.intTotalFolderCount + 1
        let updatesuccess = obSqlite.updateLocationFolderCount(incId: self.folderid, folderCount:  kAppDelegate.intTotalFolderCount)
        if updatesuccess {
            kAppDelegate.intTotalLocationCount = kAppDelegate.intTotalLocationCount + 1
            _ = obSqlite.updateBuiltAuditLocationCount(count: kAppDelegate.intTotalLocationCount, locationId: self.locationid, auditId: self.auditid)
        }
        
    }
    
    func checkValidations() -> String {
        var strMsg = ""
        if tf_subfoldername.text?.count == 0 {
            strMsg = ValidationMessages.subFolderName
        } else if tv_description.text.count == 0 {
            strMsg = ValidationMessages.subFolderDescription
        }
        return strMsg
    }
    
    @objc func touchHappen(_ sender: UITapGestureRecognizer) {
        view_popover.alpha = 0.0
    }
    
    func setUpLanguageSetting() {
    }
    
    func getLocationFolderDetailList() {
    }
   
}

extension LocationFolderListViewController: FolderOperationDelegate {
    
    func viewFolderDetails(index: Int) {
        print(index)
        
        let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltSubAuditViewController") as! BuiltSubAuditViewController
        vc.intAuditId = arrLocationFolderList[index].auditId!
        
    }
    
    func archiveFolder(index: Int) {
        print(index)
    }
    
    func editFolder(index: Int) {
        print(index)
        flagIsAddSubFolder = false
        selectedindex = index
        view_popover.alpha = 1.0
        tf_subfoldername.text = arrLocationFolderList[index].subFolderName
        tv_description.text = arrLocationFolderList[index].subFolderDescription
    }
}

extension LocationFolderListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLocationFolderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderViewCell", for: indexPath) as! FolderViewCell
        cell.intIndex = indexPath.row
        cell.delegate = self
        cell.lbl_Title.text = arrLocationFolderList[indexPath.row].subFolderName
        cell.lbl_Description.text = arrLocationFolderList[indexPath.row].subFolderDescription

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //self.deleteSelectedFolder(indexPath: indexPath)
            obSqlite.deleteSelectedSubFolderData(incId: self.arrLocationFolderList[indexPath.row].incId!)
            self.arrLocationFolderList.remove(at: indexPath.row)
            
            kAppDelegate.intTotalFolderCount = kAppDelegate.intTotalFolderCount - 1
            let updatesuccess = obSqlite.updateLocationFolderCount(incId: self.folderid, folderCount:  kAppDelegate.intTotalFolderCount)
            if updatesuccess {
                kAppDelegate.intTotalLocationCount = kAppDelegate.intTotalLocationCount - 1
                _ = obSqlite.updateBuiltAuditLocationCount(count: kAppDelegate.intTotalLocationCount, locationId: self.locationid, auditId: self.auditid)
            }
            
            self.executeUIProcess {
                self.tblView.deleteRows(at: [indexPath], with: .fade)
            }
            
            let delay = 1 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.arrLocationFolderList = obSqlite.getLocationSubFolderList(locationId: self.locationid, auditId: self.auditid, folderId: self.folderid)
                let str = self.str_folderlocation.components(separatedBy: "(")
                self.lbl_FolderName.text = String(format: "%@ (%d)", str[0], self.arrLocationFolderList.count)
                self.tblView.reloadData()
            })
        }
    }
    
    func deleteSelectedFolder(indexPath: IndexPath) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 16.0)!]
        let messageAttrString = NSMutableAttributedString(string: "Are you sure you want to delete the selected folder. This will delete all the associated data. Would you like to continue ?", attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let okButton = UIAlertAction(title:"Yes", style: UIAlertActionStyle.default) { (UIAlertAction) in
            /// delete Query will be applied
            obSqlite.deleteSelectedSubFolderData(incId: self.arrLocationFolderList[indexPath.row].incId!)
            self.arrLocationFolderList.remove(at: indexPath.row)
            UIView.animate(withDuration: 0.2) { () -> Void in
                
                kAppDelegate.intTotalFolderCount = kAppDelegate.intTotalFolderCount - 1
                let updatesuccess = obSqlite.updateLocationFolderCount(incId: self.folderid, folderCount:  kAppDelegate.intTotalFolderCount)
                if updatesuccess {
                    kAppDelegate.intTotalLocationCount = kAppDelegate.intTotalLocationCount - 1
                    _ = obSqlite.updateBuiltAuditLocationCount(count: kAppDelegate.intTotalLocationCount, locationId: self.locationid, auditId: self.auditid)
                }
                 self.tblView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        let cancelButton = UIAlertAction(title:"No", style: UIAlertActionStyle.default) { (UIAlertAction) in
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}
