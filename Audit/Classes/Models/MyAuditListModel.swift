//
//  MyAuditListModel.swift
//  Audit
//
//  Created by Mac on 11/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyAuditListModel: NSObject {

    var id: Int? = Int()
    var audit_id: Int? = Int()
    var audit_title: String? = String()
    var audit_status: Int? = Int()
    
    var assign_by: String? = String()
    var target_date: String? = String()
    var assignDate: String? = String()
    var countryId: Int? = Int()
    var language: String? = String()
    var syncProgress: CGFloat? = CGFloat()
    var isSynching: Bool? = Bool()
    var isSyncStarted: Int? = Int()
    var isSyncCompleted: Int? = Int()
    var auditType: Int? = Int()
    var auditorLink:String? = String()
    var inspectorLink:String? = String()
    var isFinallySynced:Int? = Int()
    /// This will keep a track how many answers are for sync
    var totalAnswersForSync:Int? = Int()
    var totalAnswersAreSynced:Int? = Int() /// this will keep how many are synced
    private static var obAuditModel: MyAuditListModel?
    
    override init() { }
    
    func initWith(dict: NSDictionary) {
        //self.id = dict["id"] as? Int
        
        if let auditId = (dict["auditDetails"] as! NSDictionary)["id"] as? Int {
            self.audit_id = auditId
        } else if let auditId = (dict["auditDetails"] as! NSDictionary)["id"] as? String {
            self.audit_id = Int(auditId)
        }
        
        //print("audit Id = \(self.audit_id)")
        
        self.audit_title =  (dict["auditDetails"] as! NSDictionary)["title"] as? String
        self.audit_status =  AuditStatus.InComplete
        if let dictP = dict["agentDetails"] as? NSDictionary {
            self.assign_by =  dictP["fulname"] as? String
        }
        self.auditType = (dict["auditDetails"] as! NSDictionary)["auditType"] as? Int
        self.assignDate =  (dict["auditDetails"] as! NSDictionary)["assign_date"] as? String
        self.target_date =  (dict["auditDetails"] as! NSDictionary)["end_date"] as? String
        self.countryId = 0
        self.language = "en"
        self.isSyncStarted = 0
        self.isSyncCompleted = 0
        self.auditorLink = ""
        self.inspectorLink = ""
        self.isFinallySynced = 0
        self.totalAnswersAreSynced = 0
        self.totalAnswersForSync = 0
    }
    
    class func sharedInstance() -> MyAuditListModel {
        
        if obAuditModel == nil {
            //print("MyAuditListModel object nil and initiates")
            obAuditModel = MyAuditListModel()
        } else {
            //print("MyAuditListModel object not nil")
        }
        return obAuditModel!
    }
    
}
