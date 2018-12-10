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
    var answers:String? = String()
    var answerId:String? = String()
    var questionId:Int? = Int()
    var lang:String? = String()
    var question:String? = String()
    //Which type of question you are showing like popup,
    var questionType:Int? = Int()
    //Which category is used: like normal etc
    var categoryType:Int? = Int()
    var priority:Int? = Int()
    var incId:Int? = Int()
    var savedAnswer:String? = String()
    var auditId:Int? = Int()
    var locationId:Int? = Int()
    var subLocationId:Int? = Int()
    var isUpdate:Int? = Int()
    var folderId: Int? = Int()
    var answerDescription:String? = String()
    var imgData:Data? = Data()
    var img64Data:String? = String()
    
    override init() { }
    
    func initWith(dict: NSDictionary) {
        
    }
    
}
