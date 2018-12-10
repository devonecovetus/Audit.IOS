//
//  AuditViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 24/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class AuditViewController: UIViewController {
    
    var intAuditId = Int()
    var intPickerStatus = 1
    var strCountryId = String()
    var strLanguageId = String()
    
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
        
        if Preferences.value(forKey: "is_my_auditHistory") == nil {
            getMyAudit_HistoryList()
        }
        arrMyAuditList = obSqlite.getAuditListWith(status: AuditStatus.InComplete)
    }
    
    func getMyAudit_HistoryList() {
       
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetauditHistory, methodType: 1, forContent: 1, OnView: self, withParameters: MF.initializeDictWithUserId()) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                Preferences.set("1", forKey: "is_my_auditHistory")
                let arrresponse = (dictJson["response"] as! NSDictionary)["history"] as! NSArray
                
                for item in arrresponse {
                  
                    let obRequest = MyAuditListModel()
                    obRequest.initWith(dict: (item as? NSDictionary)!)
                    
                    let Items = self.arrMyAuditList.filter { $0.audit_id == obRequest.audit_id }
                    if Items.count == 0 {
                        print("insert data")
                        obSqlite.insertMyAuditList(obAudit: obRequest)
                        self.arrMyAuditList.append(obRequest)
                    }
                }
                self.tblView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view_Option.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_Option)
        view_Option.alpha = 0.0
        
        view_Picker.frame = CGRect(x: 10, y: view_Option.frame.size.height - (view_Picker.frame.size.height + 10), width: ScreenSize.SCREEN_WIDTH - 20 , height: view_Picker.frame.size.height)
        self.view_Option.addSubview(view_Picker)
        view_Picker.alpha = 0.0
        
        MF.addShadowToView(viewShadow: view_Picker, andRadius: 10)
        MF.addBorderAndCornerRadius(view: view_Picker, andRadius: 10)
    }
    
    //MARK: Button Actions:
    @IBAction func btn_Sorting(_ sender: Any) {
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
        }
        view_Picker.alpha = 0.0
    }
    
    @IBAction func btn_SelectLanguage(_ sender: Any) {
        
        if strCountryId.count == 0 {
            self.showAlertViewWithMessage("Please select country standard first", vc: self)
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
            self.getModulesSubModulesAndQuestionnaries(auditId: intAuditId)
        }
    }
    
    @IBAction func btn_SelectCountry(_ sender: Any) {
        intPickerStatus = 1
        view_Picker.alpha = 1.0
        pkrView.reloadAllComponents()
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

                if let response = dictJson["response"] as? NSArray {
                    self.showAlertViewWithMessage("No country standard found.", vc: self)
                } else {
                    if let response1 = dictJson["response"] as? NSDictionary {
                        if let arr = response1["standard"] as? NSArray {
                            self.arrCountryList = arr.mutableCopy() as! NSMutableArray
                            self.pkrView.reloadAllComponents()
                        }
                    }
                }
            }
        }
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
        let arr = obSqlite.checkAnyBuiltAuditEntryExistOrNot()
        if arr[0] as! Bool == true {
            if arr[1] as? Int == arrMyAuditList[index].audit_id {
                self.showAlertViewWithMessage("Data for this audit is already downloaded", vc: self)
            } else {
                self.showAlertViewWithMessage("You cannot download another audit data until you sync previous one", vc: self)
            }
        } else {
            view_Option.alpha = 1.0
            intAuditId = arrMyAuditList[index].audit_id!
            self.performSelector(inBackground: #selector(self.getCountryList), with: nil)
            // getModulesSubModulesAndQuestionnaries(auditId: arrMyAuditList[index].audit_id!)
        }
    }
    
    func getModulesSubModulesAndQuestionnaries(auditId: Int) {
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(auditId, forKey: "audit_id")
        dictP.setValue(strCountryId, forKey: "country_id")
        dictP.setValue(strLanguageId, forKey: "lang")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetQuestions, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                self.view_Option.alpha = 0.0
                let arrResponse = dictJson["response"] as! NSArray
                
                for i in 0..<arrResponse.count {
                    let dictR = arrResponse[i] as! NSDictionary
                    let arrModules = dictR["Milti_lang_modules"] as! NSArray
                    for j in 0..<arrModules.count {
                        let dictM = arrModules[j] as! NSDictionary
                        
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
                            
                            //for saving questions
                            //1. Measurement question type
                            let arrMQ = dictSubLoc["measurement_questions"] as! NSArray
                            
                            for l in 0..<arrMQ.count {
                                let obQ = QuestionsModel()
                                obQ.initWith(dict: arrMQ[l] as! NSDictionary, questionCategory: QuestionCategory.Measurement, auditId: auditId, locationId: obLocation.locationId!, subLocationId: obSubLoc.subLocationId!)
                                /// Insert int question table
                                obSqlite.insertQuestionsData(obQuestion: obQ)
                            }
                            //For saving Questions2. NOrmal type
                            let arrNQ = dictSubLoc["normal_questions"] as! NSArray
                            
                            for l in 0..<arrNQ.count {
                                let obQ = QuestionsModel()
                                obQ.initWith(dict: arrNQ[l] as! NSDictionary, questionCategory: QuestionCategory.Normal, auditId: auditId, locationId: obLocation.locationId!, subLocationId: obSubLoc.subLocationId!)
                                /// Insert int question table
                                obSqlite.insertQuestionsData(obQuestion: obQ)
                            }
                        }
                    }
                }
                if arrResponse.count > 0 {
                    /// This will update the audit list and audit status to incomplete to pending
                  //  let arr = obSqlite.updateAuditWorkStatus(auditStatus: AuditStatus.Pending, auditId: auditId)
                 //   if arr[0] as! Bool == true {
                     //   self.showAlertViewWithDuration(arr[1] as! String, vc: self)
                     //   self.arrMyAuditList = obSqlite.getAuditListWith(status: AuditStatus.InComplete)
                    //    self.tblView.reloadData()
                        //here to navigate to built audsit screenß
                        let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltAuditViewController") as! BuiltAuditViewController
                        vc.intAuditId = auditId
                        self.navigationController?.pushViewController(vc, animated: true)
                   // }
                }
                else {
                    self.showAlertViewWithMessage("No Audit information avaliable so you cannot be proceed any more", vc: self)
                }
            }
        }
    }
}

extension AuditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if intPickerStatus == 1 {
            return arrCountryList.count
        } else if intPickerStatus == 2 {
            return arrLanguageList.count
        }
        return 0
    }
    
    // MARK: UIPickerViewDelegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if intPickerStatus == 1 {
            return (arrCountryList[row] as! NSDictionary)["country"] as? String
        } else {
            return (arrLanguageList[row] as! NSDictionary)["title"] as? String
        }
    }
    
}
