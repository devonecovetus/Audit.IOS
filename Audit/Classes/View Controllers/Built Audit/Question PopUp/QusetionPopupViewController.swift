//
//  QusetionPopupViewController.swift
//  Audit
//
//  Created by Mac on 12/28/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

class QusetionPopupViewController: UIViewController {
    //MARK: Variables and Outlets:
    var intPopUpStatus = Int()
    var intQuestionIndex: Int? = Int()
    var actionDelegate: QuestionPopUpActionDelegate?
    var superAuditDelegate:QuestionPopUpSuperUserAuditDelegate?
    var selectedIndex = Int()
    var normalSubQuestionDataCallBack:(( _ selectedIndex: Int, _ obQuestion: AuditAnswerModel, _ arrSubAnswer: [AuditAnswerModel])->())?
    var measurementSubQuestionDataCallBack: ((_ selectedIndex: Int, _ obQuestion: AuditAnswerModel, _ arrSubAnswer: [AuditAnswerModel])->())?
    var superUserAuditDataCallBack:((_ selectedIndex: Int, _ obInspector: AuditAnswerModel?) -> ())?
    var intSuperAuditIndex = Int()
    var intImagePickingType = Int()
    var imagePicker = UIImagePickerController()
    var arrAnswers = [AnswerTypeModel]()
    var obAnswer = AuditAnswerModel()
    var obNormalAnswer = AuditAnswerModel()
    var arrSubAnswers = [AuditAnswerModel]()
    var arrInspectorAnswers = [AnswerTypeModel]()
    var intMainIndex = Int()
    var globalbtn = UIButton()
    var globalindex = Int()
    var headertype = ""
    var intQuestionCategoryType = Int()
    var strSelectedAnswer = String()
    var imgCaptured = UIImage()
    var arrInspectorQuestions:[AuditAnswerModel]? = [AuditAnswerModel]() /// If its count > 0 menas it is a super user audit
    var obInspectorAnswer:AuditAnswerModel? = AuditAnswerModel()
    
    @IBOutlet weak var tblView_Inspector: UITableView!
    @IBOutlet weak var tblInspectorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btn_CancelDescriptionText: DesignableButton!
    @IBOutlet weak var btn_SaveDescriptionText: DesignableButton!
    @IBOutlet weak var btn_Priority: DesignableButton!
    @IBOutlet weak var btn_RemoveInspectorImg: DesignableButton!
    @IBOutlet weak var btn_InspectorImg: UIButton!
    @IBOutlet weak var imgView_Inspector: UIImageView!
    @IBOutlet weak var btn_CancelText: DesignableButton!
    
    @IBOutlet weak var lbl_InspectorQuestion: UILabel!
    @IBOutlet weak var btn_SaveText: DesignableButton!
    @IBOutlet var view_TextDescription: UIView!
    @IBOutlet weak var btn_No: DesignableButton!
    @IBOutlet weak var btn_Yes: DesignableButton!
    @IBOutlet var view_InspectorQuestion: UIView!
    @IBOutlet weak var btn_CancelInspectorData: UIButton!
    @IBOutlet weak var btn_SaveInspectorData: UIButton!
    
    @IBOutlet weak var btn_Inspector: UIButton!
    
    @IBOutlet weak var btn_ViewText: UIButton!
    @IBOutlet weak var btn_Save: UIButton!
    @IBOutlet weak var btn_Cancel: DesignableButton!
    @IBOutlet weak var lbl_MeasurementQuestion: UILabel!
    @IBOutlet weak var tblView_DropDown: UITableView!
    @IBOutlet weak var btn_DropDown: UIButton!
    @IBOutlet var view_DropDown: UIView!
    @IBOutlet weak var tf_Text: UITextField!
    @IBOutlet var view_Text: UIView!
    @IBOutlet var view_TrueFalse: UIView!
    @IBOutlet weak var btn_InspectorNo: DesignableButton!
    @IBOutlet weak var btn_InspectorYes: DesignableButton!
    @IBOutlet weak var btn_InspectorPriority: DesignableButton!
    @IBOutlet weak var imgView_Photo: UIImageView!
    @IBOutlet weak var tv_Description: DesignableTextView!
    @IBOutlet weak var tv_InspectorDescription: DesignableTextView!
    @IBOutlet weak var tv_AuditorDescription: DesignableTextView!
    @IBOutlet weak var btn_DeletePhoto: DesignableButton!
    @IBOutlet weak var lbl_Question: UILabel!
    @IBOutlet weak var lbl_Answer: UILabel!
    @IBOutlet weak var viewquestion: UIView!
    @IBOutlet weak var tblView_SubQuestions: UITableView!
    @IBOutlet weak var tblView_Measurement: UITableView!
    
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        actionDelegate = self
        superAuditDelegate = self
        self.tblView_SubQuestions.tableFooterView = UIView()
        self.tblView_Measurement.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        setUpLanguageSetting()
        //print("obAnswer.questionType = \(obAnswer.questionType ?? Int())")
        
