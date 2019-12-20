//
//  NotificationListProtocol.swift
//  Audit
//
//  Created by Rupesh Chhabra on 22/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

protocol NotificationListDelegate {
    func getNotificationList()
    func NotificationSeen(notifyid:Int)
   
}

extension NotificationListViewController: NotificationListDelegate {
    func getNotificationList() {
        /// API code here
        self.executeUIProcess({
         self.btn_DeleteAll.alpha = 0.0
        })
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetNotification, methodType: 1, forContent: 1, OnView: self, withParameters: MF.initializeDictWithUserId()) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                let dictresponse = dictJson["response"] as! NSDictionary
                for i in 0..<(dictresponse["notification"] as! NSArray).count {
                    autoreleasepool {
                        let obRequest:NotificationModel? = NotificationModel()
                        obRequest?.initWith(dict: (dictresponse["notification"] as! NSArray)[i] as! NSDictionary)
                        self.notificationList?.append(obRequest!)
                    }
                }
                self.executeUIProcess({
                    self.tblView?.reloadData()
                    if self.notificationList!.count > 0 {
                        self.btn_DeleteAll.alpha = 1.0
                    } else {
                        self.btn_DeleteAll.alpha = 0.0
                    }
                })
            }
        }        
    }
    
    func deleteAllNotification() {
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.DeleteAllNotification, methodType: 1, forContent: 1, OnView: self, withParameters: MF.initializeDictWithUserId()) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                
                self.notificationList?.removeAll()
                self.executeUIProcess({
                    self.btn_DeleteAll.alpha = 0.0
                    self.tblView?.reloadData()
                })
                self.getNotificationList()
            }
        }
    }
    
    func NotificationSeen(notifyid:Int) {
        /// API code here
        let dictP = NSMutableDictionary()
        dictP.setValue(UserProfile.id, forKey: "id")
        dictP.setValue(UserProfile.authToken, forKey: "auth_token")
        dictP.setValue(notifyid, forKey: "notify_id")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.SeenNotify, methodType: 1, forContent: 1, OnView: self, withParameters: dictP, IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
            }
        }
    }
}
