//
//  SubLocationSubFolderListViewController.swift
//  Audit
//
//  Created by Mac on 12/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class SubLocationSubFolderListViewController: UIViewController {
    //MARK: Variables & Outlets:
    var strSubFolderName = String()
    var strSubLocationName = String()
    var arrSubLocationSubFolder = [SubLocationSubFolderModel]()
    var intAuditId = 0
    var intLocationId = 0
    var intSubLocationId = Int()
    var intFolderId = 0
    var intSubFolderId = 0
    var intSubLocIncId = Int()
    var flagIsAddSubFolder = false
    var intSelectedIndex = Int()
    
    @IBOutlet weak var lbl_SubLocationSubFolderName: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btn_Add: UIButton!
    @IBOutlet weak var lbl_SubFolderName: UILabel!
    @IBOutlet weak var lbl_SubLocationName: UILabel!
    @IBOutlet weak var lbl_Msg: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet var view_popover: UIView!
    @IBOutlet weak var tf_subfoldername: DesignableUITextField!
    @IBOutlet weak var tv_description: DesignableTextView!
    @IBOutlet weak var lbl_EditDescription: UILabel!
    @IBOutlet weak var lbl_SubFolderTitle: UILabel!
    @IBOutlet weak var btn_Done: DesignableButton!
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
         self.tblView.tableFooterView = UIView()
        setUpLanguageSetting()
     
        tf_subfoldername.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: tf_subfoldername.frame.height))
        tf_subfoldername.leftViewMode = .always
        view_popover.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_popover)
        view_popover.alpha = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        lbl_SubFolderName.text = strSubFolderName
        lbl_SubLocationName.text = kAppDelegate.strSubLocationName
        arrSubLocationSubFolder = obSqlite.getSubLocationSubFolderList(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, sub_locationId: intSubLocationId, subFolderId: intSubFolderId)
        self.lbl_SubFolderName.text = String(format: "%@ (%d)", strSubFolderName, self.arrSubLocationSubFolder.count)
        tblView.reloadData()
        setWorkStatusForSubFolderBlocks()
    }
    
    func releaseUnusedMemory() {
        lbl_SubFolderName.removeFromSuperview()
        lbl_SubLocationName.removeFromSuperview()
        view_popover.removeFromSuperview()
        tblView.delegate = nil
        tblView.dataSource = nil
        tblView.removeFromSuperview()
        arrSubLocationSubFolder.removeAll()
        arrSubLocationSubFolder = [SubLocationSubFolderModel]()
    }
    
    func setWorkStatusForSubFolderBlocks() {
        var answersCount = 0.0
        var totalAnswers = 0.0
        for obSubLocation in arrSubLocationSubFolder {
            answersCount = answersCount + Double(obSubLocation.answeredCount!)
            totalAnswers = totalAnswers + Double(obSubLocation.totalCount!)
        }
        //print("answersCount = \(answersCount)")
        //print("totalAnswers = \(totalAnswers)")
        if (answersCount / totalAnswers) == 0.0 {
            
            _ = obSqlite.updateBuiltAuditSubLocation(incId: 0, auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subFolderId: intSubFolderId, subLocationId: intSubLocationId, subLocationCount: 0, workStatus: AuditStatus.InComplete, updateType: "workstatus")
        } else if (answersCount / totalAnswers) < 1.0 {
            
            _ = obSqlite.updateBuiltAuditSubLocation(incId: 0, auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subFolderId: intSubFolderId, subLocationId: intSubLocationId, subLocationCount: 0, workStatus: AuditStatus.Pending, updateType: "workstatus")
        }  else if (answersCount / totalAnswers) == 1.0 {
            
            _ = obSqlite.updateBuiltAuditSubLocation(incId: 0, auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subFolderId: intSubFolderId, subLocationId: intSubLocationId, subLocationCount: 0, workStatus: AuditStatus.Completed, updateType: "workstatus")
        }
    }
    
    //MARK: Button Actions:
    @IBAction func btn_HidePopOver(_ sender: Any) {
        tf_subfoldername.resignFirstResponder()
        tv_description.resignFirstResponder()
        view_popover.alpha = 0.0
    }
    
    @IBAction func btn_AddEditSubFolder(_ sender: Any) {
        if flagIsAddSubFolder { /// Add new entry
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
        } else { /// Update existing entry
            if checkValidations().count > 0 {
                self.showAlertViewWithMessage(checkValidations(), vc: self)
            } else {
                self.updateExistingSubFolder()
                view_popover.alpha = 0.0
                tf_subfoldername.text = ""
                tv_description.text = ""
                tf_subfoldername.resignFirstResponder()
                tv_description.resignFirstResponder()
            }
        }
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        releaseUnusedMemory()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btn_NavigateToBuiltSubAudit(_ sender: Any) {
          setWorkStatusForSubFolderBlocks()
        releaseUnusedMemory()
        MF.navigateToBuiltSubAudit(vc: self)
    }
    @IBAction func btn_NavigateToBuiltAudit(_ sender: Any) {
          setWorkStatusForSubFolderBlocks()
        releaseUnusedMemory()
        
        MF.navigateToBuiltAudit(vc: self)
    }
    @IBAction func btn_Add(_ sender: Any) {
        flagIsAddSubFolder = true
        view_popover.alpha = 1.0
    }
    
    //MARK: Supporting Functions
    func checkValidations() -> String {
        var strMsg = String()
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
    
    func addNewSubFolderEntry() {
        let obAudit = SubLocationSubFolderModel()
        
        obAudit.initWith(auditId: intAuditId, locationId: intLocationId, subLocationId: intSubLocationId, folderId: intFolderId, subFolderId: intSubFolderId, subFolderName: tf_subfoldername.text! , subFolderDesc: tv_description.text)
        obSqlite.insertintoSubLocationSubFolderList(oblist: obAudit)

        //Here refreshing or retriving the list
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
           self.arrSubLocationSubFolder = obSqlite.getSubLocationSubFolderList(auditId: self.intAuditId, locationId: self.intLocationId, folderId: self.intFolderId, sub_locationId: self.intSubLocationId, subFolderId: self.intSubFolderId)
            self.lbl_SubFolderName.text = String(format: "%@ (%d)", self.strSubFolderName, self.arrSubLocationSubFolder.count)
            self.tblView.reloadData()
        })
        
        let delay1 = 0.7 * Double(NSEC_PER_SEC)
        let time1 = DispatchTime.now() + Double(Int64(delay1)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time1, execute: {
          _ = obSqlite.updateBuiltAuditSubLocation(incId: self.intSubLocIncId, auditId: 0, locationId: 0, folderId: 0, subFolderId: 0, subLocationId: 0, subLocationCount: self.arrSubLocationSubFolder.count, workStatus: 0, updateType: "count")
        })
    }
    
    func updateExistingSubFolder() {
        let obSubFolder = arrSubLocationSubFolder[intSelectedIndex]
        
        let isUpdate = obSqlite.updateSubLocationSubFolder(incId: obSubFolder.incId!, isArchive: 0, subFolderTitle: tf_subfoldername.text!, subFolderDescription: tv_description.text, updateType: "titleDesc")
        if isUpdate{
            obSubFolder.subFolderName = tf_subfoldername.text!
            obSubFolder.subFolderDescription  = tv_description.text
            tblView.reloadData()
        }
    }
    
    @objc func touchHappen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        tf_subfoldername.resignFirstResponder()
        tv_description.resignFirstResponder()
        view_popover.alpha = 0.0
    }
    
    func setUpLanguageSetting() {
        
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.text = NSLocalizedString("BuiltAudit", comment: "")
        lbl_Msg.text = NSLocalizedString("ContentMessage", comment: "")
        btn_Add.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Add.setTitle(NSLocalizedString("Add", comment: ""), for: UIControlState.normal)
        lbl_SubFolderTitle.text = NSLocalizedString("SubFolderTitle", comment: "")
        lbl_EditDescription.text = NSLocalizedString("EditDescription", comment: "")
        btn_Done.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Done.setTitle(NSLocalizedString("Done", comment: ""), for: UIControlState.normal)
        lbl_SubLocationName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_SubFolderName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_SubFolderName.textAlignment = NSTextAlignment.right
        }
    }
}

