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
        if let photo_str = dict["photo"] as? String {
            self.photo = photo_str
        }
    }
}
