//
//  BuiltAuditViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 15/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class BuiltAuditViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var flagIsSearch = false
    
    //MARK: Variables & Outlets
    /*
     This will work woit drop feature
     */
    @IBOutlet weak var colView_SelectedLocation: UICollectionView!
    /*
     This view can work with drag feature
     */
    @IBOutlet weak var colView_LocationList: UICollectionView!
    
    @IBOutlet var view_Alert: UIView!
    @IBOutlet weak var lbl_AlertTitle: UILabel!
    @IBOutlet weak var lbl_AlertMsg: UILabel!
    @IBOutlet weak var btn_AlertYes: UIButton!
    @IBOutlet weak var btn_AlertNo: UIButton!
    @IBOutlet weak var btn_Next: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tv_Description: UITextView!
    @IBOutlet weak var lbl_Information: UILabel!
    @IBOutlet weak var btn_Delete: UIButton!
    @IBOutlet weak var btn_Location: UIButton!
    
    var intAuditId:Int? = Int()
    var counter: Int? = Int()
    var intSelectedIndexPath = Int()
    var intSelectedIndexOnAlert = Int()
    /**
     This index help to categorized wether user click on delete or on decrease button
     **/
    var intWhichAlertIndex = Int()
    var flagIsAddedSelectedLocation: Bool? = Bool()
    var arrLocationList = [LocationModel]()
    var arrLocationTempList = [LocationModel]()
    var arrSelectedLocation = [LocationModel]()
    var arrSearch: [LocationModel]? = [LocationModel]()
    var isShowDeleteBtn = false
    ///This value hold the number for counts in folder list of a particular location
    var intFolderListCounter = Int()
    var is_draft = false
    
    //MARK: Button Action Methods:
    @IBAction func btn_Back(_ sender: Any) {
        releaseUnusedMemory()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_AlertYes(_ sender: Any) {
        if intWhichAlertIndex == 1 {
            deleteOnDecreaseOrDeleteClick(deleteType: "delete")
        } else if intWhichAlertIndex == 2 {
            deleteOnDecreaseOrDeleteClick(deleteType: "decrease")
        }
        view_Alert.alpha = 0.0
    }
    
    @IBAction func btn_AlertNo(_ sender: Any) {
        view_Alert.alpha = 0.0
    }
    
    @IBAction func btn_Next(_ sender: Any) {
        if arrSelectedLocation.count > 0 {
            let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController
            vc?.intAuditId = self.intAuditId
             releaseObjectDependencies() 
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func btn_Delete(_ sender: UIButton) {
        if sender.isSelected {
            isShowDeleteBtn = false
            btn_Delete.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
            sender.isSelected = false
        } else {
            isShowDeleteBtn = true
            btn_Delete.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
            sender.isSelected = true
        }
        colView_SelectedLocation.reloadData()
    }
    
    //MARK: Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        let checkdraft = obSqlite.getAuditStatusInfoWithAuditID(auditId: intAuditId!)
        if checkdraft != 0 { is_draft = true }
        
        view_Alert.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_Alert)
        view_Alert.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (navigationController?.viewControllers.count)! > 3 {
            self.navigationController!.viewControllers.removeAll()
        }
        
        colView_LocationList.delegate = self
        colView_LocationList.dataSource = self
        colView_LocationList.dropDelegate = self
        colView_LocationList.dragDelegate = self
        colView_LocationList.dragInteractionEnabled = true
        colView_SelectedLocation.delegate = self
        colView_SelectedLocation.dataSource = self
        colView_SelectedLocation.dropDelegate = self
        tv_Description.delegate = self
        kAppDelegate.currentViewController = self
        self.executeUIProcess {
            self.getLocationList()
            let delay = 0.25 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.getSelectedLocationList()
            })
        }
    }
    
    func releaseUnusedMemory() {
        releaseObjectDependencies()
        obSqlite = SqliteDB.sharedInstance()
       // self.view.removeAllSubViews()
    }
    
    func releaseObjectDependencies() {
        self.arrLocationList.removeAll()
        self.arrLocationList = [LocationModel]()
        arrSelectedLocation.removeAll()
        arrSelectedLocation = [LocationModel]()
        colView_LocationList.delegate = nil
        colView_LocationList.dataSource = nil
        colView_SelectedLocation.delegate = nil
        colView_SelectedLocation.dataSource = nil
        tv_Description.delegate = nil
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Information.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tv_Description.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Next.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Location.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Delete.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Delete.setTitle(NSLocalizedString("Delete", comment: ""), for: UIControlState.normal)
        btn_Next.setTitle(NSLocalizedString("Next", comment: ""), for: UIControlState.normal)
        btn_Location.setTitle(NSLocalizedString("Location", comment: ""), for: UIControlState.normal)
        lbl_Information.text = NSLocalizedString("InformationBox", comment: "")
        lbl_Title.text = NSLocalizedString("BuiltAudit", comment: "")
        lbl_AlertTitle.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AlertMsg.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_AlertNo.setTitle(NSLocalizedString("No", comment: ""), for: UIControlState.normal)
        btn_AlertYes.setTitle(NSLocalizedString("Yes", comment: ""), for: UIControlState.normal)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
             lbl_Information.textAlignment = NSTextAlignment.right
            tv_Description.textAlignment = NSTextAlignment.right
        }
    }
    
    func getLocationList() {
        self.arrLocationList = obSqlite.getLocationList(isModified: AuditStatus.InComplete, auditId: intAuditId!)
        self.colView_LocationList.reloadData()
    }
    
    func getSelectedLocationList() {
        self.arrSelectedLocation = obSqlite.getLocationList(isModified: AuditStatus.Pending, auditId: intAuditId!)
        if self.arrSelectedLocation.count == 0 {
            let isSuccess = obSqlite.updateAudit(auditId: intAuditId!, updateType: "auditStatus", auditStatus: AuditStatus.InComplete, countryId: 0, language: "", isSyncCompleted: 0, answersAreSynced: 0, answersForSync: 0)
            if isSuccess == true {
                is_draft = false
            }
            btn_Delete.isSelected = false
            isShowDeleteBtn = false
            btn_Delete.setTitle("Delete", for: .normal)
            btn_Delete.alpha = 0.5
            btn_Delete.isUserInteractionEnabled = false
        } else {
            btn_Delete.alpha = 1.0
            btn_Delete.isUserInteractionEnabled = true
        }
        self.colView_SelectedLocation.reloadData()
    }
    
    
    func deleteOnDecreaseOrDeleteClick(deleteType:String) {
        
        if deleteType == "delete" {
            
            obSqlite.updateBuiltAuditLocation(isModified: AuditStatus.InComplete, count: 0, auditId: self.arrSelectedLocation[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedLocation[intSelectedIndexOnAlert].locationId!, updateType: "modified")
            obSqlite.updateBuiltAuditLocation(isModified: 0, count: 1, auditId: self.arrSelectedLocation[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedLocation[intSelectedIndexOnAlert].locationId!, updateType: "count")
            self.lbl_Information.text = NSLocalizedString("Information", comment: "")
            self.tv_Description.text = ""
            
        } else if deleteType == "decrease" {
            if self.counter! > 1 {
                self.counter! -= 1
                obSqlite.updateBuiltAuditLocation(isModified: 0, count: self.counter!, auditId: self.arrSelectedLocation[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedLocation[intSelectedIndexOnAlert].locationId!, updateType: "count")
                self.arrSelectedLocation[intSelectedIndexOnAlert].locationCount = self.counter
                self.colView_SelectedLocation.reloadData()
            }
        }
        
        // --- Delete Folders
        obSqlite.deleteLocationFolder(auditId: self.arrSelectedLocation[self.intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedLocation[self.intSelectedIndexOnAlert].locationId!, deleteType: "location")
        
        // --- Delete Sub Folders
        obSqlite.deleteLocationSubFolder(auditId: self.arrSelectedLocation[self.intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedLocation[self.intSelectedIndexOnAlert].locationId!, incId: 0, folderId: 0, deleteType: "location")

        // --- Delete Built Sub Location
        obSqlite.deleteBuiltAuditSubLocation(auditId: self.arrSelectedLocation[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedLocation[intSelectedIndexOnAlert].locationId!, folderId: 0, subFolderId: 0, sublocationId: 0, deleteType: "location")

        // --- Delete Sub Location Sub Folder
        obSqlite.deleteSubLocationSubFolder(incId: 0, auditId: self.arrSelectedLocation[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedLocation[intSelectedIndexOnAlert].locationId!, folderId: 0, subFolderId: 0, sub_locationId: 0, deleteType: "location")

        // --- Delete Audit Answers
        obSqlite.deleteQuestionAnswer(auditId: self.arrSelectedLocation[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedLocation[intSelectedIndexOnAlert].locationId!, folderId:0, subFolderId:0, subLocationId:0, subLocationSubFolderId: 0, deleteType: "location")
        
        // --- Delete Audit Photos
        _ = obSqlite.deleteSubLocationSubFolderPhoto(incId: 0, auditId: self.arrSelectedLocation[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedLocation[intSelectedIndexOnAlert].locationId!, sublocationId: 0, deleteType: "location")
        
        self.getLocationList()
        self.getSelectedLocationList()
    }
}

extension BuiltAuditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write here..." {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGray
            textView.text = "Write here..."
        }
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

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
