//
//  DraftsViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 24/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let internetDisconnect = Notification.Name("internetDisconnect")
}

class DraftsViewController: UIViewController {
   
    var intPopUpIndex = Int()
    @IBOutlet weak var view_Header: UIView!
    @IBAction func btn_UpdateAudit(_ sender: Any) {
        
        self.executeUIProcess({
            SVProgressHUD.show(withStatus: "Downloading Files\n\nProcessing the download, Please wait.....")
        })
        
        /// Here we refresh or update new contents in Audit
        strCountryId = String(format: "%d", (arrDraftAuditList?[0].countryId)!)
        strLanguageId = String(format: "%d", (arrDraftAuditList?[0].language)!)
        
        getAuditLocationSubLocationAndQuestionData(intAuditId: (arrDraftAuditList?[0].audit_id)!)
        ///from this here I am checking audit locations
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.getUpdatedLocationList(auditId: (self.arrDraftAuditList?[0].audit_id)!, countryId: (self.arrDraftAuditList?[0].countryId)!)
        }
        
    }
    
    var strCountryId = String()
    var strLanguageId = String()
    var intTotalAnswersForSync = Double() /// This will take only record for those needs for sync or synced.
    var intTotalAnswersToBeSynced = Double() /// THis will take the total nhumber of questiones to be synced on server.
    var intTotalAnswersSynced = Double() /// This will track the total number of answers successfully synced.
    var indexValue = Int()
    var GIndex = Int()
    var intSyncIndex = Int()
    var intAuditId = Int()
    var arrDataSync:[DataSyncModel]?  = [DataSyncModel]()
    var arrDraftAuditList:[MyAuditListModel]? = [MyAuditListModel]()
    
    var arrAuditLocation: [LocationModel]? = [LocationModel]()
    var arrAuditSubLocation:[SubLocationModel]? = [SubLocationModel]()
    var arrAuditQuestions:[QuestionsModel]? = [QuestionsModel]()
    var intIndexCount = Int()
    var arrLocations: [LocationModel] = [LocationModel]()
    var intTotalLocationsCount = Int()
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lbl_Title: UILabel!

    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        view_Header.alpha = 0.0
        view_Header.frame = CGRect(x: 0, y: 0, width: self.view_Header.frame.size.width, height: 0.0)
        arrAuditLocation = [LocationModel]()
        arrAuditSubLocation = [SubLocationModel]()
        arrAuditQuestions = [QuestionsModel]()
        // Do any additional setup after loading the view.
        setUpLanguageSetting()
        NotificationCenter.default.addObserver(self, selector: #selector(myFunction), name: .internetDisconnect, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        kAppDelegate.currentViewController = self
        arrDraftAuditList = obSqlite.getAuditList(status: 0, fetchType: "pendingComplete")
        self.executeUIProcess {
        if (self.arrDraftAuditList?.count)! > 0 {
            self.view_Header.alpha = 1.0
            self.view_Header.frame = CGRect(x: 0, y: 0, width: self.view_Header.frame.size.width, height: 55.0)
        } else {
            self.view_Header.alpha = 0.0
            self.view_Header.frame = CGRect(x: 0, y: 0, width: self.view_Header.frame.size.width, height: 0.0)
        }
            self.tblView.reloadData()
        }
        if (navigationController?.viewControllers.count)! > 2 {
            self.navigationController!.viewControllers.removeAll()
        }
    }
        
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
    @objc func myFunction(notification: Notification) {
        self.executeUIProcess({
            self.tblView.reloadData()
        })
    }
}

extension DraftsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDraftAuditList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAuditCell", for: indexPath) as! MyAuditCell
        autoreleasepool {
            cell.intIndex = indexPath.row
            cell.delegate = self
            if arrDraftAuditList!.count > 0 {
                cell.setMyAuditData(obAudit: arrDraftAuditList?[indexPath.row])
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if arrDraftAuditList?[indexPath.row].audit_status == AuditStatus.Completed  && arrDraftAuditList?[indexPath.row].isSyncStarted == 1 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            obSqlite.deleteSelectedAudit(auditId: arrDraftAuditList?[indexPath.row].audit_id)
        }
    }
}

extension DraftsViewController: MyAuditDelegate {
    
    func refreshList(index: Int) {
        viewWillAppear(true)
    }
    
