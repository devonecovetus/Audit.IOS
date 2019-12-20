//
//  ReportModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 30/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ReportModel: NSObject {
    
    
    var incId: Int? = Int()
    var reportTitle: String? = String()
    var reportDescription: String? = String()
    var isDownloaded: Bool? = Bool()
    var startDate: String? = String()
    var endDate: String? = String()
    var address:String? = String()
    var city:String? = String()
    var state:String? = String()
    var country:String? = String()
    var reportLink:URL? = URL(string: "")
    var auditorReportLink:URL? = URL(string: "")
    var inspectorReportLink:URL? = URL(string: "")
    var agentName:String? = String()
    var agentEmail:String? = String()
    var agentPhone:String? = String()
    var agentPhoto:String? = String()
    var auditType: Int? = Int()
    

    override init() {}
    
    func initWith(dict: NSDictionary) {
        if let dictAudit = dict["auditDetails"] as? NSDictionary {
            
            self.incId = dictAudit["id"] as? Int
            self.reportTitle = dictAudit["title"] as? String
            self.reportDescription = dictAudit["description"] as? String
            self.startDate = dictAudit["start_date"] as? String
            self.endDate = dictAudit["end_date"] as? String
            self.address = dictAudit["address"] as? String
            self.city = dictAudit["city"] as? String
            self.state = dictAudit["State"] as? String
            self.country = dictAudit["country"] as? String
            self.reportLink =  URL(string: (dictAudit["report"] as? String)!)
            self.auditorReportLink =  URL(string: (dictAudit["auditor_pdf"] as? String)!)
            self.inspectorReportLink =  URL(string: (dictAudit["inspector_pdf"] as? String)!)
            self.auditType = dictAudit["auditType"] as? Int
        }
        if let dictAgent = dict["agentDetails"] as? NSDictionary {
            
            self.agentName = dictAgent["fulname"] as? String
            self.agentEmail = dictAgent["email"] as? String
            self.agentPhoto = dictAgent["photo"] as? String
            self.agentPhone = dictAgent["phone"] as? String
        }
    }
    
}

