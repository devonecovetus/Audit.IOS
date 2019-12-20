//
//  LocationViewController.swift
//  Audit
//
//  Created by Mac on 11/19/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController {
    //MARK: Variables & Outlets
    var intAuditId: Int? = Int()
    var arrMainLocationSection = [LocationModel]()
    var intSelectedSectionIndex = Int()
    var selectedIndex = 0
    var SubFoldersCount = 0
    var totalFolderCount = 0
    var subFolderLocationCount = 0
    var calculationCounter = 0
    var intTotalFolderCounts = 0
    var primaryid = 0
    
    @IBOutlet weak var lbl_PopUpSubTitle: UILabel!
    @IBOutlet weak var btn_Add: DesignableButton!
    @IBOutlet weak var btn_Cancel: DesignableButton!
    @IBOutlet weak var lbl_AddSubFolder: UILabel!
    @IBOutlet weak var lbl_HeaderTitle: UILabel!
    @IBOutlet var view_popover: UIView!
    @IBOutlet weak var tbl_view: UITableView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_SubTitle: UILabel!
    @IBOutlet weak var tv_folderName: DesignableTextView!
    @IBOutlet weak var lbl_Count: UILabel!
   
    //MARK: Variables & Outlets
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbl_view.tableFooterView = UIView()
        setUpLanguageSetting()
        tv_folderName.delegate = self
        // Do any additional setup after loading the view.
        view_popover.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_popover)
        view_popover.alpha = 0.0
        
      //  let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchHappen(_:)))
      //  view_popover.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        tv_folderName.delegate = self
        tbl_view.delegate = self
        tbl_view.dataSource = self
        /// This will resets the value to 0, in case if there will no  subfolder counts
        kAppDelegate.intTotalLocationCount = 0
        kAppDelegate.intTotalFolderCount = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.executeUIProcess {
            self.arrMainLocationSection = obSqlite.getLocationList(isModified: AuditStatus.Pending, auditId: self.intAuditId!)
            self.tbl_view.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       removeUnUsedObjects()
    }
    
    func releaseUnusedMemory() {
        removeUnUsedObjects()
        tbl_view.delegate =  nil
        tbl_view.dataSource = nil
        view.removeAllSubViews()
    }
    
    func removeUnUsedObjects() {
        obSqlite = SqliteDB.sharedInstance()
        tv_folderName.delegate = nil
        arrMainLocationSection.removeAll()
        arrMainLocationSection = [LocationModel]()
        
    }
    
    @objc func touchHappen(_ sender: UITapGestureRecognizer) {
        view_popover.alpha = 0.0
    }
  
    @IBAction func btn_Back(_ sender: Any) {
        releaseUnusedMemory()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_NavigateToBuiltAudit(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: BuiltAuditViewController.self) {
                releaseUnusedMemory()
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    @IBAction func action_increase(_ sender: Any) {
        if calculationCounter < totalFolderCount {
            calculationCounter += 1
            lbl_Count.text = String(format: "%d", calculationCounter)
        }
    }
    
    @IBAction func action_decrease(_ sender: Any) {
        if calculationCounter > 1 {
            calculationCounter -= 1
            lbl_Count.text = String(format: "%d", calculationCounter)
        }
    }
    
    @IBAction func action_add(_ sender: Any) {
        
        if tv_folderName.text.count == 0 {
            self.showAlertViewWithMessage(ValidationMessages.enterFolderName, vc: self)
        } else {
            if btn_Add.titleLabel?.text == "Add" {
                let dictP = NSMutableDictionary()
                dictP.setValue(tv_folderName.text, forKey: "folder_name")
                dictP.setValue(Int(lbl_Count.text!), forKey: "folder_count")
                
                let obAudit = LocationFolderModel()
                obAudit.initWith(dict: dictP, auditId: arrMainLocationSection[selectedIndex].auditId!, locationId: arrMainLocationSection[selectedIndex].locationId!)
                obSqlite.insertLocationFolderData(obFolder: obAudit)
                arrMainLocationSection = obSqlite.getLocationList(isModified: AuditStatus.Pending, auditId: intAuditId!)
                
                ///Here will be the logic
                arrMainLocationSection[intSelectedSectionIndex].collapsed = false
                
                tbl_view.reloadData()
                tbl_view.reloadSections(NSIndexSet(index: intSelectedSectionIndex) as IndexSet, with: .automatic)
            } else {
                _ = obSqlite.updateLocationFolder(incId: primaryid, folderCount: Int(lbl_Count.text!)!, folderTitle: tv_folderName.text, updateType: "name_count")
                arrMainLocationSection = obSqlite.getLocationList(isModified: AuditStatus.Pending, auditId: intAuditId!)
                ///Here will be the logic
            }
            tv_folderName.text = ""
            view_popover.alpha = 0.0
            tbl_view.reloadData()
            tv_folderName.resignFirstResponder()
        }
    }
    
    @IBAction func btn_HidePopOver(_ sender: Any) {
        tv_folderName.text = ""
        tv_folderName.resignFirstResponder()
        view_popover.alpha = 0.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_SubTitle.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
         tv_folderName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.text = NSLocalizedString("BuiltAudit", comment: "")
        lbl_HeaderTitle.text = NSLocalizedString("BuiltAudit", comment: "")
        lbl_SubTitle.text = NSLocalizedString("LocationMessage", comment: "")
        lbl_PopUpSubTitle.text = NSLocalizedString("AddSubFolder", comment: "")
        lbl_Count.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Add.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Cancel.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Add.setTitle(NSLocalizedString("Add", comment: ""), for: UIControlState.normal)
        btn_Cancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: UIControlState.normal)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tv_folderName.textAlignment = NSTextAlignment.right
            lbl_PopUpSubTitle.textAlignment = NSTextAlignment.right
        }
    }
}

