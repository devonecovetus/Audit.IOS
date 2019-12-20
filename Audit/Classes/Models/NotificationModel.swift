//
//  NotificationModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 31/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class NotificationModel: NSObject {
    var date:String? = String()
    var notify_id:String? = String()
    var title:String? = String()
    var type: String? = String()
    var notifyCount: String? = String()
    var photo: String? = String()
    
    var role: String? = String()
    var user_name: String? = String()
    var user_id: Int? = Int()

    override init() { }
    
    func initWith(dict: NSDictionary) {
        
        self.date = dict["created_date"] as? String
        if let notifyid = dict["notify_id"] as? Int {
            self.notify_id = String(notifyid)
        } else if let strnotify_id = dict["notify_id"] as? String {
            self.notify_id = strnotify_id
        }
        self.title = dict["title"] as? String
        self.type = dict["type"] as? String
        if let notifycount = dict["notifyCount"] as? Int {
            self.notifyCount = String(notifycount)
        } else if let strnotify_count = dict["notifyCount"] as? String {
            self.notifyCount = strnotify_count
        }
        if let imgUrl1 = dict["photo"] as? String {
            if imgUrl1.count > 0 {
                self.photo = imgUrl1
                self.photo = self.photo?.replacingOccurrences(of: " ", with: "%20")
            } else {
                self.photo = ""
            }
        } else {
            self.photo = ""
        }
        
        if let struser_name = dict["Username"] as? String {
            self.user_name = struser_name
        }
        if let str_role = dict["Role"] as? String {
            self.role = str_role
        }
        if let str_userid = dict["User_id"] as? Int {
            self.user_id = str_userid
        }
    }
}
