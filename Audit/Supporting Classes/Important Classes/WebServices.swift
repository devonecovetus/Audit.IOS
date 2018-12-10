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
    enum HostName {
        static let Testing = String(format:"%@dev.covetus.com/audit/", Server.Scheme.Name)
    }
    enum Path {
        static let Test = "api/v1/"
    }
    enum API {
        static let TestUrl = String(format: "%@%@", Server.HostName.Testing, Server.Path.Test)
    }
    enum ImagePath {
        static let TestUrl = String(format: "%@storage/app/public/profilePic/chatfile/", imgBaseUrl)
    }
    static let imgBaseUrl = Server.HostName.Testing
    static let BaseURL = Server.API.TestUrl
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
    static let GetCategories = "categories"
    static let ContactUs = "contactUs"
    static let Logout = "logout"
    static let GetNotification = "getNotification"
    static let NotificationDetails = "notificationDetails"
    static let GetAuditStatus = "getAuditStatus"
    static let NotifyCount = "notifyCount"
    static let NotifyBellCount = "notifyBellCount"
    static let GetCountryStandard = "getCountryStandard"
    static let GetAgentAuditId = "getAgentByAuditorId"
    static let GetChatUsersList = "getChatUsersList"
    static let RequesttoAdminforChat = "request-to-admin-for-chat"
    static let ChatUploadMedia = "uploadChatFileAuditor"
    static let GetauditHistory = "getauditHistory"
    static let SetNotifySetting = "setNotifySetting"
    static let SetNotificationStatusByType = "setNotifyByType"

}