extension LocationViewController : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrMainLocationSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMainLocationSection[section].collapsed ? 0 : arrMainLocationSection[section].arrFolders.count
    }
    
    // Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tbl_view.dequeueReusableCell(withIdentifier: "Location_NewCell", for: indexPath) as! Location_NewCell
        cell.index = indexPath.row
        cell.indexpath = indexPath
        let item: LocationFolderModel = arrMainLocationSection[indexPath.section].arrFolders[indexPath.row]
        cell.lbl_Text.text = String(format: "%@ \t (%d)", item.folderName!, item.folderCount!)
        cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        header.titleLabel.text = arrMainLocationSection[section].locationName
        header.countLabel.text = String(format: "(%d)", arrMainLocationSection[section].locationCount!)

        if arrMainLocationSection[section].arrFolders.count == 0 {
            header.arrowimg.alpha = 0.0
        } else {
            header.arrowimg.alpha = 1.0
        }
        header.setCollapsed(arrMainLocationSection[section].collapsed)
        header.section = section
        header.delegate = self

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return DeviceType.IS_PHONE ? 45 : 70.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}

//
// MARK: - Section Header Delegate
//
extension LocationViewController: CollapsibleTableViewHeaderDelegate {
  
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !arrMainLocationSection[section].collapsed
        
        for i in 0..<arrMainLocationSection.count {
            if i != section {
                arrMainLocationSection[i].collapsed = true
            }
        }
        tbl_view.reloadData()
        let item: Int = arrMainLocationSection[section].arrFolders.count
        
