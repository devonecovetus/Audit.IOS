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
    //MARK" Varibales & Outlets:
    var flagIsAddSubFolder = false
    var arrLocationFolderList = [LocationSubFolderListModel]()
    var auditid = 0
    var locationid = 0
    var folderid = 0
    var strPhoto = String()
    var str_mainlocation = ""
    var str_folderlocation = ""
    var selectedindex = 0
    
    @IBOutlet weak var lbl_SubTitle: UILabel!
    @IBOutlet weak var lbl_HeaderTitle: UILabel!
    @IBOutlet weak var bnt_Done: DesignableButton!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var lbl_FolderName: UILabel!
    @IBOutlet var view_popover: UIView!
    @IBOutlet weak var tf_subfoldername: DesignableUITextField!
    @IBOutlet weak var tv_description: DesignableTextView!
    @IBOutlet weak var lbl_MainLocation: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btn_AddNew: UIButton!
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.tableFooterView = UIView()
        self.setUpLanguageSetting()
        // Do any additional setup after loading the view.
        
        // Create a padding view for padding on left
        tf_subfoldername.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: tf_subfoldername.frame.height))
        tf_subfoldername.leftViewMode = .always
        view_popover.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_popover)
        view_popover.alpha = 0.0
        lbl_MainLocation.text = str_mainlocation
        kAppDelegate.strMainLocationName = str_mainlocation
        lbl_FolderName.text = str_folderlocation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.arrLocationFolderList = obSqlite.getLocationSubFolderList(locationId: self.locationid, auditId: self.auditid, folderId: self.folderid)
            self.tblView.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        obSqlite = SqliteDB.sharedInstance()
        arrLocationFolderList.removeAll()
        arrLocationFolderList = [LocationSubFolderListModel]()
    }
    
    func releaseUnusedMemory() {
        obSqlite = SqliteDB.sharedInstance()
        arrLocationFolderList.removeAll()
        arrLocationFolderList = [LocationSubFolderListModel]()
        tblView.delegate = nil
        tblView.dataSource = nil
        self.view.removeAllSubViews()
    }
    
    //MARK: Button Actions
    @IBAction func btn_HidePopOver(_ sender: Any) {
        tv_description.resignFirstResponder()
        tf_subfoldername.resignFirstResponder()
        view_popover.alpha = 0.0
    }
    
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
            obSqlite.updateLocationSubFolder(incId: primaryid!, isArchive: 0, base64Str: "", subfolderTitle: tf_subfoldername.text!, subfolderDescription: tv_description.text!, updateType: "titleDesc")
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
        releaseUnusedMemory()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_NavigateToBuiltAudit(_ sender: Any) {
        releaseUnusedMemory()
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
        let updatesuccess = obSqlite.updateLocationFolder(incId: self.folderid, folderCount: kAppDelegate.intTotalFolderCount, folderTitle: "", updateType: "count")
        if updatesuccess {
            kAppDelegate.intTotalLocationCount = kAppDelegate.intTotalLocationCount + 1
            obSqlite.updateBuiltAuditLocation(isModified: 0, count: kAppDelegate.intTotalLocationCount, auditId: self.auditid, locationId: self.locationid, updateType: "count")
        }
    }
    
    func checkValidations() -> String {
        var strMsg = ""
        if tf_subfoldername.text?.count == 0 {
            strMsg = ValidationMessages.subFolderName
        } else if getDescriptionTextCount() == 0 {
            strMsg = ValidationMessages.subFolderDescription
        }
        return strMsg
    }
    
    func getDescriptionTextCount() -> Int {
        var strDesc = tv_description.text.replacingOccurrences(of: " ", with: "")
        strDesc = strDesc.replacingOccurrences(of: "\n", with: "")
        return strDesc.count
    }
    
    @objc func touchHappen(_ sender: UITapGestureRecognizer) {
        
        tv_description.resignFirstResponder()
        tf_subfoldername.resignFirstResponder()
        self.view.endEditing(true)
        view_popover.alpha = 0.0
        
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_MainLocation.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_subfoldername.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tv_description.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_HeaderTitle.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_SubTitle.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        bnt_Done.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_FolderName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Description.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_AddNew.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        lbl_HeaderTitle.text = NSLocalizedString("BuiltAudit", comment: "")
        lbl_SubTitle.text = NSLocalizedString("LocationMessage", comment: "")
        lbl_FolderName.text = NSLocalizedString("FolderName1", comment: "")
        lbl_Description.text = NSLocalizedString("FolderDescription", comment: "")
        bnt_Done.setTitle(NSLocalizedString("Done", comment: ""), for: UIControlState.normal)
        btn_AddNew.setTitle(NSLocalizedString("Add", comment: ""), for: UIControlState.normal)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_subfoldername.textAlignment = NSTextAlignment.right
            tv_description.textAlignment = NSTextAlignment.right
            lbl_FolderName.textAlignment = NSTextAlignment.right
            lbl_Description.textAlignment = NSTextAlignment.right
        }
    }
    
}

