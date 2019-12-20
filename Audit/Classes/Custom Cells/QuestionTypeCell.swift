//
//  QuestionTypeCell.swift
//  Audit
//
//  Created by Mac on 12/18/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol QuestionDelegate {
    func cameraClick(index: Int, btn:UIButton)
    func deletephotoClick(index: Int)
    func priorityClick(index: Int, btn:UIButton)
    
    func setYesNoAnswerOnClick(index: Int, obAns: AuditAnswerModel)
    func setMultipleAnswerData(index: Int, obAns: AuditAnswerModel)
    func setDataOnNextScreen(index: Int, obAns: AuditAnswerModel, selectedAnswer: String)
    func setQuestionDescription(index: Int, obAns: AuditAnswerModel)
    func setTextData(index: Int, obAns: AuditAnswerModel)
    func removeLastObject(index: Int)
    func showConfirmPopUpOnTextDescription(index: Int?, obAns: AuditAnswerModel)
}

protocol QuestionSuperUserAuditDelegate {
    func viewAndSetTextDescription(index: Int, obAns: AuditAnswerModel)
    func setAndGetInspectorQuestionData(index: Int, obAns: AuditAnswerModel)
}

class QuestionTypeCell: UITableViewCell {
    
    var delegate: QuestionDelegate?
    var superAuditDelegate: QuestionSuperUserAuditDelegate?
    var obQuestion = AuditAnswerModel()
    var intIndex: Int = Int()
    
    @IBAction func btn_Inspector(_ sender: Any) {
        superAuditDelegate?.setAndGetInspectorQuestionData(index: intIndex, obAns: obQuestion)
    }
    @IBOutlet weak var btn_Inspector: UIButton!
    @IBAction func btn_ViewText(_ sender: Any) {
        superAuditDelegate?.viewAndSetTextDescription(index: intIndex, obAns: obQuestion)
    }
    @IBOutlet weak var btn_ViewText: UIButton!
    @IBOutlet weak var lbl_question: UILabel!
    @IBOutlet weak var btn_priority: UIButton!
    @IBOutlet weak var tv_description: UITextView!
    @IBOutlet weak var btn_camera: UIButton!
    
    @IBOutlet weak var img_photo: UIImageView?
    @IBOutlet weak var btn_delete: UIButton!
    
    @IBOutlet weak var tv_text: UITextView!

    @IBOutlet weak var btn_DropDown: UIButton!
    
    // --- Type 2
    @IBOutlet weak var btn_Yes: UIButton!
    @IBOutlet weak var btn_No: UIButton!
    
    // ---- Type 3
    @IBOutlet weak var tblView: UITableView!
    var arrAnswers = [AnswerTypeModel]()
    @IBOutlet var tableheight_constraint: NSLayoutConstraint!
    
    @IBAction func btn_camera(_ sender: UIButton) {
        delegate?.cameraClick(index: intIndex, btn: sender)
    }
    
    @IBAction func btn_Delete(_ sender: UIButton) {
        delegate?.deletephotoClick(index: intIndex)
    }
    
    @IBAction func btn_priority(_ sender: UIButton) {
        delegate?.priorityClick(index: intIndex, btn: sender)
    }
    
    @IBAction func btn_DropDown(_ sender: Any) {
        if tblView.alpha == 0.0 {
            tblView.alpha = 1.0
        } else {
            tblView.alpha = 0.0
        }
    }
    
    @IBAction func btn_Yes(_ sender: Any) {
        obQuestion.savedAnswer = arrAnswers[0].strAnswer
        obQuestion.savedAnswer_id = arrAnswers[0].answerId
        obQuestion.isUpdate = 1
         fetchSubQuestionData(ansId: Int(arrAnswers[0].answerId)!, answer: arrAnswers[0].strAnswer)
        delegate?.setYesNoAnswerOnClick(index: intIndex, obAns: obQuestion)
    }
    