extension SubLocationSubFolderListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSubLocationSubFolder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderViewCell", for: indexPath) as! FolderViewCell
        cell.intIndex = indexPath.row
        cell.delegate = self
        cell.setUpSubLocationSubFolderData(obSF: arrSubLocationSubFolder[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if arrSubLocationSubFolder[indexPath.row].isArchive == 1 || arrSubLocationSubFolder.count == 1 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            /// This will delete SubLocation Sub Folder Data
            /**
             After delete selected Sublocation Folder Data, SubLocation count will be updated and list will be refreshed
             - delete associated questions and answers
             */
            obSqlite.deleteSubLocationSubFolder(incId: self.arrSubLocationSubFolder[indexPath.row].incId!, auditId: 0, locationId: 0, folderId: 0, subFolderId: 0, sub_locationId: 0, deleteType: "incId")
            
            obSqlite.deleteQuestionAnswer(auditId: self.arrSubLocationSubFolder[indexPath.row].auditId!, locationId: self.arrSubLocationSubFolder[indexPath.row].locationId!, folderId: self.arrSubLocationSubFolder[indexPath.row].folderId!, subFolderId: self.arrSubLocationSubFolder[indexPath.row].subFolderId!, subLocationId: self.arrSubLocationSubFolder[indexPath.row].subLocationId!, subLocationSubFolderId: self.arrSubLocationSubFolder[indexPath.row].incId!, deleteType: "sublocationSubFolder")
            
            self.arrSubLocationSubFolder.remove(at: indexPath.row)
            _ = obSqlite.updateBuiltAuditSubLocation(incId: self.intSubLocIncId, auditId: 0, locationId: 0, folderId: 0, subFolderId: 0, subLocationId: 0, subLocationCount: self.arrSubLocationSubFolder.count, workStatus: 0, updateType: "count")
            setWorkStatusForSubFolderBlocks()
            self.executeUIProcess {
                self.tblView.deleteRows(at: [indexPath], with: .fade)
                self.tblView.reloadData()
            }
            
            let delay = 0.25 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.lbl_SubFolderName.text = String(format: "%@ (%d)", self.strSubFolderName, self.arrSubLocationSubFolder.count)
            })
        }
    }
}

