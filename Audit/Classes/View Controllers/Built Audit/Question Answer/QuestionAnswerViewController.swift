//
//  QuestionAnswerViewController.swift
//  Audit
//
//  Created by Mac on 12/17/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

class QuestionAnswerViewController: UIViewController {
    //MARk: Variables & Outlets
    
    @IBOutlet weak var view_InnerInspectorView: DesignableView!
    var intQuestionIndex: Int? = Int()
    var intIndexInspector: Int? = 0
    var intPopUpStatus = Int()
    var actionDelegate:QuestionAnswerActionDelegate?
    var flagIsAddEditPhoto = false
    var lastContentOffset: CGFloat = 0
    var arrAnswersForDelete:[AuditAnswerModel]? = [AuditAnswerModel]()
    var arrNormalSubAnswer:[AuditAnswerModel]? = [AuditAnswerModel]()
    var arrMeasurementSubAnswer = [AuditAnswerModel]()
    var imagePicker:UIImagePickerController? = UIImagePickerController()
    var intAuditId = 0
    var intLocationId = 0
    var intFolderId = 0
    var intSubFolderId = 0
    var intSubLocationId = 0
    var intSubLocationSubFolderId = 0
    var globalbtn = UIButton()
    var globalindex = Int()
    var strLocationFolderName = String()
    var arrPhotos:[SubLocationSubFolder_PhotoModel]? = [SubLocationSubFolder_PhotoModel]()
    var arrMainPhoto: [SubLocationSubFolder_PhotoModel]? = [SubLocationSubFolder_PhotoModel]()
    var img_resizing: UIImage? = UIImage()
    var isShowDeleteBtn = false
    let intDefaultCount = 8
    var arrSubLocationSubFolder = [SubLocationSubFolderModel]()
    var arrQuestions = [QuestionsModel]()
    var arrAnswer = [AuditAnswerModel]()
    var arrInspectorAnswers = [AnswerTypeModel]()
    var arrNormalQuestions = [AuditAnswerModel]()
    var arrMesurementQuestions = [AuditAnswerModel]()
    var arrInspectorQuestions:[AuditAnswerModel]? = [AuditAnswerModel]() /// If its count > 0 menas it is a super user audit
    var obInspectorAnswer:AuditAnswerModel? = AuditAnswerModel()
    var photobtnclick = ""
    var flagTableScrolledToBottom = false
    var flagIsReloadTableView = false
    
    @IBOutlet weak var tblView_Inspector: UITableView!
    @IBOutlet weak var tblInspectorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btn_Priority: DesignableButton!
    @IBOutlet weak var btn_RemoveInspectorImg: DesignableButton!
    @IBOutlet weak var btn_InspectorImg: UIButton!
    @IBOutlet weak var imgView_Inspector: UIImageView!
    @IBOutlet weak var btn_CancelText: DesignableButton!
    @IBOutlet weak var btn_CancelInspectorData: UIButton!
    @IBOutlet weak var btn_SaveInspectorData: UIButton!
    @IBOutlet weak var lbl_InspectorQuestion: UILabel!
    @IBOutlet weak var btn_SaveText: DesignableButton!
    @IBOutlet var view_TextDescription: UIView!
    @IBOutlet weak var btn_No: DesignableButton!
    @IBOutlet weak var btn_Yes: DesignableButton!
    @IBOutlet weak var lbl_LocationFolder: UILabel!
    @IBOutlet weak var lbl_Msg: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_Save: DesignableButton!
    @IBOutlet weak var btn_AddPhoto: UIButton!
    @IBOutlet weak var imgView_Photo: UIImageView?
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var colView_photo: UICollectionView!
    @IBOutlet weak var colView_Question: UICollectionView!
    @IBOutlet weak var btn_Delete: UIButton!
    @IBOutlet var view_InspectorQuestion: UIView!
    @IBOutlet var tv_InspectorDescription: UITextView?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        actionDelegate = self
        lbl_Msg.text = kAppDelegate.strMainLocationName
        lbl_LocationFolder.text = strLocationFolderName
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
        
