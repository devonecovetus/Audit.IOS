//
//  WebServices.swift
//  Tyvo
//
//  Created by Gourav Joshi on 04/02/17.
//  Copyright © 2017 Gourav Joshi. All rights reserved.
//

import Foundation

struct Server {
    private init() {}
    enum Scheme {
        static let Name = "http://"
        static let NewName = "https://"
    }
    enum Domain {
        static let Dev = "dev.covetus.com"
        static let Live = "access4mii.com"
    }
    enum HostName {
        static let Testing = String(format:"%@%@/audit/", Server.Scheme.Name, Domain.Dev)
        static let Live = String(format:"%@%@/", Server.Scheme.NewName, Domain.Live)
    }
    enum Path {
        static let Name = "api/v1/"
    }
    enum API {
        static let TestUrl = String(format: "%@%@", Server.HostName.Testing, Server.Path.Name)
        static let LiveUrl = String(format: "%@%@", Server.HostName.Live, Server.Path.Name)
    }
    enum ImagePath {
        static let TestUrl = String(format: "%@storage/app/public/profilePic/chatfile/", imgBaseUrl)
    }
    enum Chat {
        static let Dev = String(format: "%@%@:8090", Server.Scheme.Name, Server.Domain.Dev)
        static let Live = String(format: "%@chat.%@", Server.Scheme.NewName,  Server.Domain.Live)
    }

    /// On changing the Base URL make sure you change the webcontent data links, IMag Base Url and chatBaseUrl
    static let BaseURL = Server.API.LiveUrl
    
    static let imgBaseUrl = Server.HostName.Live
    static let ChatBaseUrl = Chat.Live
}

// MARK: Webservices Constants

struct WebServiceName {
    static let UserLogin = "auth"
    static let ForgotPassword = "forgetPassword"
    static let GetUserDetail = "getUserById"
    static let ChangePassword = "changePassword"
    static let UpdateUser = "updateUser"
    static let GetModules = "getModules"
    static let GetQuestions = "getQuestion"
    static let GetQuestionsCopy = "getQuestionByLocation"
    static let GetQuestionData = "download-question-json"
    static let GetCategories = "categories"
    static let GetLocation = "get-location"
    static let GetSubLocation = "getContent"
    static let GetQuestionList = "getDistinctQuestion"
    static let GetFinalQuestionList = "getFinalQuestion"
    static let Contact = "contactUs"
    static let Logout = "logout"
    static let DeleteAllNotification = "notifyClearAll"
    static let GetNotification = "getNotification"
    static let NotificationDetails = "notificationDetails"
    static let GetAuditStatus = "getAuditStatus"
    static let NotifyCount = "notifyCount"
    static let NotifyBellCount = "notifyBellCount"
    static let SeenNotify = "seenNotify"
    static let GetCountryStandard = "getCountryStandard"
    static let GetAgentAuditId = "getAgentByAuditorId"
    static let GetChatUsersList = "getChatUsersList"
    static let RequesttoAdminforChat = "request-to-admin-for-chat"
    static let ChatUploadMedia = "uploadChatFileAuditor"
    static let GetauditHistory = "getauditHistory"
    static let SetNotifySetting = "setNotifySetting"
    static let SetNotificationStatusByType = "setNotifyByType"
    static let GetAuditSync = "getAuditSync"
    static let DataSyncCom = "DataSyncCom"
    static let LocationArrange = "LocationArrange"
    static let GetAuditReport = "getAuditReport"
    static let AboutUs = "about"
    static let TermsConditions = "terms"
    static let StandardAndPractices = "standard"
    static let News = "news"
    static let Help = "help"
    static let GenerateReport = "generateReport"
    static let FinallySync = "finalsync"
    static let GetBusinessCategories = "getBusinessSectors"
    static let SubmitBusinessSectors = "StoreBusinessSectors"
    
}