        if item != 0 {
            // Toggle collapse
            arrMainLocationSection[section].collapsed = collapsed
            header.setCollapsed(collapsed)
            tbl_view.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        }
    }
    
    func addFolder(section: Int) {
        
        btn_Add.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
        intSelectedSectionIndex = section
        selectedIndex = section
        SubFoldersCount = arrMainLocationSection[section].arrFolders.count //2
        totalFolderCount = arrMainLocationSection[section].locationCount! //20
        calculationCounter = 0
        subFolderLocationCount = 0

        if SubFoldersCount != 0 {
            let subfolders: [LocationFolderModel] = arrMainLocationSection[section].arrFolders
            for count in subfolders{
                subFolderLocationCount = subFolderLocationCount + count.folderCount!
            }
            if totalFolderCount == subFolderLocationCount {
                showAlertViewWithMessage("You consume all Counters", vc: self)
                return
            } else {
                calculationCounter = totalFolderCount - subFolderLocationCount
                lbl_Count.text = String(format: "%d",calculationCounter)
                totalFolderCount = calculationCounter
            }
        } else {
            subFolderLocationCount = totalFolderCount
            calculationCounter = subFolderLocationCount
            lbl_Count.text = String(format: "%d", arrMainLocationSection[section].locationCount!)
        }
        view_popover.alpha = 1.0
        lbl_Title.text = arrMainLocationSection[section].locationName
    }
}

extension LocationViewController: LocationFolderDelegate {
    
    func editValue(index: Int, indexPath: IndexPath) {
        
        btn_Add.setTitle(NSLocalizedString("Edit", comment: ""), for: .normal)
        selectedIndex = index
        primaryid = arrMainLocationSection[indexPath.section].arrFolders[index].primaryId!
        SubFoldersCount = arrMainLocationSection[indexPath.section].arrFolders.count
        totalFolderCount = arrMainLocationSection[indexPath.section].locationCount!
        calculationCounter = 0
        subFolderLocationCount = 0
        
        let subfolders: [LocationFolderModel] = arrMainLocationSection[indexPath.section].arrFolders
        
        for count in subfolders{
            subFolderLocationCount = subFolderLocationCount + count.folderCount!
        }
        
        let buffercount = totalFolderCount - subFolderLocationCount
        calculationCounter = arrMainLocationSection[indexPath.section].arrFolders[index].folderCount!
        totalFolderCount = calculationCounter + buffercount
        lbl_Count.text = String(format: "%d", arrMainLocationSection[indexPath.section].arrFolders[index].folderCount!)
        view_popover.alpha = 1.0
        lbl_Title.text = arrMainLocationSection[indexPath.section].locationName
        tv_folderName.text = arrMainLocationSection[indexPath.section].arrFolders[index].folderName!
    }
    