        //if headertype == "measurement" {
        if intQuestionCategoryType == QuestionCategory.Measurement {
            
            lbl_Question.alpha = 0.0
            lbl_Answer.alpha = 0.0
            viewquestion.alpha = 1.0
            ///setQuestion type.
            ///set question priority
            ///set image and other data if not set.
            /// Apart from these get the saved data for subquestions 
            lbl_MeasurementQuestion.text = obAnswer.question
          // //print("obAnswer.savedAnswer_id = \(obAnswer.answers ), obAnswer.savedAnswer = \(obAnswer.savedAnswer)")
             if (obAnswer.savedAnswer_id?.count)! > 0 &&  (obAnswer.savedAnswer?.count)! > 0 && !((obAnswer.savedAnswer_id?.contains(","))!) {
              //  fetchMeasurementSQDataOnCalling(ansId:Int(obAnswer.savedAnswer_id!)!, answer: obAnswer.savedAnswer!, obAnswer: obAnswer)
                getNormalSubQuestionsAfterSave(ansId: Int(obAnswer.savedAnswer_id!)!, answer: obAnswer.savedAnswer!, questionId: obAnswer.questionId!)
            }
            self.addAllSubViews()
            setQuestionType()
            self.setQuestionPriority()
            setImageData()
        } else {
            lbl_Question.alpha = 1.0
            lbl_Answer.alpha = 1.0
            viewquestion.alpha = 0.0
            lbl_Question.text = obNormalAnswer.question
            lbl_Answer.text = strSelectedAnswer
            ////print("obAnswer.savedAnswer_id = \(obAnswer.savedAnswer_id), obAnswer.savedAnswer = \(obAnswer.savedAnswer)")
                arrSubAnswers.append(obAnswer)
            if (obAnswer.savedAnswer_id?.count)! > 0 &&  (obAnswer.savedAnswer?.count)! > 0 && !((obAnswer.savedAnswer_id?.contains(","))!) {
                 // fetchSubQuestionData(ansId: Int(obAnswer.savedAnswer_id!)!, answer: obAnswer.savedAnswer!)
                getNormalSubQuestionsAfterSave(ansId: Int(obAnswer.savedAnswer_id!)!, answer: obAnswer.savedAnswer!, questionId: obAnswer.questionId!)
            }
            tblView_SubQuestions.reloadData()
        }
        
