
//
//  DataSyncModel.swift
//  Audit
//
//  Created by Mac on 1/8/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class DataSyncModel: NSObject {
    
    var incIdAAT:Int? = Int() // --- AA Table ki Primary ID
    var incIdSLSFP:Int? = Int() // --- SLSFP Table ki Primary ID
    var arrMainSLSFPId:NSMutableArray? = NSMutableArray()
    var arrMultiSLSFPId:NSMutableArray? = NSMutableArray() /// isme SLSFP ki id save hogi aur baad me sync k time is array se photos update honge
    var userId:Int? = Int() // -- AA
    var auditId:Int? = Int() // -- AA
    var countryId:Int? = Int() // -- MAL
    var language:String? = String() // -- MAL
    var locationId:Int? = Int() // -- AA
    var subfolderId:Int? = Int() // -- AA (Folder ID)
    var subfolderTitle:String? = String() // -- LF (Folder Title)
    var layerId:Int? = Int() // -- AA (SubFolder ID)
    var layerTitle:String? = String() // -- LSFL (SubFolder Title)
    var layerDesc:String? = String() // -- LSFL (SubFolder Desc)
    var layerImg:String? = String() // -- LSFL (SubFolder Img)
    var incIdLSFL:Int? = Int() // -- LSFL (SubFolder ID)
    var subLocationId:Int? = Int() // -- AA (SubLocation ID)
    var subLocationLayerId:Int? = Int() // -- AA (SubLocationSubFolder ID)
    var subLocationLayerTitle:String? = String() // -- SLSFL (SubLocationSubFolder Title)
    var subLocationLayerDesc:String? = String() // -- SLSFL (SubLocationSubFolder Desc)
    var subLocationLayerFirstImage = [] as NSArray  // -- AA (Main Image = 1) at index 0
    var questionId:Int? = Int() // -- AA (Question ID)
    var isSuperUserAudit:Int? = Int()
    var parentId:Int? = Int() // -- AA (if main question = 0, subquestion = 1)
    var answerId:String? = String() // -- AA (Savedanswerid)
    var answerValue:String? = String() // -- AA (Text Answer)
    var questionType:Int? = Int() // -- AA (Question Type)
    var questionImage:String? = String() // -- AA (Question Image)
    var questionPriority:Int? = Int() // -- AA (Question Priority)
    var questionExtraText:String? = String() // -- AA (Question Text)
    var mul_image = [] as NSArray // -- SLSFP (Collection Images) at index 0

    override init() { }
    
    func initWith(obAnswer: AuditAnswerModel) {
        
        self.incIdAAT = obAnswer.incId
        self.userId = UserProfile.id
        self.auditId = obAnswer.auditId
        let dictcountry = obSqlite.getLang_CountryFromAuditList(auditId: obAnswer.auditId!)
        self.countryId = dictcountry["countryId"] as? Int
        self.language = dictcountry["language"] as? String
        self.locationId = obAnswer.locationId
        self.subfolderId = obAnswer.folderId
        self.subfolderTitle = obSqlite.getLocationFolderName(locationId: obAnswer.locationId!, auditId: obAnswer.auditId!, folderId: obAnswer.folderId!)
    //    //print("subfolderTitle = \(subfolderTitle)")
        self.layerId = obAnswer.subfolder_id
        let dictSubfolder = obSqlite.getLocationSubFolderInfo(locationId: obAnswer.locationId!, auditId: obAnswer.auditId!, folderId: obAnswer.folderId!, subFolderId: obAnswer.subfolder_id!)
      //  //print("dictSubfolder =\(dictSubfolder)")
        self.layerTitle = dictSubfolder["folderName"] as? String
        self.layerDesc = dictSubfolder["folderDesc"] as? String
        
        let is_sync_check = dictSubfolder["is_sync"] as? Int
        
        if is_sync_check == 1 {
            self.layerImg = ""
        } else {
            self.layerImg = dictSubfolder["photo"] as? String
        }
        
        // ghfg
        self.incIdLSFL = dictSubfolder["id"] as? Int
        
        self.subLocationId = obAnswer.subLocationId
        self.subLocationLayerId = obAnswer.sublocation_subfolder_id
        let dictSubLocationSubfolder = obSqlite.getSubLocationSubFolderInfo(auditId: obAnswer.auditId!, locationId: obAnswer.locationId!, folderId: obAnswer.folderId!, sub_locationId: obAnswer.subLocationId!, sublocation_subfolderId: obAnswer.sublocation_subfolder_id!)
        // //print("dictSubLocationSubfolder =\(dictSubLocationSubfolder)")
        self.subLocationLayerTitle = dictSubLocationSubfolder["Name"] as? String
        self.subLocationLayerDesc = dictSubLocationSubfolder["Desc"] as? String
        
        let dictMainPhoto = obSqlite.getPhotoNameSubLocationSubFolder(auditId:  obAnswer.auditId!, locationId: obAnswer.locationId!, folderId: obAnswer.folderId!, subfolderId: obAnswer.subfolder_id!, sub_locationId: obAnswer.subLocationId!, sub_locationsub_folderId: obAnswer.sublocation_subfolder_id!, main_photo: 1, isSync: 0)
        
        if dictMainPhoto.count == 0 {
            self.subLocationLayerFirstImage = []
            self.arrMainSLSFPId = []
            self.incIdSLSFP = 0
        } else {
            self.subLocationLayerFirstImage = (dictMainPhoto["Name"] as? NSArray)!
            self.arrMainSLSFPId = (dictMainPhoto["Id"] as? NSMutableArray)!
            self.incIdSLSFP = dictMainPhoto["Id"] as? Int
        }
        
        self.questionId = obAnswer.questionId
        self.isSuperUserAudit = obAnswer.isSuperUserAudit
        if obAnswer.parentQuestionId == 0 {
            self.parentId = 0
        } else {
            self.parentId = 1
        }
        self.answerId = obAnswer.savedAnswer_id
        if obAnswer.questionType == QuestionType.Text {
            self.answerValue = obAnswer.savedAnswer
        } else {
            self.answerValue = ""
        }
        self.questionType = obAnswer.questionType
        self.questionImage = obAnswer.imgName
        self.questionPriority = obAnswer.priority
        self.questionExtraText = obAnswer.answerDescription
        
        let dictMultiPhoto = obSqlite.getPhotoNameSubLocationSubFolder(auditId:  obAnswer.auditId!, locationId: obAnswer.locationId!, folderId: obAnswer.folderId!, subfolderId: obAnswer.subfolder_id!, sub_locationId: obAnswer.subLocationId!, sub_locationsub_folderId: obAnswer.sublocation_subfolder_id!, main_photo: 0, isSync: 0)
                
        if dictMultiPhoto.count == 0 {
            self.mul_image =  []
            self.arrMultiSLSFPId = []
            self.incIdSLSFP = 0
        } else {
         //   //print("arrMiages = \((dictMultiPhoto["Id"] as? NSMutableArray)!)")
            
            self.mul_image =  (dictMultiPhoto["Name"] as? NSArray)!
            self.arrMultiSLSFPId = (dictMultiPhoto["Id"] as? NSMutableArray)!
            self.incIdSLSFP = dictMultiPhoto["Id"] as? Int
        //    //print("self.mul_image = \(self.mul_image.count)")
        }
        
        dictMultiPhoto.removeAllObjects()
        dictMainPhoto.removeAllObjects()
        dictSubfolder.removeAllObjects()
        dictSubLocationSubfolder.removeAllObjects()
        dictcountry.removeAllObjects() 
    }    
}
