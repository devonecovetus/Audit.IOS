//
//  AuditAnswerModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 28/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

// All the answers during answering are saved in  DB via this  model

class AuditAnswerModel: NSObject {
    
    var incId:Int? = Int()
    var auditId:Int? = Int()
    var locationId:Int? = Int()
    var subLocationId:Int? = Int()
    var folderId: Int? = Int()
    var questionId:Int? = Int()
    var answerId:String? = String()
    //Which type of question you are showing like popup,
    var questionType:Int? = Int()
    //Which category is used: like normal etc
    var categoryType:Int? = Int()
    var priority:Int? = Int()
    var isUpdate:Int? = Int()
    var sublocation_subfolder_id:Int? = Int()
    var subfolder_id:Int? = Int()
    var question:String? = String()
    var answers:String? = String()
    var answerDescription:String? = String()
    var imgName:String? = String()
    var savedAnswer:String? = String()
    var savedAnswer_id:String? = String()
    var lang:String? = String()
 //   var arrSubAnswers = [AuditSubAnswersModel]()
    var hasSubQuestion:Int? = Int()
    var isSubQuestion:Int? = Int()
    var parentQuestionId:Int? = Int()
    var selectedAnswerIdForSubQuestion:Int? = Int()
    var arrSubAnswers = [AuditAnswerModel]()
    var arrInspectorAnswers = [AuditAnswerModel]()
    var isSync:Int? = Int()
    var isSuperUserAudit: Int? = Int()
    
    override init() { }
    
    func initWith(obQue: QuestionsModel, folderId: Int, sublocation_subfolder_id: Int, subfolder_id: Int, sublocation_id: Int) {
        
        //print("locationId = \(obQue.locationId!)")
        
        self.isSync = 0
        self.incId = 0
        self.auditId = obQue.auditId
        self.locationId = obQue.locationId
        self.subLocationId = sublocation_id
        self.folderId = folderId
        self.questionId = obQue.questionId
        self.answerId = obQue.answerId
        self.questionType = obQue.questionType
        self.categoryType = obQue.categoryType
        self.priority = obQue.priority
        self.isUpdate = 0
        self.sublocation_subfolder_id = sublocation_subfolder_id
        self.subfolder_id = subfolder_id
        self.question = obQue.question
        self.answers = obQue.answers
        self.answerDescription = ""
        self.imgName = ""
        self.savedAnswer = ""
        self.savedAnswer_id = ""
        self.parentQuestionId = obQue.parentQuestionId
        self.isSubQuestion = obQue.isSubQuestion
        self.hasSubQuestion = obQue.hasSubQuestion
        self.selectedAnswerIdForSubQuestion = obQue.selectedAnswerIdForSubQuestion
        self.isSuperUserAudit = obQue.isSuperUserAudit
    }
    
}