        if let flowLayout = colView_Question.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1,height: 1)
        }
        
        arrQuestions = obSqlite.getQuestionList(locationId: intLocationId, subLocationId: intSubLocationId, auditId: intAuditId)
        //print("arrQuestions = \(arrQuestions.count)")
        arrPhotos = obSqlite.getPhotosSubLocationSubFolder(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, main_photo: 0,fetchType: "audit")
        
        arrMainPhoto = obSqlite.getPhotosSubLocationSubFolder(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, main_photo: 1, fetchType: "audit")
        
        if arrMainPhoto?.count != 0 {
            let obFM:FileDownloaderManager? = FileDownloaderManager()
            let image_download = UIImage(contentsOfFile: (obFM?.getAuditImagePath(imageName:(self.arrMainPhoto?[0].imgName!)!))!)
            self.imgView_Photo?.image = image_download
            
            let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showAvatar(_:)))
            tapGestureRecognizer11.numberOfTapsRequired = 1
            imgView_Photo?.addGestureRecognizer(tapGestureRecognizer11)
        }
        
        arrAnswer = obSqlite.getAuditAnswers(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, parentQueId: 0, selectedAnsId: 0, fetchType: "mainQue")
        
        arrInspectorQuestions = obSqlite.getAuditAnswers(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, parentQueId: 0, selectedAnsId: 0, fetchType: "superAudit")
        
        //print("arrAnswer = \(arrAnswer.count)\n arrInspectorQuestions = \(arrInspectorQuestions?.count)")
        
        if arrAnswer.count == 0 {
            for item in arrQuestions {
                autoreleasepool {
                let obRequest = AuditAnswerModel()
                obRequest.initWith(obQue: item, folderId: intFolderId, sublocation_subfolder_id: intSubLocationSubFolderId, subfolder_id: intSubFolderId, sublocation_id: intSubLocationId)
                obSqlite.insertAnswersData(obAns: obRequest)
                    //mngfkjsdnv ksd nkjnvkljndsjkng
                }
            }
            
            arrAnswer = obSqlite.getAuditAnswers(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, parentQueId: 0, selectedAnsId: 0, fetchType: "mainQue")
            arrInspectorQuestions = obSqlite.getAuditAnswers(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, parentQueId: 0, selectedAnsId: 0, fetchType: "superAudit")
        }
        
        //// condition for updated question
        var flagIsExist = false
        
        //print("arrQuestions = \(arrQuestions.count), arrAnswer.count = \(arrAnswer.count)")
        
        if arrAnswer.count != arrQuestions.count {
            for j in 0..<arrQuestions.count {
                let obQM = arrQuestions[j]
                
                for i in 0..<arrAnswer.count {
                   let obAM = arrAnswer[i]
                    
                    if obAM.questionId == obQM.questionId {
                        flagIsExist = true
                        break
                    } else {
                        flagIsExist = false
                    } 
                }
                
                if !flagIsExist {
                    let obRequest = AuditAnswerModel()
                    obRequest.initWith(obQue: obQM, folderId: intFolderId, sublocation_subfolder_id: intSubLocationSubFolderId, subfolder_id: intSubFolderId, sublocation_id: intSubLocationId)
                    obSqlite.insertAnswersData(obAns: obRequest)
                }
            }
            
            arrAnswer = obSqlite.getAuditAnswers(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, parentQueId: 0, selectedAnsId: 0, fetchType: "mainQue")
            arrInspectorQuestions = obSqlite.getAuditAnswers(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, parentQueId: 0, selectedAnsId: 0, fetchType: "superAudit")
            
        }
        
        //self.checkQuestionExistOrNot()
        
        if arrAnswer.count != 0 {
            arrNormalQuestions = arrAnswer.filter({ $0.categoryType == 1 })
            arrMesurementQuestions = arrAnswer.filter({ $0.categoryType == 2 })
        }
        
        tblView.estimatedRowHeight = 100.0
        tblView.rowHeight = UITableViewAutomaticDimension
        tblView.reloadData()
        
        view_InspectorQuestion.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_InspectorQuestion)
        view_InspectorQuestion.alpha = 0.0
        
        view_TextDescription.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_TextDescription)
        view_TextDescription.alpha = 0.0
    }
    //MARK: Supporting Functions:
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Msg.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_LocationFolder.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.text = NSLocalizedString("BuiltAudit", comment: "")
     //   lbl_Msg.text = NSLocalizedString("LocationMessage", comment: "")
        btn_AddPhoto.setTitle(NSLocalizedString("AddPhoto", comment: ""), for: UIControlState.normal)
        btn_Delete.setTitle(NSLocalizedString("DeletePhoto", comment: ""), for: UIControlState.normal)
        btn_Save.setTitle(NSLocalizedString("Submit", comment: ""), for: UIControlState.normal)
        lbl_InspectorQuestion.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