    func viewAudit(index: Int) {
        kAppDelegate.flagIsOrderSubmit = false
        let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltAuditViewController") as! BuiltAuditViewController
        vc.intAuditId = self.arrDraftAuditList?[index].audit_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func syncAudit(index: Int) {
        intSyncIndex = index
        
        let arrAnswersForSync: [AuditAnswerModel]? = obSqlite.getAuditAnswers(auditId: (arrDraftAuditList?[GIndex].audit_id!)!, locationId: 0, folderId: 0, subfolderId: 0, sub_locationId: 0, sub_locationsub_folderId: 0, parentQueId: 0, selectedAnsId: 0, fetchType: "totalAnswersForSync")
        if arrAnswersForSync?.count == 0 {
         
             MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Simple, title: NSLocalizedString("Alert", comment: ""), message: NSLocalizedString("emptyAudit", comment: ""))
        } else {
            intTotalAnswersSynced = 0
            let arrAnswersAreSync = obSqlite.getAuditAnswers(auditId: (arrDraftAuditList?[GIndex].audit_id!)!, locationId: 0, folderId: 0, subfolderId: 0, sub_locationId: 0, sub_locationsub_folderId: 0, parentQueId: 0, selectedAnsId: 0, fetchType: "totalAnswersAreSync")
            intTotalAnswersSynced = Double((arrAnswersAreSync.count))
            
            intAuditId = (self.arrDraftAuditList?[index].audit_id!)!
            GIndex = index
            
            if self.arrDraftAuditList?[index].isSyncStarted == 0 {
                /// In future the functionalit will be manage by showing popup for confirmatioMF.showCus
                MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: "Data Sync", message: NSLocalizedString("ValidationSyncAudit", comment: ""))
            } else {
                intTotalAnswersForSync = 0
                let arrAnswersForSync = obSqlite.getAuditAnswers(auditId: (arrDraftAuditList?[GIndex].audit_id!)!, locationId: 0, folderId: 0, subfolderId: 0, sub_locationId: 0, sub_locationsub_folderId: 0, parentQueId: 0, selectedAnsId: 0, fetchType: "totalAnswersForSync")
                intTotalAnswersForSync = Double((arrAnswersForSync.count))
                syncAuditData()
            }
        }
        
    }
    
    func syncAuditData() {
        /// THis varaible checks the
        if kAppDelegate.flagIsOrderSubmit {
            
            self.executeUIProcess({
                SVProgressHUD.show(withStatus: "Loading...")
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                var arrAnswersForSync: [AuditAnswerModel]? = obSqlite.getAuditAnswers(auditId: (self.arrDraftAuditList?[self.GIndex].audit_id!)!, locationId: 0, folderId: 0, subfolderId: 0, sub_locationId: 0, sub_locationsub_folderId: 0, parentQueId: 0, selectedAnsId: 0, fetchType: "totalAnswersForSync")
                
                if (arrAnswersForSync?.count)! > 0 {
                    self.intTotalAnswersForSync = Double(((arrAnswersForSync?.count)!))
                    self.getDBData()
                    arrAnswersForSync?.removeAll()
                    arrAnswersForSync = nil
                }
            }
         } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "LocationReOrderingViewController") as? LocationReOrderingViewController
                vc?.intAuditId = (self.arrDraftAuditList?[self.GIndex].audit_id!)!
                vc?.intCountryId = (self.arrDraftAuditList?[self.GIndex].countryId)!
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
    }
    
    func getDBData(){
        obSqlite = SqliteDB.sharedInstance()
      print("intTotalAnswersSynced = \(intTotalAnswersSynced), intTotalAnswersToBeSynced = \(intTotalAnswersForSync)")
   //     //print("sync Value = \(CGFloat(intTotalAnswersSynced / intTotalAnswersForSync) * 100)")
        arrDraftAuditList?[intSyncIndex].totalAnswersAreSynced = Int(intTotalAnswersSynced)
        arrDraftAuditList?[intSyncIndex].totalAnswersForSync = Int(intTotalAnswersForSync)
        if CGFloat((intTotalAnswersSynced / intTotalAnswersForSync) * 100) > 100 {
            arrDraftAuditList?[intSyncIndex].syncProgress = 100
        } else {
            arrDraftAuditList?[intSyncIndex].syncProgress = CGFloat((intTotalAnswersSynced / intTotalAnswersForSync) * 100)
        }
        
       // tblView.reloadData()
        self.executeUIProcess {
            let indexPath = NSIndexPath.init(row:  self.intSyncIndex, section: 0)
            self.tblView.reloadRows(at: [indexPath as IndexPath], with: .none)
        }
        
        
        var obAnswer: [AuditAnswerModel]? = [AuditAnswerModel]()
        obAnswer = obSqlite.getAuditAnswers(auditId: (arrDraftAuditList?[GIndex].audit_id!)!, locationId: 0, folderId: 0, subfolderId: 0, sub_locationId: 0, sub_locationsub_folderId: 0, parentQueId: 0, selectedAnsId: 0, fetchType: "updateSync")
        
        if obAnswer!.count > 0 {

            indexValue = 0
            arrDataSync?.removeAll()//removeAll()
            arrDataSync = [DataSyncModel]()
            
            for item in obAnswer! {
                 autoreleasepool {
                let obSync:DataSyncModel? = DataSyncModel()
                obSync!.initWith(obAnswer: item)
                arrDataSync?.append(obSync!)
                
            }
            }
            getNewSyncObject(indexValue: indexValue)
        } else {
            //print("Complete")
            getDataSyncComplete()
        }
        obAnswer?.removeAll()
        obAnswer = nil
    }
    
    func getNewSyncObject(indexValue: Int) {
        getAuditSync(obSync: arrDataSync![indexValue])
    }
    
    func getAuditSync(obSync: DataSyncModel?) {
        
     //   self.executeUIProcess {
            autoreleasepool {
        /// API code here
        let dictP: NSMutableDictionary? = MF.initializeDictWithUserId()
        dictP?.setValue(obSync?.auditId, forKey: "audit_id")
        dictP?.setValue(obSync?.userId, forKey: "user_id")
        dictP?.setValue(obSync?.countryId, forKey: "country_id")
        dictP?.setValue(obSync?.language, forKey: "lang")
        dictP?.setValue(obSync?.locationId, forKey: "location_id")
        dictP?.setValue(obSync?.subfolderId, forKey: "subfolder_id")
        dictP?.setValue(obSync?.subfolderTitle, forKey: "subfolder_title")
        dictP?.setValue(obSync?.layerId, forKey: "layer_id")
        dictP?.setValue(obSync?.layerTitle, forKey: "layer_title")
        dictP?.setValue(obSync?.layerDesc, forKey: "layer_desc")
        
            let obFM: FileDownloaderManager?  = FileDownloaderManager()

             //   //print("obSync?.layerImg = \(obSync?.layerImg)")
                
        if obSync?.layerImg != "" && obSync?.layerImg != nil {
            
            let image_layer = UIImage(contentsOfFile: obFM!.getAuditImagePath(imageName:obSync!.layerImg!))
            let layerImgBase64String = image_layer?.imageQuality(.lowest)?.base64EncodedString(options: .lineLength64Characters)
        //    //print("layerImgBase64String = \(layerImgBase64String?.count)")
            dictP?.setValue(layerImgBase64String, forKey: "fileData1")
            dictP?.setValue("layer_img", forKey: "fileKey1")
        }
        
            dictP?.setValue(obSync?.subLocationId, forKey: "sub_location_id")
            dictP?.setValue(obSync?.subLocationLayerId, forKey: "sub_location_layer_id")
            dictP?.setValue(obSync?.subLocationLayerTitle, forKey: "sub_location_layer_title")
            dictP?.setValue(obSync?.subLocationLayerDesc, forKey: "sub_location_layer_desc")
        
            if obSync?.subLocationLayerFirstImage.count != 0 {
            ////print("obSync?.subLocationLayerFirstImage = \((obSync?.subLocationLayerFirstImage[0] as! String).count)")
                let image_main = UIImage(contentsOfFile: obFM!.getAuditImagePath(imageName:obSync?.subLocationLayerFirstImage[0] as! String))
            let mainImgBase64String = image_main?.imageQuality(.lowest)?.base64EncodedString(options: .lineLength64Characters)
            dictP?.setValue(mainImgBase64String, forKey: "fileData2")
            dictP?.setValue("sub_location_layer_first_image", forKey: "fileKey2")
        }
            
            dictP?.setValue(obSync?.questionId, forKey: "question_id")
            dictP?.setValue(obSync?.parentId, forKey: "parent_id")
            dictP?.setValue(obSync?.answerId, forKey: "answer_id")
            dictP?.setValue(obSync?.answerValue, forKey: "answer_value")
            dictP?.setValue(obSync?.questionType, forKey: "question_type")
        /// HERE I am managing the inspector or auditor view
             if (obSync?.parentId)! > 0 && obSync?.isSuperUserAudit == 1 {
                 dictP?.setValue("7", forKey: "permissions_id")
            } else {
                 dictP?.setValue("6", forKey: "permissions_id")
            }
     //   //print("obSync.questionImage = \(obSync.questionImage)")
            if obSync?.questionImage != "" {
                let image_QueImg = UIImage(contentsOfFile: obFM!.getAuditImagePath(imageName:(obSync?.questionImage!)!))
            let QueImgBase64String = image_QueImg?.imageQuality(.lowest)?.base64EncodedString(options: .lineLength64Characters)
            
            dictP?.setValue(QueImgBase64String, forKey: "fileDataQ")
            dictP?.setValue("question_image", forKey: "fileKeyQ")
        }
        
            dictP?.setValue(obSync?.questionPriority, forKey: "question_priority")
            dictP?.setValue(obSync?.questionExtraText, forKey: "question_extra_text")
        
           //     //print("obSync.mul_image.count = \(obSync?.mul_image.count)")
        
            if obSync?.mul_image.count != 0 {
                if obSync!.mul_image.count > 0 {
                    let arrFile:NSMutableArray? = NSMutableArray()
                    
                    for i in 0..<obSync!.mul_image.count {
                        autoreleasepool {
                        let dictF1: NSMutableDictionary? = NSMutableDictionary()
                    
                        let image_QueImg = UIImage(contentsOfFile: obFM!.getAuditImagePath(imageName:obSync?.mul_image[i] as! String))
                    let multiImgBase64String = image_QueImg?.imageQuality(.least)?.base64EncodedString(options: .lineLength64Characters)
                  //          //print("multiImgBase64String = \(multiImgBase64String?.count)")
                         dictF1?.setValue(multiImgBase64String, forKey: "fileDataM")
                         dictF1?.setValue("mul_image[]", forKey: "fileKeyM")
                         arrFile?.add(dictF1!)
                         //dictF1?.removeAllObjects()
                    }
                }
                //   //print("arrFile = \(arrFile?.count)")
                dictP?.setValue(arrFile, forKey: "multiFiles")
            }
        }
       
               // OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetAuditSync, methodType: 1, forContent: 1, OnView: self, withParameters: dictP!) { (dictJson) in
                OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetAuditSync, methodType: 1, forContent: 1, OnView: self, withParameters: dictP!, IsShowLoader: false)  { (dictJson) in

            if dictJson["status"] as? Int == 1 { // Means user logined
                
                self.arrDraftAuditList?[self.GIndex].isSyncStarted = 1
                self.arrDraftAuditList?[self.GIndex].isSynching = true
                self.executeUIProcess {
                    let indexPath = IndexPath(row: self.GIndex, section: 0)
                    self.tblView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
              //  self.tblView.reloadData()
                // Upadte is_sync = 1 == (AuditAnswer, Photo)
                obSqlite = SqliteDB.sharedInstance()
                _ = obSqlite.updateAudit(auditId: (self.arrDraftAuditList?[self.intSyncIndex].audit_id!)!, updateType: "isStartSync", auditStatus: 0, countryId: 0, language: "", isSyncCompleted: 0, answersAreSynced: Int(self.intTotalAnswersSynced), answersForSync: Int(self.intTotalAnswersForSync))
                self.arrDraftAuditList?[self.intSyncIndex].isSyncStarted = 1
                _ = obSqlite.updateAuditAnswerData(obAns: AuditAnswerModel(), incId: (obSync?.incIdAAT!)!, updateType: "sync")
                
                if (obSync?.arrMainSLSFPId?.count)! > 0 {
                        for i in 0..<(obSync?.arrMainSLSFPId?.count)! {
                            autoreleasepool {
                            obSqlite.updatePhotoSyncData(primaryId: obSync!.arrMainSLSFPId![i] as! Int)
                        }
                    }
                }
                
                if (obSync?.arrMultiSLSFPId?.count)! > 0 {
                    
                    for i in 0..<(obSync!.arrMultiSLSFPId?.count)! {
                        autoreleasepool {
                        obSqlite.updatePhotoSyncData(primaryId: obSync!.arrMultiSLSFPId![i] as! Int)
                        }
                    }
                }
                
                obSqlite.updateLocationSubFolder(incId: obSync!.incIdLSFL!, isArchive: 0, base64Str: "", subfolderTitle: "", subfolderDescription: "", updateType: "isSync")
                
                self.indexValue += 1
                self.intTotalAnswersSynced += 1
             //   //print(self.arrDataSync!.count)
                if self.arrDataSync!.count == 0 {
                    // Sync Complete API
                } else {
                    self.getDBData()
                } 
            }
            dictP?.removeAllObjects()
        }
         }
       // }
       
    }
    /**
     Once all the local data sync completelty on the server this api runs for aknowledege that from app side data synced
     */
    func getDataSyncComplete() {
        /// API code here
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(arrDraftAuditList?[intSyncIndex].audit_id, forKey: "audit_id")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.DataSyncCom, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                /// need to debug
                kAppDelegate.flagIsOrderSubmit = false
                MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Simple, title: NSLocalizedString("DataSynced", comment: ""), message: NSLocalizedString("AuditSynced", comment: ""))
                
                _ = obSqlite.updateAudit(auditId: self.intAuditId, updateType: "auditStatus", auditStatus: (self.arrDraftAuditList?[self.intSyncIndex].audit_status)!, countryId: 0, language: "", isSyncCompleted: 1, answersAreSynced: Int(self.intTotalAnswersSynced), answersForSync: Int(self.intTotalAnswersForSync))
                
                obSqlite.updateAuditSyncedStatusAndPreview(auditId: self.intAuditId, updateType: "updateReportLink" , isFinallySync: 0, auditorReport: dictJson["AuditorPDF"] as! String, inspectorReport: dictJson["InspectorPDF"] as! String)
                self.arrDraftAuditList?.removeAll()
                self.arrDraftAuditList = nil
                obSqlite = SqliteDB.sharedInstance()
                
                self.viewWillAppear(true)
                self.executeUIProcess({
                    self.tblView.reloadData()
                })
                
                 kAppDelegate.flagIsOrderSubmit = false
                ///Here I am calling api for generating report
            }
        }
    }
    
   @objc func generateReportForSyncedAudit(dictP: NSMutableDictionary?) {
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GenerateReport, methodType: 1, forContent: 1, OnView: self, withParameters: dictP!) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
            }
        }
    }
    
    func deleteAllAuditDataFromDataBase(auditId: Int) {
        // -- delete all data as respect to sync audit (Deleting all entries from all tables)
        obSqlite.deleteAllRecordFromBuiltAuditLocation()
        obSqlite.deleteAllRecordFromSubLocation()
        obSqlite.deleteLocationFolder(auditId: auditId, locationId: 0, deleteType: "all")
        obSqlite.deleteLocationSubFolder(auditId: auditId, locationId: 0, incId: 0, folderId: 0, deleteType: "all")
        obSqlite.deleteBuiltAuditSubLocation(auditId: auditId, locationId: 0, folderId: 0, subFolderId: 0, sublocationId: 0, deleteType: "all")
        obSqlite.deleteSubLocationSubFolder(incId: auditId, auditId: 0, locationId: 0, folderId: 0, subFolderId: 0, sub_locationId: 0, deleteType: "all")
        obSqlite.deleteAllRecordFromAuditQuestions()
        obSqlite.deleteQuestionAnswer(auditId: auditId, locationId: 0, folderId:0, subFolderId:0, subLocationId:0, subLocationSubFolderId: 0, deleteType: "all")
        _ = obSqlite.deleteSubLocationSubFolderPhoto(incId: 0, auditId: auditId, locationId: 0, sublocationId: 0, deleteType: "all")
    }
    
    /// New Module feature
    
    func getAuditLocationSubLocationAndQuestionData(intAuditId: Int) {
         obSqlite.deleteUnModifiedBuiltAuditLocation(intAuditId: intAuditId)
        arrAuditLocation = obSqlite.getLocationList(isModified: 1, auditId:intAuditId)
    }
    
    func getUpdatedLocationList(auditId: Int, countryId: Int) { /// Here only updated location list will be added
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(auditId, forKey: "audit_id")
        dictP.setValue(countryId, forKey: "country_id")
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetLocation, methodType: 1, forContent: 1, OnView: self, withParameters: dictP, IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                obSqlite.deleteSelectedAuditSubLocation(intAuditId: auditId)
                obSqlite.deleteSelectedAuditQuestions(intAuditId: auditId)
                self.executeUIProcess({
                    SVProgressHUD.show(withStatus: "Downloading Files\n\nProcessing the download, Please wait.....")
                })
                
               var flagIsExist = false
                
                var arrResponseLocation:[LocationModel]? = [LocationModel]()
                let arrResponse = dictJson["response"] as! NSArray
                
                for i in 0..<arrResponse.count {
                    
                    let obLocation: LocationModel? = LocationModel()
                    obLocation?.initWith(dict: arrResponse[i] as! NSDictionary, auditId: auditId)
                    arrResponseLocation?.append(obLocation!)

                }
               //print("(self.arrAuditLocation?.count)! = \((self.arrAuditLocation?.count)!), (arrResponseLocation?.count)! = \((arrResponseLocation?.count)!)")
                
                for i in 0..<(self.arrAuditLocation?.count)! {
                    for k in 0..<(arrResponseLocation?.count)! {
                        if arrResponseLocation?[k].locationId == self.arrAuditLocation?[i].locationId {
                            arrResponseLocation?[k].isModified = 1
                            break
                        }
                    }
                }
               //print(" (arrResponseLocation?.count)! = \((arrResponseLocation?.count)!)")
                
                for j in 0..<(arrResponseLocation?.count)! {
                    if arrResponseLocation?[j].isModified == 0 {
                        //print("arrResponseLocation?[j].locationId = \(arrResponseLocation?[j].locationName)")
                        obSqlite.insertLocationData(obLocation: (arrResponseLocation?[j])!)
                    }
                }
                
                self.getSubLocationDataList(auditId: auditId)
            }
        }
    }
    
    func getSubLocationDataList(auditId: Int) {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(auditId, forKey: "audit_id")
        dictP.setValue(strCountryId, forKey: "country_id")
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetSubLocation, methodType: 1, forContent: 1, OnView: self, withParameters: dictP, IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                
                //   self.view_Option.alpha = 0.0
                let arrResponse = dictJson["response"] as! NSArray
                
                /// This will store all location data firstly
                for i in 0..<arrResponse.count {
                    let obSubLoc: SubLocationModel? = SubLocationModel()
                    obSubLoc?.initWith(dict: arrResponse[i] as! NSDictionary, auditId: auditId, locationId: 0)
                    obSqlite.insertSubLocationData(obSubLoc: obSubLoc!)
                }
                
                self.getFinalQuestionList(auditId: auditId)
            }
            
        }
    }
    
    func getFinalQuestionList(auditId: Int) {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(auditId, forKey: "audit_id")
        dictP.setValue(strCountryId, forKey: "country_id")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetFinalQuestionList, methodType: 1, forContent: 1, OnView: self, withParameters: dictP, IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                let dictResponse = dictJson["response"] as! NSDictionary
                
                if let arrNQ = dictResponse["normal_questions"] as? NSArray {
                    
                    for g in 0..<arrNQ.count {
                        let arrNormalQuestions = arrNQ[g] as! NSArray
                        for i in 0..<arrNormalQuestions.count {
                            autoreleasepool {
                                let obQ:QuestionsModel? = QuestionsModel()
                                obQ?.initWith(dict: arrNormalQuestions[i] as! NSDictionary, questionCategory: QuestionCategory.Normal, auditId: auditId, locationId: 0, locationIds: "", subLocationId: 0, isSubQuestion: 0, parentQuestionId: 0)
                                /// Insert int question table
                                obSqlite.insertQuestionsData(obQuestion: obQ!)
                            }
                        }
                    }
                }
                
                if let arrMQ = dictResponse["measurement_questions"] as? NSArray {
                    
                    for j in 0..<arrMQ.count {
                        let arrMeasurementQuestions = arrMQ[j] as! NSArray
                        for l in 0..<arrMeasurementQuestions.count {
                            autoreleasepool {
                                let obQ:QuestionsModel? = QuestionsModel()
                                obQ?.initWith(dict: arrMeasurementQuestions[l] as! NSDictionary, questionCategory: QuestionCategory.Measurement, auditId: auditId, locationId: 0, locationIds: "", subLocationId: 0, isSubQuestion: 0, parentQuestionId: 0)
                                /// Insert int question table
                                obSqlite.insertQuestionsData(obQuestion: obQ!)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    SVProgressHUD.dismiss()
                  //  self.showAlertViewWithMessage("New Content and metadata updated successfully", vc: self)
                    self.intPopUpIndex = 2
                    MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.SimpleAction, title: "Updated!", message: "New Content and metadata updated successfully")
                })
                
            }
        }
    }
}

extension DraftsViewController: PopUpDelegate {
    
    func actionOnOk() {
        
    }
    
    func actionOnYes() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.syncAuditData()
        }
    }
    
    func actionOnNo() {
        
    }
    
    @objc func syncInThread() {
       syncAuditData()
    }
    
}