    @IBAction func btn_No(_ sender: Any) {
        obQuestion.savedAnswer = arrAnswers[1].strAnswer
        obQuestion.savedAnswer_id = arrAnswers[1].answerId
        obQuestion.isUpdate = 1
      
        fetchSubQuestionData(ansId: Int(arrAnswers[1].answerId)!, answer: arrAnswers[1].strAnswer)
        delegate?.setYesNoAnswerOnClick(index: intIndex, obAns: obQuestion)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if tblView != nil {
            tblView.tableFooterView = UIView()
        }
        
        tv_description.delegate = self
        setLanguageSetting()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        if btn_DropDown != nil {
            btn_DropDown.setTitle(NSLocalizedString("SelectOption", comment: ""), for: UIControlState.normal)
        }
    }
    
    func setQuestionData(obQuestion: AuditAnswerModel) {
        
        self.obQuestion = obQuestion
        setSuperUserAuditView()
        tv_description.delegate = self
        tv_description.tag = intIndex
        tv_description.textColor = UIColor.lightGray
        tv_description.text = NSLocalizedString("TextPlaceHolder", comment: "")
        if (self.obQuestion.answerDescription?.count)! > 0 {
            if intIndex == tv_description.tag {
                //print("txt desc = \(obQuestion.answerDescription!)")
            tv_description.textColor = UIColor.black
            tv_description.text = self.obQuestion.answerDescription!
            }
        } else {
           // tv_description.text = ""
        }
        
        if obQuestion.questionType == QuestionType.Text {
            setTextData(obQuestion: obQuestion)
        }
        else if obQuestion.questionType == QuestionType.Radio {
            tblView.rowHeight = UITableViewAutomaticDimension
            tblView.estimatedRowHeight = 44
            setRadioQuestionData(obQuestion: obQuestion)
        }
        else if obQuestion.questionType == QuestionType.CheckBox {
            tblView.rowHeight = UITableViewAutomaticDimension
            tblView.estimatedRowHeight = 44
            setCheckboxQuestionData(obQuestion: obQuestion)
        }
        else if obQuestion.questionType == QuestionType.DropDown {
            tblView.rowHeight = UITableViewAutomaticDimension
            tblView.estimatedRowHeight = 44
            setDropDownQuestionData(obQuestion: obQuestion)
        }
        else if obQuestion.questionType == QuestionType.TrueFalse {
            setTrueFalseQuestionData(obQuestion: obQuestion)
        }
        else if obQuestion.questionType == QuestionType.PopUp {
            tblView.rowHeight = UITableViewAutomaticDimension
            tblView.estimatedRowHeight = 44
            setRadioQuestionData(obQuestion: obQuestion)
        }
        
    }
    
    func setQuestionPriority() {
        
        if obQuestion.priority == QuestionPriority.Low {
            btn_priority.setTitle(QuestionPriorityName.Low, for: UIControlState.normal)
            btn_priority.backgroundColor = PriorityColor.Low
        } else if obQuestion.priority == QuestionPriority.Medium {
            btn_priority.setTitle(QuestionPriorityName.Medium, for: UIControlState.normal)
            btn_priority.backgroundColor = PriorityColor.Medium
        } else if obQuestion.priority == QuestionPriority.High {
            btn_priority.setTitle(QuestionPriorityName.High, for: UIControlState.normal)
            btn_priority.backgroundColor = PriorityColor.High
        } else if obQuestion.priority == QuestionPriority.PPP {
            btn_priority.setTitle(QuestionPriorityName.PPP, for: UIControlState.normal)
            btn_priority.backgroundColor = PriorityColor.PPP
        }
    }
    