//        btn_Yes.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
//        btn_No.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
//        btn_Yes.setTitle(NSLocalizedString("Yes", comment: ""), for: UIControlState.normal)
//        btn_No.setTitle(NSLocalizedString("No", comment: ""), for: UIControlState.normal)
        btn_SaveText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_SaveText.setTitle(NSLocalizedString("Save", comment: ""), for: UIControlState.normal)
        btn_CancelText.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_CancelText.setTitle(NSLocalizedString("Cancel", comment: ""), for: UIControlState.normal)
        tv_InspectorDescription?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_Inspector.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Priority.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tv_InspectorDescription?.textAlignment = .right
            lbl_InspectorQuestion?.textAlignment = .right
        }
    }
    
    func releaseUnusedMemory() {
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        arrPhotos = [SubLocationSubFolder_PhotoModel]()
        arrMainPhoto = [SubLocationSubFolder_PhotoModel]()
        arrNormalQuestions.removeAll()
        arrMesurementQuestions.removeAll()
        arrNormalQuestions = [AuditAnswerModel]()
        arrMesurementQuestions = [AuditAnswerModel]()
        imagePicker?.delegate = nil
        imagePicker = UIImagePickerController()
        tblView.delegate = nil
        colView_Question.delegate = nil
        colView_Question.dataSource = nil
        view.removeAllSubViews()
    }
    
    func setWorkStatusForSubFolderBlocks() {
        
        arrSubLocationSubFolder = obSqlite.getSubLocationSubFolderList(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, sub_locationId: intSubLocationId, subFolderId: intSubFolderId)
        
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
    
    func checkQuestionExistOrNot() {
        
        ///if the give que id is not exist in anser list then that queid will be deleted from Answerlist
        var obAAns: AuditAnswerModel = AuditAnswerModel()
        var flagIsExist = Bool()
        for obAns in arrAnswer {
            for obQues in arrQuestions {
                if obQues.parentQuestionId == 0 {
                    if obQues.questionId == obAns.questionId {
                        flagIsExist = true
                    } else {
                        //    //print("obQues.questionId= \(obQues.questionId), obAns.questionId = \(obAns.questionId)")
                        flagIsExist = false
                        obAAns = obAns
                        break
                    }
                }
            }
            
            if !flagIsExist {
                //print("Answer \(obAAns.questionId) deleted")
                arrAnswersForDelete?.append(obAAns)
              //  obSqlite.deleteQuestionAnswer(auditId: intAuditId, locationId: intLocationId , folderId: intFolderId , subFolderId: intSubFolderId, subLocationId: intSubLocationId, subLocationSubFolderId: intSubLocationSubFolderId,  deleteType: "selectedId", questionId:  obAAns.questionId!)
            }
        }
        
        print("arrAnswersForDelete =\(arrAnswersForDelete?.count)")
       /* for obQues in arrQuestions {
            //print("obQues.questionId= \(obQues.questionId), obQues.parentQuestionId = \(obQues.parentQuestionId)")
            if obQues.parentQuestionId == 0 {
                for obAns in arrAnswer {
                    //   //print("obAns.questionId = \(obAns.questionId)")
                    if obQues.questionId == obAns.questionId {
                        flagIsExist = true
                    } else {
                        //    //print("obQues.questionId= \(obQues.questionId), obAns.questionId = \(obAns.questionId)")
                        flagIsExist = false
                        obAAns = obAns
                       // break
                    }
                }
                
            }
        } */
        
        
        //call again answerList
        arrAnswer = obSqlite.getAuditAnswers(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, parentQueId: 0, selectedAnsId: 0, fetchType: "mainQue")
        arrInspectorQuestions = obSqlite.getAuditAnswers(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, parentQueId: 0, selectedAnsId: 0, fetchType: "superAudit")
    }
    
    func updateQuestionTypeIfAny() {
        
    }
    
    
    //MARK: Button Actions:
    
    @IBAction func btn_RemoveInspectorImg(_ sender: Any) {
        actionDelegate?.removeInspectorImage()
    }
    
    @IBAction func btn_CancelInspectorData(_ sender: Any) {
        view_InspectorQuestion.alpha = 0.0
    }
    @IBAction func btn_SaveInspectorData(_ sender: Any) {
        view_InspectorQuestion.alpha = 0.0
        updateInspectorArray()
    }
    
    @IBAction func btn_Priority(_ sender: Any) {
        openPriorityPickerView()
    }
    
    @IBAction func btn_Yes(_ sender: Any) {
       actionDelegate?.inspectorActionYes()
    }
    
    @IBAction func btn_No(_ sender: Any) {
       actionDelegate?.inspectorActionNo()
    }
    
    @IBAction func btn_SaveText(_ sender: Any) {
        arrNormalQuestions[intIndexInspector!].answerDescription = tv_InspectorDescription?.text
        arrNormalQuestions[intIndexInspector!].isUpdate = 1
        view_TextDescription.alpha = 0.0
        tv_InspectorDescription?.resignFirstResponder()
    }
    
    @IBAction func btn_CancelText(_ sender: Any) {
        tv_InspectorDescription?.resignFirstResponder()
        view_TextDescription.alpha = 0.0
    }
    
    @IBAction func btn_InspctorImg(_ sender: Any) {
        actionDelegate?.captureInpsectorImage()
    }
    
    @IBAction func btn_Save(_ sender: Any) {
        actionDelegate?.saveAuditAnswerData()
    }
    
    @IBAction func btn_Delete(_ sender: UIButton) {
        actionDelegate?.deleteMainPhoto()
    }
    
    @IBAction func showAvatar(_ sender: UITapGestureRecognizer) {
        let imgview = sender.view as! UIImageView
        if imgview.image != nil {
            SJAvatarBrowser.showImage(sender.view as? UIImageView)
        }
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        releaseUnusedMemory()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_AddPhoto(_ sender: Any) {
        actionDelegate?.addMainPhoto()
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
}
