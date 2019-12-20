//
//  AuditViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 24/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class AuditViewController: UIViewController {
    var auditType = Int()
    var intAuditId = Int()
    var intPickerStatus = 1
    var strCountryId = String()
    var strLanguageId = String()
    var strLanguage = String()
    var intPopUpIndex = Int()
    var intTotalLocationsCount = Int()
    var intIndexCount = Int()
    var flagIsUploadPic = false
    var imagePicker:UIImagePickerController? = UIImagePickerController()
    
    var arrLocations: [LocationModel] = [LocationModel]()

    @IBOutlet weak var imgView_Audit: UIImageView!

    @IBOutlet weak var lbl_SelectImage: UILabel!
    @IBOutlet weak var btn_PIckerCancel: UIButton!
    @IBOutlet weak var pkrView: UIPickerView!
    @IBOutlet weak var btn_PIckerDone: UIButton!
    @IBOutlet weak var btn_SelectLanguage: UIButton!
    @IBOutlet weak var lbl_Language: UILabel!
    @IBOutlet weak var btn_SelectCountry: UIButton!
    @IBOutlet weak var lbl_SelectCountry: UILabel!
    @IBOutlet weak var lbl_OptionMsg: UILabel!
    @IBOutlet weak var lbl_OptionTitle: UILabel!
    @IBOutlet var view_Option: UIView!
    @IBOutlet var view_Picker: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btn_Sorting: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    var arrMyAuditList = [MyAuditListModel]()
    var arrCountryList = NSMutableArray()
    var arrLanguageList = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
        
        let arrFullAuditList = obSqlite.getAuditList(status: 0, fetchType: "all")
        if arrFullAuditList.count == 0 {
             getMyAudit_HistoryList()
        } else {
            self.arrMyAuditList = obSqlite.getAuditList(status: AuditStatus.InComplete, fetchType: "byStatus")
             self.executeUIProcess({
                self.tblView.reloadData()
             })
        }
    }
    
    func getMyAudit_HistoryList() {
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetauditHistory, methodType: 1, forContent: 1, OnView: self, withParameters: MF.initializeDictWithUserId()) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                Preferences?.set("1", forKey: "is_my_auditHistory")
                let arrresponse = (dictJson["response"] as! NSDictionary)["history"] as! NSArray
                for item in arrresponse {
                    autoreleasepool {
                        let obRequest = MyAuditListModel()
                        obRequest.initWith(dict: (item as? NSDictionary)!)
                        let Items = self.arrMyAuditList.filter { $0.audit_id == obRequest.audit_id }
                        if Items.count == 0 {
                            obSqlite.insertMyAuditList(obAudit: obRequest)
                            self.arrMyAuditList.append(obRequest)
                        }
                    }
                }
                self.executeUIProcess({
                    self.tblView.reloadData()
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !flagIsUploadPic {
  
            view_Option.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT)
            self.view.addSubview(view_Option)
            view_Option.alpha = 0.0
            
            view_Picker.frame = CGRect(x: 10, y: view_Option.frame.size.height - (view_Picker.frame.size.height + 10), width: ScreenSize.SCREEN_WIDTH - 20 , height: view_Picker.frame.size.height)
            self.view_Option.addSubview(view_Picker)
            view_Picker.alpha = 0.0
            
            MF.addShadowToView(viewShadow: view_Picker, andRadius: 10)
            MF.addBorderAndCornerRadius(view: view_Picker, andRadius: 10)
        }
    }
    
    //MARK: Button Actions:
    @IBAction func btn_SelectImage(_ sender: Any) {
        MF.openActionSheet(with: imagePicker!, and: self, targetFrame: imgView_Audit.frame)
    }
    
    @IBAction func btn_Sorting(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: NSLocalizedString("SortBy", comment: ""), preferredStyle: .actionSheet)
        let openDateAction = UIAlertAction(title: NSLocalizedString("ByDate", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.arrMyAuditList = self.arrMyAuditList.sorted { $0.target_date! < $1.target_date! } // DATE ascending order
            self.tblView.reloadData()
        })
        
        let openTitleAction = UIAlertAction(title: NSLocalizedString("ByTitle", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.arrMyAuditList = self.arrMyAuditList.sorted { $0.audit_title! < $1.audit_title! } // Name ascending order
            self.tblView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(openDateAction)
        optionMenu.addAction(openTitleAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.sourceRect = btn_Sorting.frame
        optionMenu.popoverPresentationController?.sourceView = self.view
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        view_Option.alpha = 0.0
    }
    
    @IBAction func btn_PickerCancel(_ sender: Any) {
        view_Picker.alpha = 0.0
    }
    
    @IBAction func btn_PickerDone(_ sender: Any) {
        if intPickerStatus == 1 {
            let dict = arrCountryList[pkrView.selectedRow(inComponent: 0)] as! NSDictionary
            btn_SelectCountry.setTitle(dict["country"] as? String, for: UIControlState.normal)
            strCountryId = String(format: "%d", dict["country_id"] as! Int)
            arrLanguageList = (dict["language"] as! NSArray).mutableCopy() as! NSMutableArray
            pkrView.reloadAllComponents()
           
        } else if intPickerStatus == 2 {
            let dict = arrLanguageList[pkrView.selectedRow(inComponent: 0)] as! NSDictionary
            btn_SelectLanguage.setTitle(dict["title"] as? String, for: UIControlState.normal)
            strLanguageId = dict["lang"] as! String
            strLanguage = dict["title"] as! String
        }
        view_Picker.alpha = 0.0
    }
    
    @IBAction func btn_SelectLanguage(_ sender: Any) {
        if strCountryId.count == 0 {
            self.showAlertViewWithMessage(NSLocalizedString("selectCountryStandard", comment: ""), vc: self)
        } else {
            intPickerStatus = 2
            view_Picker.alpha = 1.0
            pkrView.reloadAllComponents()
        }
    }
    
    @IBAction func btn_Ok(_ sender: Any) {
        if checkValidations().count > 0 {
            self.showAlertViewWithMessage(checkValidations(), vc: self)
        } else {
            
            MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("AuditAlert", comment: ""))
        }
    }
    
    @IBAction func btn_SelectCountry(_ sender: Any) {
        if arrCountryList.count > 0 {
            intPickerStatus = 1
            view_Picker.alpha = 1.0
            pkrView.reloadAllComponents()
        } else{
            self.showAlertViewWithMessage(NSLocalizedString("noCountryList", comment: ""), vc: self)
        }
    }
    
    // MARK: - Supporting Methods
    func checkValidations() -> String {
        var strMsg = ""
        if intAuditId == 0 {
            strMsg = ValidationMessages.selectAuditId
        } else if strCountryId.count == 0 {
            strMsg = ValidationMessages.selectCountry
        } else if strLanguageId.count == 0 {
            strMsg = ValidationMessages.selectLanguage
        }
        return strMsg
    }
    
    @objc func getCountryList() {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(intAuditId, forKey: "audit_id")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetCountryStandard, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined

                if (dictJson["response"] as? NSArray) != nil {
                    self.showAlertViewWithMessage(NSLocalizedString("noCountryList", comment: ""), vc: self)
                } else {
                    if let response1 = dictJson["response"] as? NSDictionary {
                        self.auditType = (response1["auditStatus"] as? Int)!
                        if let arr = response1["standard"] as? NSArray {
                            self.arrCountryList = arr.mutableCopy() as! NSMutableArray
                            self.executeUIProcess({
                                self.pkrView.reloadAllComponents()
                            })
                        }
                    }
                }
            }
        }
    }
 
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Sorting.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        pkrView.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_SelectCountry.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Language.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            btn_SelectCountry.contentHorizontalAlignment = .right
            btn_SelectLanguage.contentHorizontalAlignment = .right
        }
    }
    
    func getFullAuditData(auditId: Int) {
        DispatchQueue.main.async(execute: {
            SVProgressHUD.show(withStatus: NSLocalizedString("DownloadingData....", comment: ""))
        })
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(auditId, forKey: "audit_id")
        dictP.setValue(strCountryId, forKey: "country_id")
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetQuestionData, methodType: 1, forContent: 1, OnView: self, withParameters: dictP, IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                //print("dictJson = \(dictJson)")
                
                let obFM: FileDownloaderManager? = FileDownloaderManager()
                
                if let strFP = dictJson["response"] as? String {
                    obFM?.saveAuditDataContent(fileUrl: strFP, callBackFile: { (filePath) in
                        //print("filepath created and returned= \(filePath)")
                        
                        // self.executeUIProcess {
                        let arr = [URL(string: filePath) as Any, auditId] as [Any]
                        self.performSelector(inBackground: #selector(self.downloadFileDataInBackground(arrData:)), with: arr)
                        //self.downloadFileData(fileUrl: URL(string: filePath)!, auditId: auditId)
                        // }
                    })
                }
            }
        }
    }
    
    @objc func downloadFileDataInBackground(arrData: NSArray) {
        //print("arrData = \(arrData[0]), \(arrData[1])")
        self.downloadFileData(fileUrl: arrData[0] as! URL, auditId: arrData[1] as! Int)
    }
    
    func downloadFileData(fileUrl: URL, auditId: Int) {
        
        //   DispatchQueue.main.async(execute: {
        let fileData = try? Data(contentsOf: fileUrl, options: [])
        let strP = "%"
        do {
            let dictJson = try JSONSerialization.jsonObject(with: fileData!, options: []) as! [String: Any]
            let arrResponse = (dictJson["original"] as! NSDictionary)["response"] as! NSArray
            
            self.intTotalLocationsCount = arrResponse.count
            
            //print("self.intTotalLocationsCount = \(self.intTotalLocationsCount)")
            self.intIndexCount = 1
            for i in 0..<arrResponse.count {
                self.intIndexCount = i + 1
                
                let progressCount = (CGFloat(self.intIndexCount) / CGFloat(self.intTotalLocationsCount)) * 100
                let strProgress = String(format: "%@\n%.1f%@", NSLocalizedString("DownloadingData....", comment: ""), progressCount, strP)
                
                // DispatchQueue.main.async(execute: {
                self.executeUIProcess({
                    //print("intIndexCount = \(self.intIndexCount)")
                    SVProgressHUD.show(withStatus: strProgress)
                })
                
                //})
                autoreleasepool {
                    let dictR = arrResponse[i] as! NSDictionary
                    let arrModules = dictR["Milti_lang_modules"] as! NSArray
                    for j in 0..<arrModules.count {
                        
                        autoreleasepool {
                            let dictM = arrModules[j] as! NSDictionary
                            
                            ///Saving Location obj
                            
                            let obLocation = LocationModel()
                            obLocation.initWith(dict: dictM, auditId: auditId)
                            obSqlite.insertLocationData(obLocation: obLocation)
                            
                            /// Saving Sublocation Obj
                            let arrSubLocation = dictM["categories"] as! NSArray
                            for k in 0..<arrSubLocation.count {
                                
                                autoreleasepool {
                                    let dictSubLoc = arrSubLocation[k]as! NSDictionary
                                    let obSubLoc = SubLocationModel()
                                    obSubLoc.initWith(dict: dictSubLoc, auditId: auditId, locationId: obLocation.locationId!)
                                    obSqlite.insertSubLocationData(obSubLoc: obSubLoc)
                                    
                                    //for saving questions
                                    //1. Measurement question type
                                    let arrMQ = dictSubLoc["measurement_questions"] as! NSArray
                                    
                                    for l in 0..<arrMQ.count {
                                        autoreleasepool {
                                            let obQ = QuestionsModel()
                                            obQ.initWith(dict: arrMQ[l] as! NSDictionary, questionCategory: QuestionCategory.Measurement, auditId: auditId, locationId: obLocation.locationId!, subLocationId: obSubLoc.subLocationId!, isSubQuestion: 0, parentQuestionId: 0)
                                            /// Insert int question table
                                            obSqlite.insertQuestionsData(obQuestion: obQ)
                                        }
                                    }
                                    //For saving Questions2. NOrmal type
                                    let arrNQ = dictSubLoc["normal_questions"] as! NSArray
                                    
                                    for l in 0..<arrNQ.count {
                                        autoreleasepool {
                                            let obQ = QuestionsModel()
                                            obQ.initWith(dict: arrNQ[l] as! NSDictionary, questionCategory: QuestionCategory.Normal, auditId: auditId, locationId: obLocation.locationId!, subLocationId: obSubLoc.subLocationId!, isSubQuestion: 0, parentQuestionId: 0 )
                                            /// Insert int question table
                                            obSqlite.insertQuestionsData(obQuestion: obQ)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            /// This will go for next screen part
            if self.intIndexCount == self.intTotalLocationsCount {
                DispatchQueue.main.async(execute: {
                    SVProgressHUD.dismiss()
                    let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltAuditViewController") as! BuiltAuditViewController
                    vc.intAuditId = auditId
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                
            }
            
        } catch let err as Error {
            //print(" JSOn parsing error = \(err.localizedDescription)")
        }
        //   })
        
    }
    
    /**
     get location api calling
     */
    
    func getLocationList(auditId: Int) {
        let imgBase64String = imgView_Audit.image?.imageQuality(.low)?.base64EncodedString(options: .lineLength64Characters)
        
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(auditId, forKey: "audit_id")
        dictP.setValue(strCountryId, forKey: "country_id")
        dictP.setValue(imgBase64String, forKey: "audit_image")
        
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetLocation, methodType: 1, forContent: 1, OnView: self, withParameters: dictP, IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                
                self.executeUIProcess({
                    SVProgressHUD.show(withStatus: "Downloading Files\n\nProcessing the download, Please wait.....")
                })
                
                //   self.view_Option.alpha = 0.0
                let arrResponse = dictJson["response"] as! NSArray
                
                _ = obSqlite.updateAudit(auditId: auditId, updateType: "lang&Country", auditStatus: 0, countryId: Int(self.strCountryId)!, language: self.strLanguageId, isSyncCompleted: 0, answersAreSynced: 0, answersForSync: 0)
                
                obSqlite.deleteSelectedAuditQuestions(intAuditId: auditId)
                obSqlite.deleteSelectedBuiltAuditLocation(intAuditId: auditId)
                obSqlite.deleteSelectedAuditSubLocation(intAuditId: auditId)
                
                /// This will store all location data firstly
                for i in 0..<arrResponse.count {
                    let obLocation: LocationModel? = LocationModel()
                    obLocation?.initWith(dict: arrResponse[i] as! NSDictionary, auditId: auditId)
                    obSqlite.insertLocationData(obLocation: obLocation!)
                }
                
                /// Once location data saved in Database, we move on sublocation module.
                /// Api func calling for sublocation
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
                
                _ = obSqlite.updateAudit(auditId: auditId, updateType: "lang&Country", auditStatus: 0, countryId: Int(self.strCountryId)!, language: self.strLanguageId, isSyncCompleted: 0, answersAreSynced: 0, answersForSync: 0)
                
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
                    self.view_Option.alpha = 0.0
                    let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltAuditViewController") as! BuiltAuditViewController
                    vc.intAuditId = auditId
                    self.navigationController?.pushViewController(vc, animated: true)
                })
               
            }
        }
    }
    
    /**
     This func calls and download all the location data into database and
     */
    func getLocationData(auditId: Int) {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(auditId, forKey: "audit_id")
        dictP.setValue(strCountryId, forKey: "country_id")
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetLocation, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                SVProgressHUD.show(withStatus: NSLocalizedString("DownloadingData....", comment: ""))
                //   self.view_Option.alpha = 0.0
                let arrResponse = (dictJson["response"] as! NSDictionary)["productDetails"] as! NSArray
                
                _ = obSqlite.updateAudit(auditId: auditId, updateType: "lang&Country", auditStatus: 0, countryId: Int(self.strCountryId)!, language: self.strLanguageId, isSyncCompleted: 0, answersAreSynced: 0, answersForSync: 0)
                
                obSqlite.deleteSelectedAuditQuestions(intAuditId: auditId)
                obSqlite.deleteSelectedBuiltAuditLocation(intAuditId: auditId)
                obSqlite.deleteSelectedAuditSubLocation(intAuditId: auditId)
                
                /// This will store all location data firstly
                for i in 0..<arrResponse.count {
                    let obLocation = LocationModel()
                    obLocation.initWith(dict: arrResponse[i] as! NSDictionary, auditId: auditId)
                    obSqlite.insertLocationData(obLocation: obLocation)
                }
                
                /// Now from here, a loop run and on the behalf of location id all their subloaction and question data will be downloaded
                self.getSubLocationAndQuestionsData(auditId: auditId)
            }
        }
    }
    
    func getSubLocationAndQuestionsData(auditId: Int) {
        arrLocations = obSqlite.fetchLocationData(auditId: auditId)
        
        intTotalLocationsCount = arrLocations.count
        intIndexCount = 0
        self.executeUIProcess {
            SVProgressHUD.show(withStatus: NSLocalizedString("DownloadingData....", comment: ""))
        }
        self.getModulesSubModulesAndQuestionnaries(auditId: auditId, locationId: arrLocations[intIndexCount].locationId!)
    }
    
    func getModulesSubModulesAndQuestionnaries(auditId: Int, locationId: Int) {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(auditId, forKey: "audit_id")
        dictP.setValue(strCountryId, forKey: "country_id")
        dictP.setValue(strLanguageId, forKey: "lang")
        dictP.setValue(locationId, forKey: "location_id")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetQuestionsCopy, methodType: 1, forContent: 1, OnView: self, withParameters: dictP, IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                //    self.view_Option.alpha = 0.0
                let arrResponse = dictJson["response"] as! NSArray
                let strP = "%"
                let progressCount = (CGFloat(self.intIndexCount) / CGFloat(self.intTotalLocationsCount)) * 100
                //print("CGFloat(self.intIndexCount) = \(CGFloat(self.intIndexCount)), CGFloat(self.intTotalLocationsCount) = \(CGFloat(self.intTotalLocationsCount))")
                //print("progressCount = \(progressCount)")
                self.executeUIProcess({
                    let strProgress = String(format: "%@%.1f%@", NSLocalizedString("DownloadingData....", comment: ""), progressCount, strP)
                    SVProgressHUD.show(withStatus: strProgress)
                })

                for i in 0..<arrResponse.count {
                    autoreleasepool {
                        let dictR = arrResponse[i] as! NSDictionary
                        let arrModules = dictR["Milti_lang_modules"] as! NSArray
                        for j in 0..<arrModules.count {
                            
                            autoreleasepool {
                                let dictM = arrModules[j] as! NSDictionary
                                
                                ///Saving Location obj
                                /// 09 Jul 19, As per discussion, here the flow will be slightly change, location data will not save from this
                                /*
                                 let obLocation = LocationModel()
                                 obLocation.initWith(dict: dictM, auditId: auditId)
                                 obSqlite.insertLocationData(obLocation: obLocation)
                                 */
                                /// Saving Sublocation Obj
                                let arrSubLocation = dictM["categories"] as! NSArray
                                for k in 0..<arrSubLocation.count {
                                    
                                    autoreleasepool {
                                        let dictSubLoc = arrSubLocation[k]as! NSDictionary
                                        let obSubLoc = SubLocationModel()
                                        obSubLoc.initWith(dict: dictSubLoc, auditId: auditId, locationId: locationId)
                                        obSqlite.insertSubLocationData(obSubLoc: obSubLoc)
                                        
                                        //for saving questions
                                        //1. Measurement question type
                                        let arrMQ = dictSubLoc["measurement_questions"] as! NSArray
                                        
                                        for l in 0..<arrMQ.count {
                                            autoreleasepool {
                                                let obQ = QuestionsModel()
                                                obQ.initWith(dict: arrMQ[l] as! NSDictionary, questionCategory: QuestionCategory.Measurement, auditId: auditId, locationId: locationId, subLocationId: obSubLoc.subLocationId!, isSubQuestion: 0, parentQuestionId: 0)
                                                /// Insert int question table
                                                obSqlite.insertQuestionsData(obQuestion: obQ)
                                            }
                                        }
                                        //For saving Questions2. NOrmal type
                                        let arrNQ = dictSubLoc["normal_questions"] as! NSArray
                                        
                                        for l in 0..<arrNQ.count {
                                            autoreleasepool {
                                                let obQ = QuestionsModel()
                                                obQ.initWith(dict: arrNQ[l] as! NSDictionary, questionCategory: QuestionCategory.Normal, auditId: auditId, locationId: locationId, subLocationId: obSubLoc.subLocationId!, isSubQuestion: 0, parentQuestionId: 0 )
                                                /// Insert int question table
                                                obSqlite.insertQuestionsData(obQuestion: obQ)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                /// Herer recursion feature works
                if self.intIndexCount != self.intTotalLocationsCount - 1 {
                    self.intIndexCount += 1
                    self.getModulesSubModulesAndQuestionnaries(auditId: auditId, locationId: self.arrLocations[self.intIndexCount].locationId!)
                } else {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltAuditViewController") as! BuiltAuditViewController
                        vc.intAuditId = auditId
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                }
            }
        }
    }
    
}







