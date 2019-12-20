 //
//  ReportListViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 30/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ReportListViewController: UIViewController {
    //MARK: Variables & Outlets
    var flagIsSearch: Bool? = Bool()
    var arrReportList:[ReportModel]? = [ReportModel]()
    var arrSearch:[ReportModel]? = [ReportModel]()
    @IBOutlet weak var tblView: UITableView?
    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var lbl_Title: UILabel?
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView?.tableFooterView = UIView()
         getReportList()
        // Do any additional setup after loading the view.
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
       
    }
    
    // MARK: - Supporting Methods
    func getReportList() {
        ///API code here
        let dictP = MF.initializeDictWithUserId()
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetAuditReport, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                let dictHistory = dictJson["response"] as! NSDictionary
                for i in 0..<(dictHistory["history"] as! NSArray).count {
                    autoreleasepool {
                        let obReport = ReportModel()
                        obReport.initWith(dict: (dictHistory["history"] as! NSArray)[i] as! NSDictionary)
                        self.arrReportList?.append(obReport)
                    }
                }
            }
            self.executeUIProcess({
                self.tblView?.reloadData()
            })
        }
    }
    
    //MARK: Button Actions:
    @IBAction func btn_DownloadAll(_ sender: Any) {
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

 extension ReportListViewController: ReportDelegate {
    
    func downloadReport(index: Int) {
        var obReport = ReportModel()
        if flagIsSearch! {
            obReport = (arrSearch?[index])!
        } else {
            obReport = (arrReportList?[index])!
        }
        
        if obReport.auditType == 0 { /// Normal user
            if obReport.reportLink != nil  {
                configureReportForDownloading(strFileLink: obReport.reportLink?.absoluteString)
            }
        } else {
            openActionSheet(obReport: obReport)
        }
    }
    
    func configureReportForDownloading(strFileLink: String?) {
        var strFilePath = strFileLink
        let arrFP = strFilePath!.components(separatedBy: "/")
        let strFileName = arrFP.last
        let arrExt = strFileName?.components(separatedBy: ".")
        strFilePath = strFilePath!.replacingOccurrences(of: " ", with: "%20")
        let arrP = [strFilePath as Any, (arrExt?.first)!, (arrExt?.last)!] as [Any]
        
        /// Here checking condition
        let obFile = FileDownloaderManager()
        let arrR = obFile.checkReportFileExistOrNot(arrParam: arrP as! [String])
        if arrR.0 == true {
            /// File exist
            let dc = UIDocumentInteractionController(url: URL(fileURLWithPath: arrR.1.absoluteString))
            dc.delegate = self
            dc.presentPreview(animated: true)
        } else {
            DispatchQueue.main.async {
                SVProgressHUD.show(withStatus: "Downloading....")
            }
            self.performSelector(inBackground: #selector(downloadFile(arrP:)), with: arrP)
        }
    }
    
    @objc func downloadFile(arrP: [String]) {
        let obFile = FileDownloaderManager()
        obFile.downloadAuditReportInBackground(arrParam: arrP , callBack: { (reportFile) in
            /// In future Opening the document
            if let url = URL(string: arrP[0]) {
                UIApplication.shared.open(url, options: [:])
            }
        })
    }
    
    func openActionSheet(obReport: ReportModel?) {
        let optionMenu = UIAlertController(title: NSLocalizedString("ChoosePreview", comment: ""), message: NSLocalizedString("SelectPreviewType", comment: ""), preferredStyle: .actionSheet)
        let auditorAction = UIAlertAction(title: NSLocalizedString("AuditorReport", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            autoreleasepool {
                self.configureReportForDownloading(strFileLink: obReport?.auditorReportLink?.absoluteString)
                
            }
        })
        
        let inspectorAction = UIAlertAction(title: NSLocalizedString("InspectorReport", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            autoreleasepool {
                self.configureReportForDownloading(strFileLink: obReport?.inspectorReportLink?.absoluteString)
            }
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(auditorAction)
        optionMenu.addAction(inspectorAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.sourceView = self.view
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func openUrl(strUrl: String?) {
        if (strUrl?.count)! > 0 {
            if let url = URL(string: strUrl!) {
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            self.showAlertViewWithDuration("No file to preview", vc: self)
        }
    }
 }

extension ReportListViewController: UIDocumentInteractionControllerDelegate {
    //MARK: UIDocumentInteractionController delegates
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self//or use return self.navigationController for fetching app navigation bar colour
    }
 }
