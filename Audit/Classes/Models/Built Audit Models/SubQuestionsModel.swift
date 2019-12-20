//
//  SubQuestionsModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 27/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

// All the sub questions will be inserted in DB by this model

class SubQuestionsModel: NSObject {
    var auditId:Int? = Int()
    var locationId:Int? = Int()
    var subLocationId:Int? = Int()
    var answer:String? = String()
    var answerId:Int? = Int()
    var questionId:Int? = Int()
    var subQuestionId:Int? = Int()
    var lang:String? = String()
    var subQuestion:String? = String()
    var subQuestionType:Int? = Int()
    var hasSubQuestion:Int? = Int()
    var isSubQuestion:Int? = Int()
    var parentQuestionId: Int? = Int()
    var arrSubQuestions:[SubQuestionsModel]? = [SubQuestionsModel]()
    
    override init() { }

    func initWith(dict: NSDictionary,auditId: Int, locationId: Int ,subLocationId: Int, questionId: Int) {
      let strA = dict["answer"] as? String
        self.answer = strA?.replacingOccurrences(of: "\r\n", with: AnswerSeperator)//dict["answer"] as? String
        self.answerId = dict["answer_id"] as? Int
        self.subQuestionId = dict["id"] as? Int
        self.subQuestion = dict["question"] as? String
        self.subQuestionType = dict["type"] as? Int
        
        self.auditId = auditId
        self.locationId = locationId
        self.subLocationId = subLocationId
        self.questionId = questionId
    }
    
}