extension SubLocationSubFolderListViewController: FolderOperationDelegate {
    func navigateToSubLocationSubFolderList(obSubLocationSubFolder: BuiltAuditSubLocationModel, obLocationSubFolder: LocationSubFolderListModel) {
        
    }
    
   
    
    func viewFolderDetails(index: Int) {
        /// Once user click here the questionaries session or module will start and navigate to question view screen
        let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "QuestionAnswerViewController") as! QuestionAnswerViewController
        vc.arrSubLocationSubFolder = arrSubLocationSubFolder
        vc.strLocationFolderName = arrSubLocationSubFolder[index].subFolderName!
        vc.intAuditId = arrSubLocationSubFolder[index].auditId!
        vc.intLocationId = arrSubLocationSubFolder[index].locationId!
        vc.intFolderId = arrSubLocationSubFolder[index].folderId!
        vc.intSubFolderId = arrSubLocationSubFolder[index].subFolderId!
        vc.intSubLocationId = arrSubLocationSubFolder[index].subLocationId!
        vc.intSubLocationSubFolderId = arrSubLocationSubFolder[index].incId!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func archiveFolder(index: Int) {
        if arrSubLocationSubFolder[index].isArchive == 1 {
            arrSubLocationSubFolder[index].isArchive = 0
        } else {
            arrSubLocationSubFolder[index].isArchive = 1
        }
        
        tblView.beginUpdates()
        let indexPosition = IndexPath(row: index, section: 0)
        tblView.reloadRows(at: [indexPosition], with: .middle)
        tblView.endUpdates()
       _ = obSqlite.updateSubLocationSubFolder(incId: arrSubLocationSubFolder[index].incId!, isArchive: arrSubLocationSubFolder[index].isArchive!, subFolderTitle: "", subFolderDescription: "", updateType: "isArchive")
    }
    
    func editFolder(index: Int) {
        ///here user can edit or update the title and description of the selected index.
        flagIsAddSubFolder = false
        intSelectedIndex = index
        view_popover.alpha = 1.0
        tf_subfoldername.text = arrSubLocationSubFolder[index].subFolderName!
        tv_description.text = arrSubLocationSubFolder[index].subFolderDescription!
    }
}

extension SubLocationSubFolderListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

extension SubLocationSubFolderListViewController: UITextViewDelegate {
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