    func nextValue(index: Int, indexPath: IndexPath) {
        var arrSubLocationFolder = [LocationSubFolderListModel]()
        arrSubLocationFolder = arrMainLocationSection[indexPath.section].arrFolders[index].arrSubFolders
        kAppDelegate.intTotalLocationCount = arrMainLocationSection[indexPath.section].locationCount!
        kAppDelegate.intTotalFolderCount = arrMainLocationSection[indexPath.section].arrFolders[index].folderCount!
        
        if arrSubLocationFolder.count == 0 {
            let foldercount = arrMainLocationSection[indexPath.section].arrFolders[index].folderCount!
            primaryid = arrMainLocationSection[indexPath.section].arrFolders[index].primaryId!
            
            for i in 0..<(foldercount) {
                autoreleasepool {
                    let strname = String(format: "%@ %d", arrMainLocationSection[indexPath.section].arrFolders[index].folderName!,i+1)
                    let strdescription = String(format: "Description %d",i+1)
                    let obAudit = LocationSubFolderListModel()
                    obAudit.initWith(locationId: arrMainLocationSection[indexPath.section].arrFolders[index].locationId! , auditId: arrMainLocationSection[indexPath.section].auditId!, folderId: primaryid, name: strname, description: strdescription)
                    obSqlite.insertLocationSubFolderListData(obFolder: obAudit)
                }
            }
        } else {
            
            let previouscount = arrSubLocationFolder.count
            let currentcount = arrMainLocationSection[indexPath.section].arrFolders[index].folderCount!
            
            if previouscount != currentcount {
                let folderid = arrMainLocationSection[indexPath.section].arrFolders[index].primaryId!
                obSqlite.deleteLocationSubFolder(auditId: arrMainLocationSection[indexPath.section].auditId!, locationId: arrMainLocationSection[indexPath.section].arrFolders[index].locationId!, incId: 0, folderId: folderid, deleteType: "folderId")
                
                /// MAke delay of 1 sec
                
                let foldercount = self.arrMainLocationSection[indexPath.section].arrFolders[index].folderCount!
                self.primaryid = self.arrMainLocationSection[indexPath.section].arrFolders[index].primaryId!
                
                for i in 0..<(foldercount) {
                    autoreleasepool {
                        let strname = String(format: "%@ %d", self.arrMainLocationSection[indexPath.section].arrFolders[index].folderName!,i+1)
                        let strdescription = String(format: "Description %d",i+1)
                        
                        let obAudit = LocationSubFolderListModel()
                        obAudit.initWith(locationId: self.arrMainLocationSection[indexPath.section].arrFolders[index].locationId! , auditId: self.arrMainLocationSection[indexPath.section].auditId!, folderId: self.primaryid, name: strname, description: strdescription)
                        obSqlite.insertLocationSubFolderListData(obFolder: obAudit)
                    }
                }
            }
        }
        
        
        //// Here logic to manage all folder counts
      //  if arrMainLocationSection[indexPath.section].locationCount == intTotalFolderCounts {
        if self.checkTotalLocationAndFolderCountsAreEqual() {
            let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "LocationFolderListViewController") as? LocationFolderListViewController
            vc?.str_mainlocation = self.arrMainLocationSection[indexPath.section].locationName!
            vc?.str_folderlocation = String(format: "%@ \t (%d)", self.arrMainLocationSection[indexPath.section].arrFolders[index].folderName!, self.arrMainLocationSection[indexPath.section].arrFolders[index].folderCount!)
            vc?.auditid = self.arrMainLocationSection[indexPath.section].auditId!
            vc?.locationid = self.arrMainLocationSection[indexPath.section].arrFolders[index].locationId!
            vc?.folderid = self.arrMainLocationSection[indexPath.section].arrFolders[index].primaryId!
            kAppDelegate.strPhoto = self.arrMainLocationSection[indexPath.section].arrFolders[index].photo!
            vc?.strPhoto = kAppDelegate.strPhoto
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            self.showAlertViewWithMessage("In order to proceed Audit, You must have to split sub folder counts as per as total counts !", vc: self)
        }
    }
    
    /**
     This function manages the total location counts and total folder counts. If equal then condition return true else false
     */
    func checkTotalLocationAndFolderCountsAreEqual() -> Bool {
        /// CheckTotal Location counts
        var flagIsEqual = false
        var intLocationCount = 0
        var intFolderCount = 0
        for i in 0..<arrMainLocationSection.count {
            autoreleasepool {
                intLocationCount = intLocationCount + arrMainLocationSection[i].locationCount!
                for j in 0..<arrMainLocationSection[i].arrFolders.count {
                    intFolderCount = intFolderCount + arrMainLocationSection[i].arrFolders[j].folderCount!
                }
            }
        }
       // //print("intLocationCount = \(intLocationCount), intFolderCount = \(intFolderCount)")
        if intLocationCount == intFolderCount {
            flagIsEqual = true
        }
        return flagIsEqual
    }
}

extension LocationViewController: UITextViewDelegate {
    
    // Textview Delegate Method
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description" {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGray
            textView.text = "Description"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.autocorrectionType = .no
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        let currentCharacterCount = tv_folderName.text?.count ?? 0
        let newLength = currentCharacterCount + text.count - range.length
        if(newLength <= 100) {
            return true
        } else{
            return false
        }
    }
}