    func setImageData() {
        if obQuestion.imgName == "" {
            btn_camera.alpha = 1.0
            img_photo?.alpha = 0.0
            btn_delete.alpha = 0.0
        } else {
            btn_camera.alpha = 0.0
            img_photo?.alpha = 1.0
            btn_delete.alpha = 1.0
            
            let obFM:FileDownloaderManager? = FileDownloaderManager()
            let image_download = UIImage(contentsOfFile: (obFM?.getAuditImagePath(imageName: obQuestion.imgName!))!)
            img_photo?.image = image_download
            
            let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showAvatar(_:)))
            tapGestureRecognizer11.numberOfTapsRequired = 1
            img_photo?.addGestureRecognizer(tapGestureRecognizer11)
        }
    }
    
    func setSuperUserAuditView() {
     //   //print("obQuestion. = \(obQuestion.question!), obQuestion.isSuperUserAudit = \(obQuestion.isSuperUserAudit!)")
        if obQuestion.isSuperUserAudit == 1 { /// Means a super user audit
            tv_description.alpha = 0.0
            btn_ViewText.alpha = 1.0
            btn_Inspector.alpha = 1.0
        } else { /// means a normal user
            tv_description.alpha = 1.0
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
    
    func setTextData(obQuestion: AuditAnswerModel) {
        tv_text.delegate = self
        tv_text.tag = intIndex + 10000
        lbl_question.text = "\(intIndex + 1)." + obQuestion.question!
        setQuestionPriority()
        setImageData()
        if (obQuestion.answerDescription?.count)! > 0 {
            
                tv_description.textColor = UIColor.black
                tv_description.text = obQuestion.answerDescription!
            
        }
        if (obQuestion.savedAnswer?.count)! > 0 {
            tv_text.textColor = UIColor.black
            tv_text.text = obQuestion.savedAnswer!
        }
        
    }
    
    func setRadioQuestionData(obQuestion: AuditAnswerModel) {
        
        lbl_question.text = "\(intIndex + 1)." + obQuestion.question!
        setQuestionPriority()
        setImageData()
        setPreviousDataSelected()
        
        tblView.reloadData()
        tableheight_constraint.constant =  DeviceType.IS_PHONE ? (CGFloat(arrAnswers.count * 35)) :  tblView.contentSize.height
        print("tableheight_constraint.constant = \(tableheight_constraint.constant)")
    }
    
    func setCheckboxQuestionData(obQuestion: AuditAnswerModel) {
        
        lbl_question.text = "\(intIndex + 1)." + obQuestion.question!
        setQuestionPriority()
        setImageData()
        
        setPreviousDataSelected()
        
        tblView.allowsMultipleSelection = true
        tblView.reloadData()
        tableheight_constraint.constant = tblView.contentSize.height
    }
    
    func setDropDownQuestionData(obQuestion: AuditAnswerModel) {
        arrAnswers = [AnswerTypeModel]()
        tblView.alpha = 0.0
        lbl_question.text = "\(intIndex + 1). " + obQuestion.question!
        setQuestionPriority()
        setImageData()
        
        var arr_Answer1 = [String]()
        var arrAnswerIds = [String]()
        
        let strAns =  NSLocalizedString("SelectOption", comment: "") + "\(AnswerSeperator)\(obQuestion.answers!)"//
        let strAnsId = "0" + ",\(obQuestion.answerId!)"
        
        /// To avoid some unintentionally data redundancy I work in this way.
        arr_Answer1 = (strAns.components(separatedBy: AnswerSeperator))
        arrAnswerIds = (strAnsId.components(separatedBy: ","))
        
        /// Here to check if answers are saved in saved answer or not. From this condition I am accessing the answers and ids
        
        if (obQuestion.savedAnswer?.count)! > 0 {
            let arr_SavedAnswer = (obQuestion.savedAnswer?.components(separatedBy: AnswerSeperator))!
            btn_DropDown.setTitle(arr_SavedAnswer[0], for: UIControlState.normal)
            btn_DropDown.backgroundColor = CustomColors.themeColorGreen
            btn_DropDown.setTitleColor(UIColor.white, for: UIControlState.normal)
        } else {
            btn_DropDown.backgroundColor = UIColor.groupTableViewBackground
            btn_DropDown.setTitleColor(UIColor.black, for: UIControlState.normal)
        }
        
        //print("intIndex = \(intIndex), arr_Answer1 = \(arr_Answer1.count), arrAnswers.count = \(arrAnswers.count)")
        
        /// On the bbbasis of the condition the loop executes the futher flow.
        if arrAnswers.count != arr_Answer1.count {
            for i in 0..<arr_Answer1.count {
                let obAns = AnswerTypeModel()
                obAns.initWith(answer: arr_Answer1[i], answerId: arrAnswerIds[i] , type: obQuestion.questionType!, status: 0)
                arrAnswers.append(obAns)
            }
        }
        tblView.reloadData()
        tblView.isScrollEnabled = true
    }
    
    func setTrueFalseQuestionData(obQuestion: AuditAnswerModel) {
        
        lbl_question.text = "\(intIndex + 1)." + obQuestion.question!
        setQuestionPriority()
        setImageData()
        setPreviousDataSelected()
        
        btn_Yes.setTitle(arrAnswers[0].strAnswer, for: UIControlState.normal)
        btn_No.setTitle(arrAnswers[1].strAnswer, for: UIControlState.normal)
        
        if obQuestion.savedAnswer_id == arrAnswers[0].answerId {
            btn_Yes.backgroundColor = UIColor(red: 44/255.0, green: 189/255.0, blue: 165/255.0, alpha: 1.0)
            btn_No.backgroundColor = UIColor(red: 150/255.0, green: 159/255.0, blue: 169/255.0, alpha: 1.0)
        } else if obQuestion.savedAnswer_id == arrAnswers[1].answerId {
            btn_Yes.backgroundColor = UIColor(red: 150/255.0, green: 159/255.0, blue: 169/255.0, alpha: 1.0)
            btn_No.backgroundColor = UIColor(red: 249/255.0, green: 95/255.0, blue: 98/255.0, alpha: 1.0)
        }
        /*
        if arrAnswers[0].status == 1 {
            btn_Yes.backgroundColor = UIColor(red: 44/255.0, green: 189/255.0, blue: 165/255.0, alpha: 1.0)
            btn_No.backgroundColor = UIColor(red: 150/255.0, green: 159/255.0, blue: 169/255.0, alpha: 1.0)
        } else if arrAnswers[1].status == 1 {
            btn_Yes.backgroundColor = UIColor(red: 150/255.0, green: 159/255.0, blue: 169/255.0, alpha: 1.0)
            btn_No.backgroundColor = UIColor(red: 249/255.0, green: 95/255.0, blue: 98/255.0, alpha: 1.0)
        } */
    }
    
    func setPreviousDataSelected() {
        arrAnswers = [AnswerTypeModel]()
        
        var arr_Answer1 = [String]()
        var arrAnswerIds = [String]()
        var arrSaveAnswerId = [String]()
        
        /// To avoid some unintentionally data redundancy I work in this way.
        arr_Answer1 = (obQuestion.answers?.components(separatedBy: AnswerSeperator))!
        arrAnswerIds = (obQuestion.answerId?.components(separatedBy: ","))!
        /// Here to check if answers are saved in saved answer or not. From this condition I am accessing the answers and ids
        
        if (obQuestion.savedAnswer?.count)! > 0 {
            arrSaveAnswerId = (obQuestion.savedAnswer_id?.components(separatedBy: ","))!
        }
        
        /// On the bbbasis of the condition the loop executes the futher flow.
        if arrAnswers.count != arr_Answer1.count {
            /// Here adding placeholder value
            let obAns = AnswerTypeModel()
            obAns.initWith(answer: NSLocalizedString("SelectOption", comment: ""), answerId: "0" , type: obQuestion.questionType!, status: 0)
    //        arrAnswers.append(obAns)
            for i in 0..<arr_Answer1.count {
                let obAns = AnswerTypeModel()
                obAns.initWith(answer: arr_Answer1[i], answerId: arrAnswerIds[i] , type: obQuestion.questionType!, status: 0)
                arrAnswers.append(obAns)
            }
        }
        
        if (obQuestion.savedAnswer?.count)! > 0 {
            if arrAnswers.count == arr_Answer1.count {
                for j in 0..<arrAnswers.count {
                    for k in 0..<arrSaveAnswerId.count {  
                        if arrAnswers[j].answerId == arrSaveAnswerId[k] {
                            arrAnswers[j].status = 1
                        }
                    }
                }
            }
        }
    }
    
    func setLanguageSetting() {
        
        btn_ViewText.backgroundColor = UIColor.clear
        btn_Inspector.backgroundColor = UIColor.clear
        
        tv_description.text = NSLocalizedString("TextPlaceHolder", comment: "")
        if tv_text != nil {
            
        }
        btn_priority.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_question.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tv_description.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        img_photo?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_question.textAlignment = .right
            tv_description.textAlignment = .right
        }
        btn_camera.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if btn_Yes != nil {
            btn_Yes.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
            btn_No.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
            btn_No.setTitle(NSLocalizedString("No", comment: ""), for: UIControlState.normal)
            btn_Yes.setTitle(NSLocalizedString("Yes", comment: ""), for: UIControlState.normal)
        }
        
        if btn_DropDown != nil {
            btn_DropDown.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
            if kAppDelegate.strLanguageName == LanguageType.Arabic {
                btn_DropDown.contentHorizontalAlignment = .right
            }
            btn_DropDown.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
        }
        
    }
}