        view_InspectorQuestion.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_InspectorQuestion)
        view_InspectorQuestion.alpha = 0.0
        
        view_TextDescription.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(view_TextDescription)
        view_TextDescription.alpha = 0.0
    }
    
    func removeUnusedMemory() {
        obAnswer = AuditAnswerModel()
        tblView_SubQuestions.delegate = nil
        tblView_DropDown.delegate = nil
        tblView_Measurement.delegate = nil
        tblView_SubQuestions.dataSource = nil
        tblView_DropDown.dataSource = nil
        tblView_Measurement.dataSource = nil
        imagePicker.delegate = nil
        imagePicker = UIImagePickerController()
        self.view.removeAllSubViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Yes.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_No.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_DropDown.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Save.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Cancel.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Priority.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Question.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_MeasurementQuestion.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_Photo.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tv_Description.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        
        tv_Description.text = NSLocalizedString("TextPlaceHolder", comment: "")
        btn_Save.setTitle(NSLocalizedString("Save", comment: ""), for: UIControlState.normal)
        btn_Cancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: UIControlState.normal)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            btn_DropDown.contentHorizontalAlignment = .right
            btn_DropDown.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
            tv_Description.textAlignment = NSTextAlignment.right
            lbl_Question.textAlignment = NSTextAlignment.right
            lbl_MeasurementQuestion.textAlignment = NSTextAlignment.right
            lbl_InspectorQuestion.textAlignment = NSTextAlignment.right
            tv_AuditorDescription.textAlignment = NSTextAlignment.right
        }
    }
   
    //MARK: Supporting Functions:
    
    func setPreviousDataSelected() {
        arrAnswers = [AnswerTypeModel]()
        var arr_Answer1 = [String]()
        var arrAnswerIds = [String]()
        var arrSaveAnswerId = [String]()
        
        let strAns =  NSLocalizedString("SelectOption", comment: "") + "\(AnswerSeperator)\(obAnswer.answers!)"//
        let strAnsId = "0" + ",\(obAnswer.answerId!)"
        
        /// To avoid some unintentionally data redundancy I work in this way.
        arr_Answer1 = (strAns.components(separatedBy: AnswerSeperator))
        arrAnswerIds = (strAnsId.components(separatedBy: ","))
        /// Here to check if answers are saved in saved answer or not. From this condition I am accessing the answers and ids
        
        if (obAnswer.savedAnswer?.count)! > 0 {
            arrSaveAnswerId = (obAnswer.savedAnswer_id?.components(separatedBy: ","))!
        }
        
        /// On the bbbasis of the condition the loop executes the futher flow.
        if arrAnswers.count != arr_Answer1.count {
            for i in 0..<arr_Answer1.count {
                autoreleasepool {
                let obAns = AnswerTypeModel()
                obAns.initWith(answer: arr_Answer1[i], answerId: arrAnswerIds[i] , type: obAnswer.questionType!, status: 0)
                arrAnswers.append(obAns)
            }
            }
        }
        
        //print("arrAnswers = \(arrAnswers), arr_Answer1 = \(arr_Answer1)")
        
        if (obAnswer.savedAnswer?.count)! > 0 {
            if arrAnswers.count == arr_Answer1.count {
                for j in 0..<arrAnswers.count {
                    autoreleasepool {
                    for k in 0..<arrSaveAnswerId.count {
                        autoreleasepool {
                        if arrAnswers[j].answerId == arrSaveAnswerId[k] {
                            arrAnswers[j].status = 1
                        }
                      }
                    }
                    }
                }
            }
        }
    }
    
    func setQuestionPriority() {
        if obAnswer.priority == QuestionPriority.Low {
            btn_Priority.setTitle(QuestionPriorityName.Low, for: UIControlState.normal)
            btn_Priority.backgroundColor = PriorityColor.Low
        } else if obAnswer.priority == QuestionPriority.Medium {
            btn_Priority.setTitle(QuestionPriorityName.Medium, for: UIControlState.normal)
            btn_Priority.backgroundColor = PriorityColor.Medium
        } else if obAnswer.priority == QuestionPriority.High {
            btn_Priority.setTitle(QuestionPriorityName.High, for: UIControlState.normal)
            btn_Priority.backgroundColor = PriorityColor.High
        }
    }
    
    func setTextData() {
        tf_Text.text = obAnswer.savedAnswer
    }
    
    func setDropDownData() {
        var answerCount = Int()
        var arr_Answer1 = [String]()
        var arrAnswerIds = [String]()
        /// To avoid some unintentionally data redundancy I work in this way.
        let strAns =  NSLocalizedString("SelectOption", comment: "") + "\(AnswerSeperator)\(obAnswer.answers!)"//
        let strAnsId = "0" + ",\(obAnswer.answerId!)"
        
        arr_Answer1 = (strAns.components(separatedBy: AnswerSeperator))
        arrAnswerIds = (strAnsId.components(separatedBy: ","))
        answerCount = arr_Answer1.count
        /// Here to check if answers are saved in saved answer or not. From this condition I am accessing the answers and ids
        if (obAnswer.savedAnswer?.count)! > 0 {
            let arr_SavedAnswer = (obAnswer.savedAnswer?.components(separatedBy: AnswerSeperator))!
            btn_DropDown.setTitle(arr_SavedAnswer[0], for: UIControlState.normal)
            // arrAnswerIds = (obQuestion.savedAnswer_id?.components(separatedBy: ","))!
            btn_DropDown.backgroundColor = CustomColors.themeColorGreen
        } else {
            btn_DropDown.setTitle(NSLocalizedString("SelectOption", comment: ""), for: UIControlState.normal)
            btn_DropDown.backgroundColor = UIColor.groupTableViewBackground
        }
        
        /// On the bbbasis of the condition the loop executes the futher flow.
        //print("arr_Answer1- \(arr_Answer1), arrAnswers.count = \(arrAnswers.count), answerCount = \(answerCount)")
        if arrAnswers.count != answerCount {
            for i in 0..<arr_Answer1.count {
                autoreleasepool {
                let obAns = AnswerTypeModel()
                obAns.initWith(answer: arr_Answer1[i], answerId: arrAnswerIds[i] , type: obAnswer.questionType!, status: 0)
                arrAnswers.append(obAns)
                }
            }
        }
        tblView_DropDown.reloadData()
        tblView_DropDown.alpha = 0.0
    }
    
    func setRadioAndCheckBoxData() {
        setPreviousDataSelected()
    }
    
    func setTrueFalseData() {
        btn_No.backgroundColor = UIColor(red: 150/255.0, green: 159/255.0, blue: 169/255.0, alpha: 1.0)
        btn_Yes.backgroundColor = UIColor(red: 150/255.0, green: 159/255.0, blue: 169/255.0, alpha: 1.0)
        setPreviousDataSelected()
        if arrAnswers[0].status == 1 {
            btn_Yes.backgroundColor = UIColor(red: 44/255.0, green: 189/255.0, blue: 165/255.0, alpha: 1.0)
            btn_No.backgroundColor = UIColor(red: 150/255.0, green: 159/255.0, blue: 169/255.0, alpha: 1.0)
        } else if arrAnswers[1].status == 1 {
            btn_Yes.backgroundColor = UIColor(red: 150/255.0, green: 159/255.0, blue: 169/255.0, alpha: 1.0)
            btn_No.backgroundColor = UIColor(red: 249/255.0, green: 95/255.0, blue: 98/255.0, alpha: 1.0)
        }
    }
    
    func setQuestionType() {
        setSuperUserAuditView()
        if obAnswer.questionType == QuestionType.CheckBox || obAnswer.questionType == QuestionType.Radio {
            tblView_Measurement.alpha = 1.0
            setRadioAndCheckBoxData()
        } else if obAnswer.questionType == QuestionType.DropDown {
            view_DropDown.alpha = 1.0
            setDropDownData()
        } else if obAnswer.questionType == QuestionType.Text {
            view_Text.alpha = 1.0
           tf_Text.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            setTextData()
        } else if obAnswer.questionType == QuestionType.TrueFalse {
            view_TrueFalse.alpha = 1.0
            setTrueFalseData()
        }
        
        if (obAnswer.answerDescription?.count)! > 0 {
            tv_Description.text = obAnswer.answerDescription!
            tv_Description.textColor = UIColor.black
        }
    }
    
    func setImageData() {
        if obAnswer.imgName == "" {
            imgView_Photo.alpha = 0.0
            btn_DeletePhoto.alpha = 0.0
        } else {
            imgView_Photo.alpha = 1.0
            btn_DeletePhoto.alpha = 1.0
            let obFM = FileDownloaderManager()
            let image_download = UIImage(contentsOfFile: obFM.getAuditImagePath(imageName: obAnswer.imgName!))
            imgView_Photo.image = image_download
            
            let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showAvatar(_:)))
            tapGestureRecognizer11.numberOfTapsRequired = 1
            imgView_Photo.addGestureRecognizer(tapGestureRecognizer11)
        }
    }
    
    func setSuperUserAuditView() {
        if obAnswer.isSuperUserAudit == 1 { /// Means a super user audit
            tv_Description.alpha = 0.0
            btn_ViewText.alpha = 1.0
            btn_Inspector.alpha = 1.0
            superAuditDelegate?.getAndSetInspectorData()
        } else { /// means a normal user
            tv_Description.alpha = 1.0
            btn_ViewText.alpha = 0.0
            btn_Inspector.alpha = 0.0
        }
    }
    
    @IBAction func showAvatar(_ sender: UITapGestureRecognizer) {
        let imgview = sender.view as! UIImageView
        if imgview.image != nil {
            SJAvatarBrowser.showImage(sender.view as? UIImageView)
        }
    }
    
    func addAllSubViews() {
        
        view_Text.frame = tblView_Measurement.frame
        viewquestion.addSubview(view_Text)
        view_Text.alpha = 0.0
        view_DropDown.frame = CGRect(x: tblView_Measurement.frame.origin.x, y: tblView_Measurement.frame.origin.y, width: tblView_Measurement.frame.size.width, height: tblView_Measurement.frame.size.height + 10)
        viewquestion.addSubview(view_DropDown)
        view_DropDown.alpha = 0.0
        
        view_TrueFalse.frame = tblView_Measurement.frame
        viewquestion.addSubview(view_TrueFalse)
        view_TrueFalse.alpha = 0.0
        tblView_Measurement.alpha = 0.0
    }
    
    func openPriorityPickerView() {
        let storyboard = UIStoryboard(name: "UI", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "Prirority_VC") as? Prirority_VC {
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .popover
            navController.isNavigationBarHidden = true
            if let pctrl = navController.popoverPresentationController {
                navController.preferredContentSize = CGSize(width: 375, height: 200)
                pctrl.delegate = self
                pctrl.sourceView = self.view
                pctrl.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                pctrl.permittedArrowDirections = []
                viewController.callbackpriorityset = callbackpriorityset
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: BUtton Actions:
    @IBAction func btn_Save(_ sender: Any) {
        actionDelegate?.saveAuditAnswers()
    }
    
    @IBAction func btn_DropDown(_ sender: Any) {
        if tblView_DropDown.alpha == 0.0 {
            tblView_DropDown.alpha = 1.0
        } else {
            tblView_DropDown.alpha = 0.0
        }
    }
    
    @IBAction func btn_Yes(_ sender: Any) {
        actionDelegate?.measurementOrSubNormalActionYes()
    }
    
    @IBAction func btn_No(_ sender: Any) {
        actionDelegate?.measurementOrSubNormalActionNo()
    }
    
    @IBAction func btn_Priority(_ sender: Any) {
        globalbtn = btn_Priority
        globalindex = 0
        priorityClick(index: globalindex, btn: globalbtn)
    }
    
    @IBAction func btn_Cancel(_ sender: Any) {
        removeUnusedMemory()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_DeletePhoto(_ sender: Any) {
        actionDelegate?.deleteMeasurementOrSubNormalPhoto()
    }
    
    @IBAction func btn_CapturePhoto(_ sender: Any) {
       actionDelegate?.captureMeasurementOrSubNormalPhoto()
        
    }
    ///Managing super Audit case:
    //MARK: =============
    @IBAction func btn_Inspector(_ sender: Any) {
        view_InspectorQuestion.alpha = 1.0
    }
    
    @IBAction func btn_ViewText(_ sender: Any) {
        MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("TextMessageAlert", comment: ""))
    }
    
    @IBAction func btn_CancelInspectorData(_ sender: Any) {
        view_InspectorQuestion.alpha = 0.0
    }
    @IBAction func btn_SaveInspectorData(_ sender: Any) {
        view_InspectorQuestion.alpha = 0.0
       // updateInspectorArray()
    }
    
    @IBAction func btn_InspectorPriority(_ sender: Any) {
        actionDelegate?.setInspectorPriority()
    }
    
    @IBAction func btn_InspectorYes(_ sender: Any) {
        actionDelegate?.inspectorActionYes()
    }
    
    @IBAction func btn_InspectorNo(_ sender: Any) {
        actionDelegate?.inspectorActionNo()
    }
    
    @IBAction func btn_SaveText(_ sender: Any) {
     
        obAnswer.answerDescription = tv_AuditorDescription.text
        view_TextDescription.alpha = 0.0
        tv_AuditorDescription?.resignFirstResponder()
    }
    
    @IBAction func btn_CancelText(_ sender: Any) {
        tv_AuditorDescription.resignFirstResponder()
        view_TextDescription.alpha = 0.0
    }
    
    @IBAction func btn_InspctorImg(_ sender: Any) {
        actionDelegate?.captureInpsectorImage()
    }
    
    @IBAction func btn_RemoveInspectorImg(_ sender: Any) {
        actionDelegate?.removeInspectorImage()
    }
}

