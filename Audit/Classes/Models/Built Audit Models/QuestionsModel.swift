//
//  QuestionsModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 27/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit


// All the querstions will be inserted in DB by this model
class QuestionsModel: NSObject {
    var answers:String? = String()
    var answerId:String? = String()
    var selectedAnswerIdForSubQuestion:Int? = Int()
    var questionId:Int? = Int()
    var lang:String? = String()
    var question:String? = String()
    var arrSubQuestions:[QuestionsModel]? = [QuestionsModel]()
    var arrInspectorQuestions:[QuestionsModel]? = [QuestionsModel]()
    //Which type of question you are showing like popup,
    var questionType:Int? = Int()
    //Which category is used: like normal etc
    var categoryType:Int? = Int()
    var priority:Int? = Int()
    var auditId:Int? = Int()
    var auditType:Int? = Int()
    var locationId:Int? = Int()
    //THis variable is only used to pass the id into subquestions level
    var subLocationId:Int? = Int()
    var hasSubQuestion:Int? = Int()
    var isSubQuestion:Int? = Int()
    var parentQuestionId: Int? = Int()
    var isSuperUserAudit: Int? = Int()
    var locationIds:String? = String()
    
    override init() { }
    
    func initWith(dict: NSDictionary, questionCategory: Int, auditId:Int, locationId:Int, subLocationId: Int, isSubQuestion: Int, parentQuestionId: Int) {
        self.auditId = auditId
        self.locationId = locationId
        self.locationIds = dict["module_id"] as? String
        let strA = dict["answer"] as? String
        
        self.answers = strA?.replacingOccurrences(of: "\\r\\n", with: AnswerSeperator)
        self.answers = strA?.replacingOccurrences(of: "\r\n", with: AnswerSeperator)
        if let answerId = dict["answernum"] as? String {
            self.answerId = answerId
        } else if let intAnswerId =  dict["answernum"] as? Int {
            self.answerId = String(format: "%d", intAnswerId)
        }
        
        self.questionId = dict["id"] as? Int
        self.question = dict["question"] as? String
        self.subLocationId = subLocationId
        
        self.priority = QuestionPriority.Low
        self.categoryType = questionCategory
        self.questionType = dict["type"] as? Int
        self.parentQuestionId = parentQuestionId
        if dict["answer_id"] as? Int != nil {
            self.selectedAnswerIdForSubQuestion = dict["answer_id"] as? Int
        } else {
            self.selectedAnswerIdForSubQuestion = 0
        }
        
        if let arrSQ = dict["sub_questions"] as? NSArray {
            ///This condition checks wether this has sub questions or not
            if (arrSQ.count) > 0 {
                self.hasSubQuestion = 1
            } else {
                self.hasSubQuestion = 0
            }
            self.isSubQuestion = isSubQuestion
            
            for i in 0..<(arrSQ.count) {
                /// The subquestions will also treat as Questions so during implementation and managing all will be in a integrity manner worked.
                let obSQ = QuestionsModel()
                obSQ.initWith(dict: arrSQ[i] as! NSDictionary, questionCategory: QuestionCategory.Normal, auditId: self.auditId!, locationId: self.locationId!, subLocationId: self.subLocationId!, isSubQuestion: 1, parentQuestionId: (dict["id"] as? Int)!)
                obSqlite.insertQuestionsData(obQuestion: obSQ)
                arrSubQuestions?.append(obSQ)
            }
        }
        
        /// Here managing Super Audit feature or Super User
        if let arrIQ = dict["ins_questions"] as? NSArray {
            if (arrIQ.count) > 0 {
                self.isSuperUserAudit = 1
            } else {
                self.isSuperUserAudit = 0
            }
            for i in 0..<(arrIQ.count) {
                /// the ins questions will also treat as inspector questions and hence the question Id will be refrence for inspector questions
                let obIQ = QuestionsModel()
                obIQ.initWith(dict: arrIQ[i] as! NSDictionary, questionCategory: QuestionCategory.Normal, auditId: self.auditId!, locationId: self.locationId!, subLocationId: self.subLocationId!, isSubQuestion: 0, parentQuestionId: (dict["id"] as? Int)!)
                /// This will satisfy that it is a super audit or super user audit
                obIQ.isSuperUserAudit = 1
                //print("obIQ = \(obIQ.isSuperUserAudit)")
                obSqlite.insertQuestionsData(obQuestion: obIQ)
                arrInspectorQuestions?.append(obIQ)
            }
        }
    }
    
