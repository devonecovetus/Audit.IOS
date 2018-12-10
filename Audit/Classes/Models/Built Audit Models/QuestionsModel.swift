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
    var questionId:Int? = Int()
    var lang:String? = String()
    var question:String? = String()
    var arrSubQuestions:[SubQuestionsModel]? = [SubQuestionsModel]()
    //Which type of question you are showing like popup,
    var questionType:Int? = Int()
    //Which category is used: like normal etc
    var categoryType:Int? = Int()
    var priority:Int? = Int()
    var auditId:Int? = Int()
    var locationId:Int? = Int()
    //THis variable is only used to pass the id into subquestions level
    var subLocationId:Int? = Int()
    
    override init() { }
    
    func initWith(dict: NSDictionary, questionCategory: Int, auditId:Int, locationId:Int, subLocationId: Int) {
        self.auditId = auditId
        self.locationId = locationId
        let strA = dict["answer"] as? String
        print("strA = \(strA)")
        
        self.answers = strA?.replacingOccurrences(of: "\r\n", with: AnswerSeperator)//dict["answer"] as? String
        self.answerId = dict["answernum"] as? String
        self.questionId = dict["id"] as? Int
        self.question = dict["question"] as? String
        self.subLocationId = subLocationId
        
        self.priority = QuestionPriority.Low
        self.categoryType = questionCategory
        self.questionType = dict["type"] as? Int
        
        let arrSQ = dict["sub_questions"] as? NSArray
        for i in 0..<(arrSQ?.count)! {
            let dictSQ = arrSQ![i] as! NSDictionary
            let obSQ = SubQuestionsModel()
            obSQ.initWith(dict: dictSQ, auditId: self.auditId!, locationId: self.locationId! , subLocationId: self.subLocationId!, questionId: self.questionId!)
            
            //Here insert subquestions data
            obSqlite.insertSubQuestionsData(obSubQ: obSQ)
            arrSubQuestions?.append(obSQ)
        }
    }
}
