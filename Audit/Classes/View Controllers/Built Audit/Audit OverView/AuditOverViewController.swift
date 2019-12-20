//
//  AuditOverViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SafariServices

class AuditOverViewController: UIViewController {
    //MARK: Variables & Outlets:
    var delegate:AuditOverViewDelegate?
    var arrP = [String]()
    var strMapUrl:String? = String()
    var str_notify_id = ""
    var str_pdf = ""
    var str_number = ""
    var dictData: NSDictionary? = NSDictionary()
    var arrFiles: NSMutableArray? = NSMutableArray()
    var interaction: UIDocumentInteractionController?
    
    
    @IBOutlet var view_Files: UIView!
    @IBOutlet weak var colView_Files: UICollectionView!
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
    @IBOutlet weak var btn_call: UIButton!
    @IBOutlet weak var btn_map: UIButton!
    
    //MARK: ViewLIfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
        delegate?.getAuditOverViewDetails()
        view_Files.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_Files)
        view_Files.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
    }
    
    //MARK: Button Actions:
    @IBAction func btn_Accept(_ sender: Any) {
        delegate?.AcceptRejectAudit(status: "1")
    }
    
    @IBAction func btn_CloseFileView(_ sender: Any) {
        view_Files.alpha = 0.0
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
        MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: "", message: ValidationMessages.rejectAudit)
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Map(_ sender: Any) {
        
   //     MF.openUrlInBrowser(urlString: strMapUrl)
        if (strMapUrl?.isValidForUrl())! {
            if let url = URL(string: strMapUrl!) {
                //!url.absoluteString.contains("#")
                
                if url.absoluteString.contains("http") && url.absoluteString.contains("www") {
                    let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                    vc.delegate = self as! SFSafariViewControllerDelegate
                    present(vc, animated: true)
                } else {
                    if URL(string: strMapUrl!) != nil {
                        UIApplication.shared.open(URL(string: strMapUrl!)!)
                    } else {
                        MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Simple, title: NSLocalizedString("Alert", comment: ""), message: NSLocalizedString("UrlNotSupportive", comment: ""))
                    }
                }
            } else {
                if URL(string: strMapUrl!) != nil {
                    UIApplication.shared.open(URL(string: strMapUrl!)!)
                } else {
                    MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Simple, title: NSLocalizedString("Alert", comment: ""), message: NSLocalizedString("UrlNotSupportive", comment: ""))
                }
            }
        } else {
            MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Simple, title: NSLocalizedString("Alert", comment: ""), message: NSLocalizedString("UrlNotSupportive", comment: ""))
        }
        
    }
    
    //MARK: Supporting Functions:
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Area.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_DueDate.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Time.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Date.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_PropertyDescription.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_PropertyName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Accept.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Reject.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_Agent.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AgentNumber.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AgentEmail.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AgentName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AgentDetail.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_File.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_ClientPInCode.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_ClientLandmark.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_ClientNUmber.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_ClientAddress.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_ClientDetail.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_ClientName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_attcahment.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_call.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_Area.textAlignment = NSTextAlignment.right
            lbl_DueDate.textAlignment = NSTextAlignment.right
            lbl_Time.textAlignment = NSTextAlignment.right
            lbl_Date.textAlignment = NSTextAlignment.right
            lbl_PropertyDescription.textAlignment = NSTextAlignment.right
            lbl_PropertyName.textAlignment = NSTextAlignment.right
            lbl_AgentNumber.textAlignment = NSTextAlignment.right
            lbl_AgentEmail.textAlignment = NSTextAlignment.right
            lbl_AgentName.textAlignment = NSTextAlignment.right
            lbl_AgentDetail.textAlignment = NSTextAlignment.right
            lbl_ClientPInCode.textAlignment = NSTextAlignment.right
            lbl_ClientLandmark.textAlignment = NSTextAlignment.right
            lbl_ClientNUmber.textAlignment = NSTextAlignment.right
            lbl_ClientAddress.textAlignment = NSTextAlignment.right
            lbl_ClientDetail.textAlignment = NSTextAlignment.right
            lbl_ClientName.textAlignment = NSTextAlignment.right
        }
    }
    
    func setAuditOverViewDetail(dict:NSDictionary) {
        
        lbl_PropertyName.text = dict["title"] as? String
        lbl_PropertyDescription.text = dict["description"] as? String
        if ((dict["start_date"] as? String)?.count)! > 0 && dict["start_date"] as? String != "0000-00-00" {
            let start_date = dc.change(date: (dict["start_date"] as? String)!, format: "yyyy-MM-dd", to: "dd-MMM-yyyy")
            lbl_Date.text = String(format: "%@:  %@", NSLocalizedString("Date", comment: ""),start_date)
        }
        
        if dict["auditType"] as? Int == 0 {
            lbl_Date.text = String(format: "Type:   %@", UserProfile.userRole!)
        } else {
            lbl_Date.text = String(format: "Type:   Super User Audit")
        }
 
        if ((dict["assign_date"] as? String)?.count)! > 0 && dict["assign_date"] as? String != "0000-00-00" {
            let end_date = dc.change(date: (dict["assign_date"] as? String)!, format: "yyyy-MM-dd", to: "dd-MMM-yyyy")
            lbl_DueDate.text = String(format: "%@:  %@", NSLocalizedString("AssignDate", comment: ""),end_date)
        }
        
        lbl_Area.text = String(format: "%@:  %@", NSLocalizedString("Area", comment: ""),(dict["city"] as? String)!)
    }
    
    func setAgentDetail(dict:NSDictionary) {
        
        imgView_Agent.sd_setImage(with: URL(string: (dict["photo"] as? String)!), placeholderImage: UIImage.init(named: "img_user"))
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
        if ((dict["mapurl"] as? String)?.count)! > 0 {
            strMapUrl = dict["mapurl"] as? String
            btn_map.alpha = 1.0
        } else {
            btn_map.alpha = 0.0
        }
        
       delegate?.manageAttachmentFiles(arrAttachment: dict["document"] as! NSArray)
    }
    
    @IBAction func showpdf(_ sender: UITapGestureRecognizer) {
        
        if arrFiles!.count > 1 {
            colView_Files.reloadData()
            view_Files.alpha = 1.0
        } else if arrFiles!.count == 1 {
            downloadFilesFromList(intIndex: 0)
        } else {
            showAlertViewWithDuration("No Attachement avaliable", vc: self)
        }
    }
}

extension AuditOverViewController: UIDocumentInteractionControllerDelegate {
    //MARK: UIDocumentInteractionController delegates
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self//or use return self.navigationController for fetching app navigation bar colour
    }
    
    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        interaction = nil
    }
}

extension AuditOverViewController: PopUpDelegate {
    func actionOnYes() {
        delegate?.AcceptRejectAudit(status: "2")
    }
    
    func actionOnNo() { }
}

extension AuditOverViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}
