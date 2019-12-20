//
//  BuiltSubAuditViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 30/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

class BuiltSubAuditViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var flagIsSearch = false
    
    //MARK: Variables & Outlets:
    var imagePicker: UIImagePickerController?  = UIImagePickerController()
    var isShowDeleteBtn = false
    var intAuditId = Int()
    var intLocationId = Int()
    var intFolderId = Int()
    var intSubFolderId = Int()
    var arrTempSubLocationList = [SubLocationModel]()
    var arrSubLocationByQuestionList = [SubLocationModel]()
    var arrSubLocationList = [SubLocationModel]()
    var arrSearch: [SubLocationModel]? = [SubLocationModel]()
    var arrSelectedSubLocationList = [BuiltAuditSubLocationModel]()
    var flagIsAddedSelectedSubLocation: Bool? = Bool()
    var counter: Int? = Int()
    var intSelectedIndexPath = Int()
    var intFolderListCounter = Int()
    var base64photo = String()
    var strTitle = String()
    var img_resizing: UIImage?// = UIImage()
    var intWhichAlertIndex = Int()
    var intSelectedIndexOnAlert = Int()
    var flagIsAddEditPhoto = false
    
    @IBOutlet weak var lbl_SubHeaderTitle: UILabel!
    @IBOutlet weak var lbl_HeaderTitle: UILabel!
    @IBOutlet weak var tv_Description: UITextView!
    @IBOutlet weak var lbl_Info: UILabel!
    @IBOutlet weak var btn_Content: UIButton!
    @IBOutlet weak var imgView_Photo: UIImageView?
    @IBOutlet weak var lbl_FolderTitle: UILabel!
    @IBOutlet weak var btn_EditPhoto: UIButton!
    @IBOutlet weak var btn_AddPhoto: UIButton!
    @IBOutlet weak var btn_Delete: DesignableButton!
    @IBOutlet weak var btn_Next: DesignableButton!
    @IBOutlet weak var colView_SubLocation: UICollectionView!
    @IBOutlet weak var colView_SelectedSubLocation: UICollectionView!
    @IBOutlet var view_Alert: UIView!
    @IBOutlet weak var lbl_AlertTitle: UILabel!
    @IBOutlet weak var lbl_AlertMsg: UILabel!
    @IBOutlet weak var btn_AlertYes: UIButton!
    @IBOutlet weak var btn_AlertNo: UIButton!
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        colView_SubLocation.dropDelegate = self
        colView_SubLocation.dragDelegate = self
        colView_SubLocation.dragInteractionEnabled = true
        colView_SelectedSubLocation.delegate = self
        colView_SelectedSubLocation.dataSource = self
        colView_SelectedSubLocation.dropDelegate = self
        
        // Do any additional setup after loading the view.
        
        if base64photo != "" {
            DispatchQueue.global(qos: .background).async {
                let obFM:FileDownloaderManager? = FileDownloaderManager()
                let image_download = UIImage(contentsOfFile: (obFM?.getAuditImagePath(imageName: self.base64photo))!)
                DispatchQueue.main.async {
                    self.imgView_Photo?.image = image_download
                }
            }
        }
        view_Alert.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_Alert)
        view_Alert.alpha = 0.0
    }

    override func viewWillAppear(_ animated: Bool) {
        lbl_FolderTitle.text = strTitle
        kAppDelegate.strSubLocationName = strTitle
        if !flagIsAddEditPhoto  {
            
            getSubLocationList()
            getSelectedSubLocationList()
        }
        
    }
    
    //MARK: Supporting Functions:
    func removeUnusedMemory() {
        self.arrSubLocationList.removeAll()
        self.arrSubLocationList = [SubLocationModel]()
        self.arrTempSubLocationList.removeAll()
        self.arrTempSubLocationList = [SubLocationModel]()
        self.colView_SelectedSubLocation.delegate = nil
        self.colView_SelectedSubLocation.dataSource = nil
        self.colView_SubLocation.delegate = nil
        self.colView_SubLocation.dataSource = nil
      //  imagePicker!.delegate = nil
     //   imagePicker = UIImagePickerController()
        self.view.removeAllSubViews()
    }
    
    func getSubLocationList() {
        self.arrTempSubLocationList = [SubLocationModel]()
        self.arrSubLocationList.removeAll()
        self.arrSubLocationList = [SubLocationModel]()
        self.arrSubLocationByQuestionList = obSqlite.getDefaultSubLocationList(auditId: intAuditId, locationId: intLocationId)
        
        for i in 0..<self.arrSubLocationByQuestionList.count {
            if obSqlite.getQuestionsCountForSubLocation(locationId: intLocationId, subLocationId: self.arrSubLocationByQuestionList[i].subLocationId!, auditId: intAuditId) > 0 {
                self.arrTempSubLocationList.append(self.arrSubLocationByQuestionList[i])
            }
        }
        self.colView_SubLocation.reloadData()
    }
    
    func getSelectedSubLocationList() {
        self.arrSelectedSubLocationList = obSqlite.getBuiltAuditSubLocationList(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subFolderId: intSubFolderId)
        
        if arrSelectedSubLocationList.count == 0 {
            btn_Delete.isSelected = false
            isShowDeleteBtn = false
            btn_Delete.setTitle("Delete", for: .normal)
            btn_Delete.alpha = 0.5
            btn_Delete.isUserInteractionEnabled = false
        } else {
            btn_Delete.alpha = 1.0
            btn_Delete.isUserInteractionEnabled = true
        }
        
        self.colView_SelectedSubLocation.reloadData()
        var flagIsExist = false
        /// Here calling, and filtering the two sublocation list with some checks
    //print("arrSubLocationList.count = \(arrSubLocationList.count)")
        for i in 0..<arrTempSubLocationList.count {
            let obTSL = arrTempSubLocationList[i]
           for j in 0..<arrSelectedSubLocationList.count {
                let obSSL = arrSelectedSubLocationList[j]
                if obTSL.subLocationId == obSSL.subLocationId {
                    flagIsExist = true
                    break
                } else {
                    flagIsExist = false
                }
            }
            if !flagIsExist {
                arrSubLocationList.append(arrTempSubLocationList[i])
            }
        }
        self.colView_SubLocation.reloadData()
        self.colView_SelectedSubLocation.reloadData()
    }
    
    func setUpLanguageSetting() {
         self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Next.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Content.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Delete.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_AddPhoto.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_EditPhoto.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_Photo?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_FolderTitle.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        btn_AddPhoto.setTitle(NSLocalizedString("AddPhoto", comment: ""), for: UIControlState.normal)
        btn_EditPhoto.setTitle(NSLocalizedString("EditPhoto", comment: ""), for: UIControlState.normal)
        btn_Delete.setTitle(NSLocalizedString("Delete", comment: ""), for: UIControlState.normal)
        btn_Next.setTitle(NSLocalizedString("Next", comment: ""), for: UIControlState.normal)
        btn_Content.setTitle(NSLocalizedString("Content", comment: ""), for: UIControlState.normal)
        lbl_Info.text = NSLocalizedString("InformationBox", comment: "")
        lbl_HeaderTitle.text = NSLocalizedString("BuiltAudit", comment: "")
        lbl_SubHeaderTitle.text = NSLocalizedString("BuiltUnit", comment: "")
        lbl_AlertTitle.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_AlertMsg.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_AlertNo.setTitle(NSLocalizedString("No", comment: ""), for: UIControlState.normal)
        btn_AlertYes.setTitle(NSLocalizedString("Yes", comment: ""), for: UIControlState.normal)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_Info.textAlignment = NSTextAlignment.right
            tv_Description.textAlignment = NSTextAlignment.right
            btn_AddPhoto.contentHorizontalAlignment = .left
            btn_EditPhoto.contentHorizontalAlignment = .left
        }
    }
    
    func deleteOnDecreaseCounter() {
        
        obSqlite.deleteSubLocationSubFolder(incId: 0, auditId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].locationId!, folderId: 0, subFolderId: 0, sub_locationId: 0, deleteType: "location")
                
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            if self.counter! > 1 {
                self.counter! -= 1
                let success = obSqlite.updateBuiltAuditSubLocation(incId: self.arrSelectedSubLocationList[self.intSelectedIndexOnAlert].incId!, auditId: 0, locationId: 0, folderId: 0, subFolderId: 0, subLocationId: 0, subLocationCount: self.counter!, workStatus: 0, updateType: "count")
                if success {
                    self.arrSelectedSubLocationList[self.intSelectedIndexOnAlert].subLocationCount = self.counter
                    self.colView_SelectedSubLocation.reloadData()
                }
            }
        })
    }
    
    //MARK: Button Actions:
    @IBAction func btn_AlertYes(_ sender: Any) {
        if intWhichAlertIndex == 1 {
            self.deleteSelectedSubLocation()
        } else if intWhichAlertIndex == 2 {
            self.deleteOnDecreaseCounter()
        }
        view_Alert.alpha = 0.0
    }
    
    @IBAction func btn_AlertNo(_ sender: Any) {
        view_Alert.alpha = 0.0
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        removeUnusedMemory()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_EditPhoto(_ sender: Any) {
        flagIsAddEditPhoto = true
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.photoEditorDelegate = self
        photoEditor.image = imgView_Photo?.image
        img_resizing = imgView_Photo?.image!
        photoEditor.hiddenControls = [.share, .save, .sticker]
        present(photoEditor, animated: false, completion: nil)
    }
    
    @IBAction func btn_AddPhoto(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        //MF.openActionSheet(with: imagePicker, and: self, targetFrame: btn_AddPhoto.frame)
        MF.openActionSheetDemo(with: imagePicker!, and: self, targetFrame: btn_AddPhoto.frame, sender: sender as AnyObject)
        flagIsAddEditPhoto = true
    }
    
    @IBAction func btn_NavigateToBuiltAudit(_ sender: Any) {
        removeUnusedMemory()
        MF.navigateToBuiltAudit(vc: self)
    }
    @IBAction func btn_Next(_ sender: Any) {
        /// These info will go on the next screen for processing and managing the list
        if arrSelectedSubLocationList.count == 0 {
           // self.showAlertViewWithMessage(NSLocalizedString("SelectSubLocation", comment: ""), vc: self)
        } else {
            let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "SubLocationFolderViewController") as! SubLocationFolderViewController
            vc.intAuditId = intAuditId
            vc.intLocationId = intLocationId
            vc.intFolderId = intFolderId
            vc.intSubFolderId = intSubFolderId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btn_Delete(_ sender: UIButton) {
        if (sender as AnyObject).isSelected {
            isShowDeleteBtn = false
            btn_Delete.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
            sender.isSelected = false
        } else {
            isShowDeleteBtn = true
            btn_Delete.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
            sender.isSelected = true
        }
        colView_SelectedSubLocation.reloadData()
    }
}


extension BuiltSubAuditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        picker.dismiss(animated: false, completion: nil)
     
        let photoEditor: PhotoEditorViewController? = PhotoEditorViewController(nibName:"PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor?.photoEditorDelegate = self
        photoEditor?.image = image
        self.imgView_Photo?.image = image
            self.img_resizing = image
        photoEditor?.hiddenControls = [.share, .save, .sticker]
        self.present(photoEditor!, animated: false, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension BuiltSubAuditViewController: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
        
        autoreleasepool() {
            self.imagePicker = nil
            self.imagePicker?.delegate = nil
            img_resizing = image
            //  self.executeUIProcess {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("Saving..", comment: ""))
        self.imgView_Photo?.image = image
            SVProgressHUD.dismiss()
            // }
            self.performSelector(inBackground: #selector(self.saveAuditImageInBackground), with: nil)
        }
        
        
    }
    
    func canceledEditing() {
        
        self.executeUIProcess {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("Saving..", comment: ""))
        }
        
       self.performSelector(inBackground: #selector(self.saveAuditImageInBackground), with: nil)
    }
    
  @objc func saveAuditImageInBackground() {
    autoreleasepool {
        var obFileManager: FileDownloaderManager? = FileDownloaderManager()
        obFileManager!.saveAuditImage(imgData:((img_resizing?.imageQuality(.low))!), callback: { (fileName) in
       // obSqlite = SqliteDB.sharedInstance()
            obSqlite.updateLocationSubFolder(incId: self.intSubFolderId, isArchive: 0, base64Str: fileName, subfolderTitle: "", subfolderDescription: "", updateType: "photo")
            self.executeUIProcess {
                SVProgressHUD.dismiss()
                self.img_resizing = nil
            }
        })
    obFileManager = nil
    }
    }
    
}