    func initWith(dict: NSDictionary, questionCategory: Int, auditId:Int, locationId:Int, locationIds: String, subLocationId: Int, isSubQuestion: Int, parentQuestionId: Int) {
        self.auditId = auditId
        self.locationId = locationId
        self.locationIds = "0"//dict["location_id"] as? String
        let strA = dict["answer"] as? String
        
        self.answers = strA?.replacingOccurrences(of: "\\r\\n", with: AnswerSeperator)
        self.answers = strA?.replacingOccurrences(of: "\r\n", with: AnswerSeperator)
        if let answerId = dict["answernum"] as? String {
            self.answerId = answerId
        } else if let intAnswerId =  dict["answernum"] as? Int {
            self.answerId = String(format: "%d", intAnswerId)
        }
        
        self.questionId = dict["id"] as? Int
        self.question = dict["question"] as? String
        self.subLocationId = dict["content_id"] as? Int
        
        self.priority = QuestionPriority.Low
        self.categoryType = questionCategory
        self.questionType = dict["type"] as? Int
        self.parentQuestionId = parentQuestionId
        if dict["answer_id"] as? Int != nil {
            self.selectedAnswerIdForSubQuestion = dict["answer_id"] as? Int
        } else {
            self.selectedAnswerIdForSubQuestion = 0
        }
        
        if let arrSQ = dict["sub_questions"] as? NSArray {
            ///This condition checks wether this has sub questions or not
            if (arrSQ.count) > 0 {
                self.hasSubQuestion = 1
            } else {
                self.hasSubQuestion = 0
            }
            self.isSubQuestion = isSubQuestion
            
            for i in 0..<(arrSQ.count) {
                /// The subquestions will also treat as Questions so during implementation and managing all will be in a integrity manner worked.
                let obSQ = QuestionsModel()
                self.locationIds = ""
                obSQ.initWith(dict: arrSQ[i] as! NSDictionary, questionCategory: self.categoryType!, auditId: self.auditId!, locationId: self.locationId!, locationIds: self.locationIds!, subLocationId: self.subLocationId!, isSubQuestion: 1, parentQuestionId: (dict["id"] as? Int)!)
                obSqlite.insertQuestionsData(obQuestion: obSQ)
                arrSubQuestions?.append(obSQ)
            }
        }
        
        /// Here managing Super Audit feature or Super User
        if let arrIQ = dict["ins_questions"] as? NSArray {
            if (arrIQ.count) > 0 {
                self.isSuperUserAudit = 1
            } else {
                self.isSuperUserAudit = 0
            }
            for i in 0..<(arrIQ.count) {
                /// the ins questions will also treat as inspector questions and hence the question Id will be refrence for inspector questions
                let obIQ = QuestionsModel()
                 self.locationIds = ""
                obIQ.initWith(dict: arrIQ[i] as! NSDictionary, questionCategory: QuestionCategory.Normal, auditId: self.auditId!, locationId: self.locationId!, locationIds: self.locationIds!, subLocationId: self.subLocationId!, isSubQuestion: 0, parentQuestionId: (dict["id"] as? Int)!)
                /// This will satisfy that it is a super audit or super user audit
                obIQ.isSuperUserAudit = 1
                //print("obIQ = \(obIQ.isSuperUserAudit)")
                obSqlite.insertQuestionsData(obQuestion: obIQ)
                arrInspectorQuestions?.append(obIQ)
            }
        }
    }
    
}
