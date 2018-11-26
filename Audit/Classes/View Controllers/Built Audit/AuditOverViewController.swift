//
//  AuditOverViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class AuditOverViewController: UIViewController {

    var arrP = [String]()
    @IBOutlet weak var colView_Files: UICollectionView!
    var arrFiles = NSMutableArray()
    
    @IBOutlet weak var tblView_FIles: UITableView!
    @IBAction func btn_CloseFileView(_ sender: Any) {
        view_Files.alpha = 0.0 
    }
    @IBOutlet var view_Files: UIView!
    //MARK: Varibale & Outlest:
    @IBOutlet weak var lbl_Area: UILabel!
    @IBOutlet weak var lbl_DueDate: UILabel!
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_Date: UILabel!
    @IBOutlet weak var lbl_PropertyDescription: UILabel!
    @IBOutlet weak var lbl_PropertyName: UILabel!
    @IBOutlet weak var btn_Accept: UIButton!
    @IBOutlet weak var btn_Reject: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var view_AuditDetail: UIView!
    @IBOutlet weak var imgView_Agent: UIImageView!
    @IBOutlet weak var lbl_AgentNumber: UILabel!
    @IBOutlet weak var lbl_AgentEmail: UILabel!
    @IBOutlet weak var lbl_AgentName: UILabel!
    @IBOutlet weak var lbl_AgentDetail: UILabel!
    @IBOutlet weak var view_ClientDetail: UIView!
    @IBOutlet weak var view_AgentDetail: UIView!
    @IBOutlet weak var imgView_File: UIImageView!
    @IBOutlet weak var lbl_ClientPInCode: UILabel!
    @IBOutlet weak var lbl_ClientLandmark: UILabel!
    @IBOutlet weak var lbl_ClientNUmber: UILabel!
    @IBOutlet weak var lbl_ClientAddress: UILabel!
    @IBOutlet weak var lbl_ClientDetail: UILabel!
    @IBOutlet weak var lbl_ClientName: UILabel!
    @IBOutlet weak var lbl_attcahment: UILabel!
    
    //Mark: Variables
    var str_notify_id = ""
    var str_pdf = ""
    var str_number = ""
    var dictData: NSDictionary? = NSDictionary()
    
    //MARK: ViewLIfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
        getAuditOverViewDetails()
        
        view_Files.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_Files)
        view_Files.alpha = 0.0
    }
    
    //MARK: Button Actions:
    @IBAction func btn_Accept(_ sender: Any) {
        AcceptRejectAudit(status: "1")
    }
    
    func AcceptRejectAudit(status:String) {
        
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue((dictData!["auditDetails"] as! NSDictionary)["id"], forKey: "audit_id")
        dictP.setValue(status, forKey: "status")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetAuditStatus, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means notification detail
                
                if status == "1" {
                    let obAudit = MyAuditListModel()
                    obAudit.initWith(dict: self.dictData!)
                    obSqlite.insertMyAuditList(obAudit: obAudit)
                  //  if arr[0] == true {
                        let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
                        navigationController.viewControllers = [MF.setUpTabBarView(selectedIndex:4)]
                        MF.animateViewNavigation(navigationController: navigationController)
                        kAppDelegate.window?.rootViewController = navigationController
//                    } else {
//                        self.showAlertViewWithMessage(arr[1] as! String, vc: self)
//                    }
                }
                else {
                    let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
                    navigationController.viewControllers = [MF.setUpTabBarView(selectedIndex:0)]
                    MF.animateViewNavigation(navigationController: navigationController)
                    kAppDelegate.window?.rootViewController = navigationController
                }
            }
        }
    }
    
    @IBAction func btn_CallAgent(_ sender: Any) {
        if let url = URL(string: "tel://\(str_number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btn_Reject(_ sender: Any) {
        AcceptRejectAudit(status: "2")
    }
    
    //MARK: Supporting Functions:
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Accept.setTitle(NSLocalizedString("Accept", comment: ""), for: UIControlState.normal)
        btn_Reject.setTitle(NSLocalizedString("Reject", comment: ""), for: UIControlState.normal)
    }
    
    func setAuditOverViewDetail(dict:NSDictionary) {
        
        lbl_PropertyName.text = dict["title"] as? String
        lbl_PropertyDescription.text = dict["description"] as? String
        
        let start_date = dc.change(date: (dict["start_date"] as? String)!, format: "yyyy-MM-dd", to: "dd-MMM-yyyy")
        lbl_Date.text = String(format: "%@:  %@", NSLocalizedString("Date", comment: ""),start_date)
        
        let end_date = dc.change(date: (dict["end_date"] as? String)!, format: "yyyy-MM-dd", to: "dd-MMM-yyyy")
        lbl_DueDate.text = String(format: "%@:  %@", NSLocalizedString("DueDate", comment: ""),end_date)
        
        let time = dc.change(date: (dict["time"] as? String)!, format: "HH:mm:ss", to: "hh:mm a")
        lbl_Time.text = String(format: "%@:  %@", NSLocalizedString("Time", comment: ""),time)
        
        lbl_Area.text = String(format: "%@:  %@", NSLocalizedString("Area", comment: ""),(dict["city"] as? String)!)
    }
    
    func setAgentDetail(dict:NSDictionary) {
        
        imgView_Agent.sd_setImage(with: URL(string: (dict["photo"] as? String)!), placeholderImage: UIImage.init(named: ""))
        lbl_AgentName.text = String(format: "%@:  %@", NSLocalizedString("Name", comment: ""),(dict["fulname"] as? String)!)
        lbl_AgentEmail.text = String(format: "%@:  %@", NSLocalizedString("Email", comment: ""),(dict["email"] as? String)!)
        lbl_AgentNumber.text = String(format: "%@:  %@", NSLocalizedString("Number", comment: ""),(dict["phone"] as? String)!)
        str_number = (dict["phone"] as? String)!
    }
    
    func setContactPerson(dict:NSDictionary) {

        lbl_ClientName.text = String(format: "%@:  %@", NSLocalizedString("Name", comment: ""),(dict["name"] as? String)!)
        lbl_ClientAddress.text = String(format: "%@:  %@", NSLocalizedString("Address", comment: ""),(dict["address"] as? String)!)
        lbl_ClientNUmber.text = String(format: "%@:  %@", NSLocalizedString("Number", comment: ""),(dict["phone"] as? String)!)
        lbl_ClientLandmark.text = String(format: "%@:  %@", NSLocalizedString("Landmark", comment: ""),(dict["landmark"] as? String)!)
        lbl_ClientPInCode.text = String(format: "%@:  %@", NSLocalizedString("PinCode", comment: ""),(dict["pincode"] as? String)!)
        
        let document = dict["document"] as! NSArray
        if document.count == 0 {
            imgView_File.image = UIImage.init(named: "")
        } else {
            imgView_File.image = UIImage.init(named: "icon_pdf")
            self.arrFiles = (dict["document"] as! NSArray).mutableCopy() as! NSMutableArray
            if document.count > 1 {
                str_pdf = document[0] as! String
                imgView_File.image = UIImage.init(named: "icon_pdf")
                let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showpdf(_:)))
                tapGestureRecognizer11.numberOfTapsRequired = 1
                imgView_File.addGestureRecognizer(tapGestureRecognizer11)
            } else {
                str_pdf = document[0] as! String
                imgView_File.image = UIImage.init(named: "icon_pdf")
                let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showpdf(_:)))
                tapGestureRecognizer11.numberOfTapsRequired = 1
                imgView_File.addGestureRecognizer(tapGestureRecognizer11)
            }
        }
    }
    
    @IBAction func showpdf(_ sender: UITapGestureRecognizer) {
//        if let url = URL(string: "\(str_pdf)") {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
        if arrFiles.count > 1 {
            colView_Files.reloadData()
            view_Files.alpha = 1.0
        } else {
            downloadFilesFromList(intIndex: 0)
        }
    }
    
    func getAuditOverViewDetails() {
        ///API Code here
        let dictP = NSMutableDictionary()
        dictP.setValue(UserProfile.id, forKey: "id")
        dictP.setValue(UserProfile.authToken, forKey: "auth_token")
        dictP.setValue(str_notify_id, forKey: "notify_id")
        dictP.setValue("Audit", forKey: "type")

        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.NotificationDetails, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means notification detail
                
                self.dictData = dictJson["response"] as? NSDictionary
                
                if let dictAudit = self.dictData!["auditDetails"] as? NSDictionary {
                    self.setAuditOverViewDetail(dict: dictAudit)
                }
                
                if let dictAgent = self.dictData!["agentDetails"] as? NSDictionary {
                    self.setAgentDetail(dict: dictAgent)
                }
                
                if let dictPerson = self.dictData!["contactPerson"] as? NSDictionary {
                    self.setContactPerson(dict:dictPerson)
                }
            }
        }
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AuditOverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 175 , height: 215)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FileDownloaderCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileDownloaderCell", for: indexPath) as! FileDownloaderCell
        cell.setFileData(file: arrFiles[indexPath.row] as! String)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        downloadFilesFromList(intIndex: indexPath.row)
    }
    
    @objc func downloadFiles() {
        let obFDM = FileDownloaderManager()
        obFDM.downloadFileDataInBackground(arrParam: arrP)
    }
    
    func downloadFilesFromList(intIndex: Int) {
        var strFilePath = arrFiles[intIndex] as! String
        let arrFP = strFilePath.components(separatedBy: "/")
        let strFileName = arrFP.last
        let arrExt = strFileName?.components(separatedBy: ".")
        view_Files.alpha = 0.0
        
        strFilePath = strFilePath.replacingOccurrences(of: " ", with: "%20")
        arrP = [strFilePath, strFileName!, (arrExt?.last)!]
        DispatchQueue.main.async {
            SVProgressHUD.show(withStatus: "Downloading....")
        }
        
        if (arrExt?.last)! == FileExtension.PNG || (arrExt?.last)! == FileExtension.JPEG || (arrExt?.last)! == FileExtension.JPG {
            let obFDM = FileDownloaderManager()
            obFDM.downloadImageData(strUrl: strFilePath)
        } else {
            self.performSelector(inBackground: #selector(self.downloadFiles), with: nil)
        }
    }
   
}
