//
//  AnswerTypeModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 27/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class AnswerTypeModel: NSObject {
    var strAnswer:String = String()
    var answerId:String = String()
    var answerType:Int? = Int()
    var status:Int? = Int()
    
    override init() { }
    
    func initWith(answer:String, answerId: String, type:Int = 0, status: Int = 0) {
        self.strAnswer = answer
        self.answerId = answerId
        self.answerType = type
        self.status = status
    }
    
}