extension LocationFolderListViewController: FolderOperationDelegate {
    
    func viewFolderDetails(index: Int) {
        //print(index)
        /// From here we need to pass the auditid, folderId, subfolderid etc
        let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltSubAuditViewController") as! BuiltSubAuditViewController
        vc.intAuditId = arrLocationFolderList[index].auditId!
        vc.intFolderId = arrLocationFolderList[index].folderId!
        vc.intLocationId = arrLocationFolderList[index].locationId!
        vc.intSubFolderId = arrLocationFolderList[index].incId!
        vc.base64photo = arrLocationFolderList[index].photo!
        vc.strTitle = arrLocationFolderList[index].subFolderName!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func archiveFolder(index: Int) {
        //print(index)
        if arrLocationFolderList[index].is_archive == 1 {
            arrLocationFolderList[index].is_archive = 0
        } else {
            arrLocationFolderList[index].is_archive = 1
        }
        
        tblView.beginUpdates()
        let indexPosition = IndexPath(row: index, section: 0)
        tblView.reloadRows(at: [indexPosition], with: .middle)
        tblView.endUpdates()
        
        obSqlite.updateLocationSubFolder(incId: arrLocationFolderList[index].incId!, isArchive: arrLocationFolderList[index].is_archive!, base64Str: "", subfolderTitle: "", subfolderDescription: "", updateType: "isArchive")
    }
    
    func editFolder(index: Int) {
        //print(index)
        flagIsAddSubFolder = false
        selectedindex = index
        view_popover.alpha = 1.0
        tf_subfoldername.text = arrLocationFolderList[index].subFolderName
        tv_description.text = arrLocationFolderList[index].subFolderDescription
    }
    
    func navigateToSubLocationSubFolderList(obSubLocationSubFolder: BuiltAuditSubLocationModel, obLocationSubFolder: LocationSubFolderListModel) {
        let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "SubLocationSubFolderListViewController") as! SubLocationSubFolderListViewController
        
        var arrSubFolderModel = [SubLocationSubFolderModel]()
        arrSubFolderModel = obSubLocationSubFolder.arrFolders
        
        if arrSubFolderModel.count == 0 {
            let foldercount = obSubLocationSubFolder.subLocationCount!
            
            for _ in 0..<(foldercount) {
                autoreleasepool {
                    let obAudit = SubLocationSubFolderModel()
                    var desc = obSubLocationSubFolder.subLocationDescription
                    if obSubLocationSubFolder.subLocationDescription!.count == 0 {
                        desc = "This is a description for \(obSubLocationSubFolder.subLocationName!) folder"
                    }
                    
                    obAudit.initWith(auditId: obSubLocationSubFolder.auditId!, locationId: obSubLocationSubFolder.locationId!, subLocationId: obSubLocationSubFolder.subLocationId!, folderId: obSubLocationSubFolder.folderId!, subFolderId: obSubLocationSubFolder.subFolderId!, subFolderName: obSubLocationSubFolder.subLocationName!, subFolderDesc: desc!)
                    obSqlite.insertintoSubLocationSubFolderList(oblist: obAudit)
                }
            }
        } else {
            let previouscount = arrSubFolderModel.count
            let currentcount = obSubLocationSubFolder.subLocationCount!
            
            if previouscount != currentcount {
                var foldercount = Int()
                /// Means user has decrease the quantity, in that case the data will be deleted
                if currentcount < previouscount {
                    
                    obSqlite.deleteSubLocationSubFolder(incId: 0, auditId: obSubLocationSubFolder.auditId!, locationId: obSubLocationSubFolder.locationId!, folderId: obSubLocationSubFolder.folderId!, subFolderId: obSubLocationSubFolder.subFolderId!, sub_locationId: obSubLocationSubFolder.subLocationId!, deleteType: "subLocation")
                    
                    foldercount = obSubLocationSubFolder.subLocationCount!
                } else if currentcount > previouscount {
                    foldercount = currentcount - previouscount
                }
                
                for _ in 0..<(foldercount) {
                    autoreleasepool {
                        let obAudit = SubLocationSubFolderModel()
                        obAudit.initWith(auditId: obSubLocationSubFolder.auditId!, locationId: obSubLocationSubFolder.locationId!, subLocationId: obSubLocationSubFolder.subLocationId!, folderId: obSubLocationSubFolder.folderId!, subFolderId: obSubLocationSubFolder.subFolderId!, subFolderName: obSubLocationSubFolder.subLocationName!, subFolderDesc: obSubLocationSubFolder.subLocationDescription!)
                        obSqlite.insertintoSubLocationSubFolderList(oblist: obAudit)
                    }
                }
            }
        }
        
        let vc1 = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltSubAuditViewController") as! BuiltSubAuditViewController
        vc1.intAuditId = obSubLocationSubFolder.auditId!
        vc1.intFolderId = obSubLocationSubFolder.folderId!
        vc1.intLocationId = obSubLocationSubFolder.locationId!
        vc1.intSubFolderId = obSubLocationSubFolder.subFolderId!
        vc1.base64photo = obLocationSubFolder.photo!
        vc1.strTitle = obLocationSubFolder.subFolderName!
        self.navigationController?.viewControllers.append(vc1)
        
        vc.intSubLocIncId = obSubLocationSubFolder.incId!
        vc.strSubFolderName = obSubLocationSubFolder.subLocationName!
        vc.strSubLocationName = obSubLocationSubFolder.subLocationName!
        vc.intAuditId = obSubLocationSubFolder.auditId!
        vc.intLocationId = obSubLocationSubFolder.locationId!
        vc.intFolderId = obSubLocationSubFolder.folderId!
        vc.intSubFolderId = obSubLocationSubFolder.subFolderId!
        vc.intSubLocationId = obSubLocationSubFolder.subLocationId!
        self.navigationController?.pushViewController(vc, animated: true)
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
        cell.setUpSubFolderData(obSF: arrLocationFolderList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if arrLocationFolderList[indexPath.row].is_archive == 1  || arrLocationFolderList.count == 1 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            
            /// Delete the questions related to location sub folder
            obSqlite.deleteQuestionAnswer(auditId: self.arrLocationFolderList[indexPath.row].auditId!, locationId: self.arrLocationFolderList[indexPath.row].locationId!, folderId: self.arrLocationFolderList[indexPath.row].folderId!, subFolderId: self.arrLocationFolderList[indexPath.row].incId!, subLocationId: 0, subLocationSubFolderId: 0, deleteType: "locationSubfolder")
            
            /// delete location sub folder entry and on the behalf of it,
            obSqlite.deleteLocationSubFolder(auditId: 0, locationId: 0, incId: self.arrLocationFolderList[indexPath.row].incId!, folderId: 0, deleteType: "incId")
            self.arrLocationFolderList.remove(at: indexPath.row)
            
            kAppDelegate.intTotalFolderCount = kAppDelegate.intTotalFolderCount - 1
            let updatesuccess = obSqlite.updateLocationFolder(incId: self.folderid, folderCount: kAppDelegate.intTotalFolderCount, folderTitle: "", updateType: "count")
            if updatesuccess {
                kAppDelegate.intTotalLocationCount = kAppDelegate.intTotalLocationCount - 1
                obSqlite.updateBuiltAuditLocation(isModified: 0, count: kAppDelegate.intTotalLocationCount, auditId: self.auditid, locationId: self.locationid, updateType: "count")
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
        let messageFont = [NSAttributedStringKey.font: UIFont(name: CustomFont.themeFont, size: 16.0)!]
        let messageAttrString = NSMutableAttributedString(string: "Are you sure you want to delete the selected folder. This will delete all the associated data. Would you like to continue ?", attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let okButton = UIAlertAction(title:"Yes", style: UIAlertActionStyle.default) { (UIAlertAction) in
            /// delete Query will be applied
            obSqlite.deleteLocationSubFolder(auditId: 0, locationId: 0, incId: self.arrLocationFolderList[indexPath.row].incId!, folderId: 0, deleteType: "incId")
            self.arrLocationFolderList.remove(at: indexPath.row)
            UIView.animate(withDuration: 0.2) { () -> Void in
                
                kAppDelegate.intTotalFolderCount = kAppDelegate.intTotalFolderCount - 1
                let updatesuccess = obSqlite.updateLocationFolder(incId: self.folderid, folderCount: kAppDelegate.intTotalFolderCount, folderTitle: "", updateType: "count")
                if updatesuccess {
                    kAppDelegate.intTotalLocationCount = kAppDelegate.intTotalLocationCount - 1
                    obSqlite.updateBuiltAuditLocation(isModified: 0, count: kAppDelegate.intTotalLocationCount, auditId: self.auditid, locationId: self.locationid, updateType: "count")
                }
                 self.tblView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        let cancelButton = UIAlertAction(title:"No", style: UIAlertActionStyle.default) { (UIAlertAction) in }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
}

extension LocationFolderListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

extension LocationFolderListViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.autocorrectionType = .no
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