extension QuestionTypeCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAnswers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if obQuestion.questionType == QuestionType.CheckBox {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckUncheck", for: indexPath) as! CheckUncheck_Cell
            cell.setCheckUnCheckData(obAns: arrAnswers[indexPath.row])
            return cell
        } else if obQuestion.questionType == QuestionType.DropDown {
            guard let cell: CheckUncheck_Cell = tableView.dequeueReusableCell(withIdentifier: "DropDown", for: indexPath) as? CheckUncheck_Cell else {
                return UITableViewCell()
            }
          //  let cell = tableView.dequeueReusableCell(withIdentifier: "DropDown", for: indexPath) as! CheckUncheck_Cell
            
           /* if indexPath.row == 0 {
                cell.setPlaceHolderDropDownData()
            } else { */
               // cell.setDropDownData(obAns: arrAnswers[indexPath.row - 1])
            //}
  
             cell.setDropDownData(obAns: arrAnswers[indexPath.row])
            return cell
        } else if obQuestion.questionType == QuestionType.Radio {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioType", for: indexPath) as! CheckUncheck_Cell
            /*
            if indexPath.row == 0 {
                cell.setPlaceHolderRadioData(obAns: arrAnswers[indexPath.row])
            } else {
                cell.setRadioData(obAns: arrAnswers[indexPath.row - 1])
            } */
            cell.setRadioData(obAns: arrAnswers[indexPath.row])
            return cell
        } else if obQuestion.questionType == QuestionType.PopUp {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Popup", for: indexPath) as! CheckUncheck_Cell
            cell.setRadioData(obAns: arrAnswers[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceType.IS_PHONE ? 35.0 : UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var strAnswers = String()
        var strAnswerId = String()
        
        if obQuestion.questionType == QuestionType.Radio {
           
                for i in  0..<arrAnswers.count {
                    arrAnswers[i].status = 0
                }
                if arrAnswers[indexPath.row].status == 0 {
                    arrAnswers[indexPath.row].status = 1
                    strAnswers = arrAnswers[indexPath.row].strAnswer
                    strAnswerId = arrAnswers[indexPath.row].answerId
                }
            obQuestion.isUpdate = 1
            fetchSubQuestionData(ansId: Int(strAnswerId)!, answer: strAnswers)
            obQuestion.savedAnswer = strAnswers
            obQuestion.savedAnswer_id = strAnswerId
        }
        else if obQuestion.questionType == QuestionType.CheckBox {
            
            var arrSavedAnswer = NSMutableArray()
            var arrSavedAnswerId = NSMutableArray()
            
            if obQuestion.savedAnswer != "" {
                arrSavedAnswer = NSMutableArray(array:(obQuestion.savedAnswer?.components(separatedBy: AnswerSeperator))!)
                arrSavedAnswerId = NSMutableArray(array:(obQuestion.savedAnswer_id?.components(separatedBy: ","))!)
            }
            
            if arrAnswers[indexPath.row].status == 0 {
                arrAnswers[indexPath.row].status = 1
                arrSavedAnswer.add(arrAnswers[indexPath.row].strAnswer)
                arrSavedAnswerId.add(arrAnswers[indexPath.row].answerId)
            } else if arrAnswers[indexPath.row].status == 1 {
                arrAnswers[indexPath.row].status = 0
                arrSavedAnswer.remove(arrAnswers[indexPath.row].strAnswer)
                arrSavedAnswerId.remove(arrAnswers[indexPath.row].answerId)
            }
            
            strAnswers = arrSavedAnswer.componentsJoined(by: AnswerSeperator)
            strAnswerId = arrSavedAnswerId.componentsJoined(by: ",")
            
            obQuestion.isUpdate = 1
            obQuestion.savedAnswer = strAnswers
            obQuestion.savedAnswer_id = strAnswerId
            fetchSubQuestionData(ansId: Int(arrAnswers[indexPath.row].answerId)!, answer: strAnswers)
        } else if obQuestion.questionType == QuestionType.DropDown {
            
            btn_DropDown.setTitle(NSLocalizedString("SelectOption", comment: ""), for: UIControlState.normal)
            
            for i in  0..<arrAnswers.count {
                arrAnswers[i].status = 0
            }
            if indexPath.row == 0 {
                if arrAnswers[indexPath.row].status == 0 {
                    arrAnswers[indexPath.row ].status = 1
                    strAnswers = ""
                    strAnswerId = arrAnswers[indexPath.row].answerId
                    btn_DropDown.setTitle(NSLocalizedString("SelectOption", comment: ""), for: UIControlState.normal)
                    btn_DropDown.backgroundColor = UIColor.groupTableViewBackground
                    btn_DropDown.setTitleColor(UIColor.black, for: UIControlState.normal)
                }
                obQuestion.isUpdate = 0
            } else {
                if arrAnswers[indexPath.row].status == 0 {
                    arrAnswers[indexPath.row ].status = 1
                    strAnswers = arrAnswers[indexPath.row ].strAnswer
                    strAnswerId = arrAnswers[indexPath.row].answerId
                    btn_DropDown.setTitle(strAnswers, for: UIControlState.normal)
                    btn_DropDown.backgroundColor = CustomColors.themeColorGreen
                    btn_DropDown.setTitleColor(UIColor.white, for: UIControlState.normal)
                }
                obQuestion.isUpdate = 1
                fetchSubQuestionData(ansId: Int(strAnswerId)!, answer: strAnswers)
            }
                /// main feature managing
            
            
            tblView.alpha = 0.0
            obQuestion.savedAnswer = strAnswers
            obQuestion.savedAnswer_id = strAnswerId
            
        }
        else if obQuestion.questionType == QuestionType.PopUp {
            
            for i in  0..<arrAnswers.count {
                arrAnswers[i].status = 0
                obQuestion.isUpdate = 0
            }
            if arrAnswers[indexPath.row].status == 0 {
                arrAnswers[indexPath.row].status = 1
                strAnswers = arrAnswers[indexPath.row].strAnswer
                strAnswerId = arrAnswers[indexPath.row].answerId
                obQuestion.isUpdate = 1
            }
            
            obQuestion.savedAnswer = strAnswers
            obQuestion.savedAnswer_id = strAnswerId
            fetchSubQuestionData(ansId: Int(strAnswerId)!, answer: strAnswers)
        }
        
        delegate?.setMultipleAnswerData(index: intIndex, obAns: obQuestion)
        tblView.reloadData()
    }
  
    func fetchSubQuestionData(ansId:Int, answer: String) {
        //print("")
        let arr = obSqlite.getAuditAnswers(auditId: obQuestion.auditId!, locationId: obQuestion.locationId!, folderId: obQuestion.folderId!, subfolderId: 0, sub_locationId: obQuestion.subLocationId!, sub_locationsub_folderId: obQuestion.sublocation_subfolder_id!, parentQueId: obQuestion.questionId!, selectedAnsId: ansId, fetchType: "subQue")
        
        /// Means there is a subquestion on this case string
        if arr.count > 0 {
            delegate?.setDataOnNextScreen(index: intIndex, obAns: arr[0], selectedAnswer: answer)
        } else {
            /// Here I am implementing logic in such a way that If user select option 2, then option 1 subanswers will be reset
            
       //    //print("obQuestion type = \(obQuestion.categoryType), isSubques = \(obQuestion.isSubQuestion)")
            if obQuestion.isSubQuestion == 0 && obQuestion.parentQuestionId == 0 {
         //      //print("obQuestion. = \(obQuestion.answers)")
            }
            delegate?.removeLastObject(index: intIndex)
        }
    }
    
}

extension QuestionTypeCell: UITextViewDelegate {
    
    // Textview Delegate Method
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == tv_description {
            if tv_description.text == NSLocalizedString("TextPlaceHolder", comment: "") {
                tv_description.textColor = UIColor.black
                tv_description.text = ""
                delegate?.showConfirmPopUpOnTextDescription(index: intIndex, obAns: obQuestion)
            }
            
            
        } else if textView == tv_text {
            if tv_text.text == "Answer..." {
                tv_text.textColor = UIColor.black
                tv_text.text = ""
            }
            tv_text.becomeFirstResponder()
            tv_description.resignFirstResponder()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if obQuestion.questionType == QuestionType.Text {
            if textView == tv_text {
                tv_text.resignFirstResponder()
                if tv_text.text.count > 0 {
                    if tv_text.text == "" {
                        tv_text.textColor = UIColor.lightGray
                        tv_text.text = "Answer..."
                    }
                } else {
                    obQuestion.savedAnswer = textView.text
                    obQuestion.savedAnswer_id = "1"
                    obQuestion.isUpdate = 1
                    delegate?.setTextData(index: intIndex, obAns: obQuestion)
                }
            } else if textView == tv_description {
                tv_description.resignFirstResponder()
                if tv_description.text.count > 0 {
                    obQuestion.answerDescription = textView.text
                    obQuestion.isUpdate = 1
                    delegate?.setTextData(index: intIndex, obAns: obQuestion)
                } else {
                    if tv_description.text == "" {
                        tv_description.textColor = UIColor.lightGray
                        tv_description.text = NSLocalizedString("TextPlaceHolder", comment: "")
                    }
                }
            }
        } else {
            if textView == tv_description {
                if tv_description.text.count > 0 {
                    tv_description.resignFirstResponder()
                    obQuestion.answerDescription = textView.text
                    obQuestion.isUpdate = 1
                    delegate?.setQuestionDescription(index: intIndex, obAns: obQuestion)
                } else {
                    if tv_description.text == "" {
                        tv_description.textColor = UIColor.lightGray
                        tv_description.text = NSLocalizedString("TextPlaceHolder", comment: "")
                    }
                }
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        func getTextStringCount() -> Int {
            var strDesc = tv_text.text.replacingOccurrences(of: " ", with: "")
            strDesc = strDesc.replacingOccurrences(of: "\n", with: "")
            return strDesc.count
        }
        
        if textView == tv_text {
            if getTextStringCount() == 0 {
                obQuestion.savedAnswer_id = "0"
                obQuestion.isUpdate = 1
                obQuestion.savedAnswer = ""
            } else {
                obQuestion.savedAnswer_id = "1"
                obQuestion.isUpdate = 1
                //print("index = \(index), tag = \(textView.tag)")
                obQuestion.savedAnswer = textView.text
            }
            
            
         //   delegate?.setTextData(index: intIndex, obAns: obQuestion)
        } else if textView == tv_description {
            //print("ans desc = \(textView.text)")
            obQuestion.answerDescription = textView.text
            obQuestion.isUpdate = 1
//            if tv_description.text.count > 0 {
//
//            } else {
//                if tv_description.text == "" {
//
//                }
//            }
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.autocorrectionType = .no
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
